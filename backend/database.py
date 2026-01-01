import asyncpg
import subprocess
import os
from datetime import datetime

from models import *


class Database:
    def __init__(self, user: str, password: str, host: str, port: str, database: str) -> None: 
        self.db_info = {"user": user, "password": password, "host": host, "port": port, "database": database}
        self.pool = None

    async def create_pool(self) -> None:
        self.pool = await asyncpg.create_pool(**self.db_info)

    async def dispose(self) -> None:
        await self.pool.close()

    async def create_plant(self, plant: Plant):
        async with self.pool.acquire() as conn:
            query = """
            INSERT INTO plants (plantname, price, category, humidity, temperature, description, size, isfavorite)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING plantid
            """
            plant_id = await conn.fetchval(query, plant.plantName, plant.price, plant.category, plant.humidity, plant.temperature, plant.description, plant.size, plant.isfavorite)
            return plant_id

    async def get_plants(self, user_id=None):
        async with self.pool.acquire() as conn:
            if user_id:
                return await conn.fetch("""
                    SELECT 
                        p.*,
                        CASE WHEN f.user_id IS NOT NULL THEN true ELSE false END as isfavorite
                    FROM plants p
                    LEFT JOIN favorites f ON p.plantid = f.plantid AND f.user_id = $1
                """, user_id)
            else:
                return await conn.fetch("SELECT *, false as isfavorite FROM plants")

    async def get_plant(self, plant_id: int):
        async with self.pool.acquire() as conn:
            return await conn.fetchrow("SELECT * FROM plants WHERE plantid = $1", plant_id)
        
    async def update_plant_price(self, plant_id: int, updated_price: int):
        async with self.pool.acquire() as conn:
            return await conn.execute("UPDATE plants SET price = $1 WHERE plantid = $2",
                                      updated_price, plant_id)
         
    async def delete_plant(self, plant_id: int):
        async with self.pool.acquire() as conn:
            return await conn.execute("DELETE FROM plants WHERE plantid = $1",plant_id)

    async def create_user(self, user):
        async with self.pool.acquire() as conn:
            await conn.execute("INSERT INTO users (firstName, lastName, password, username, email)"
                               "VALUES ($1, $2, $3, $4, $5)", 
                               user.firstName, user.lastName, user.password, user.username, user.email)

    async def get_users(self):
        async with self.pool.acquire() as conn:
            return await conn.fetch("SELECT * FROM users")

    async def get_user(self, session_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetchrow("SELECT * FROM users WHERE userid = $1", user_id)

    async def get_users_username(self, session_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetchrow("SELECT username FROM users WHERE userid = $1", user_id)

    async def check_user_exists(self, user):
        async with self.pool.acquire() as conn:
            if user.email:
                return await conn.fetchval("SELECT userid FROM users WHERE email = $1 AND password = $2",
                                        user.email, user.password)
            else:
                return await conn.fetchval("SELECT userid FROM users WHERE username = $1 AND password = $2",
                                        user.username, user.password)

    async def get_userid_by_sessionid(self, session_id):
        async with self.pool.acquire() as conn:
            try:
                user_id = await conn.fetchval("SELECT userid from sessions WHERE sessionid = $1", session_id)
                if not user_id:
                    print(f"Warning: No user found for session_id: {session_id}")
                return user_id
            except Exception as e:
                print(f"Error in get_userid_by_sessionid: {e}")
                raise

    async def add_new_session(self, userid, session_id):
        async with self.pool.acquire() as conn:
            await conn.execute("INSERT INTO sessions (userid, sessionid)"
                                "VALUES ($1, $2)",
                                userid, session_id)

    async def check_user_is_admin(self, session_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetchval("SELECT is_admin FROM users WHERE userid = $1", user_id)

    async def get_cart_items(self, session_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetch("select plantname, price, userid, plantid, quantity from plants NATURAL JOIN cart_items where userid = $1", user_id)

    async def add_to_cart(self, session_id, plant_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            await conn.execute("insert INTO cart_items (userid, plantid, quantity) VALUES ($1, $2, 1)", user_id, plant_id)

    async def delete_cart_item(self, session_id, plant_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.execute("delete from cart_items where userid = $1 and plantid = $2", user_id, plant_id)

    async def clear_cart_items(self, session_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.execute("delete from cart_items where userid = $1", user_id)

    async def create_order(self, session_id: str, tracking_code: str, cart_items: list):
        """Create an order from cart items"""
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            if not user_id:
                raise Exception("User not found")
            
            # Check if orders table exists
            try:
                table_exists = await conn.fetchval("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'orders'
                    )
                """)
                if not table_exists:
                    raise Exception("Orders table does not exist. Please run create_orders_table.sql first.")
            except Exception as e:
                print(f"Error checking orders table: {e}")
                raise
            
            # Calculate total amount
            total_amount = 0.0
            for item in cart_items:
                total_amount += float(item['price']) * int(item['quantity'])
            
            print(f"Creating order: user_id={user_id}, tracking_code={tracking_code}, total={total_amount}")
            
            # Create order
            try:
                order_id = await conn.fetchval("""
                    INSERT INTO orders (user_id, tracking_code, total_amount, payment_method, status)
                    VALUES ($1, $2, $3, $4, $5)
                    RETURNING order_id
                """, user_id, tracking_code, total_amount, 'cash_on_delivery', 'pending')
                
                print(f"Order created with ID: {order_id}")
            except Exception as e:
                print(f"Error creating order: {e}")
                raise Exception(f"Failed to create order: {e}")
            
            # Insert order items
            try:
                for item in cart_items:
                    await conn.execute("""
                        INSERT INTO order_items (order_id, plant_id, quantity, price)
                        VALUES ($1, $2, $3, $4)
                    """, order_id, item['plantid'], item['quantity'], item['price'])
                print(f"Inserted {len(cart_items)} order items")
            except Exception as e:
                print(f"Error inserting order items: {e}")
                raise Exception(f"Failed to insert order items: {e}")
            
            return order_id

    async def increase_quantity_to_cart_item(self, session_id, plant_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.execute("update cart_items set quantity = quantity + 1 where userid = $1 and plantid = $2", user_id, plant_id)

    async def decrease_quantity_from_cart_item(self, session_id, plant_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.execute("update cart_items set quantity = quantity - 1 where userid = $1 and plantid = $2", user_id, plant_id)

    async def checkout(self, session_id):
        async with self.pool.acquire() as conn:
            customer_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetchrow("SELECT * FROM addresses WHERE customer_id = $1", customer_id)

    async def verify_address(self, session_id, address: Address):
        async with self.pool.acquire() as conn:
            customer_id = await self.get_userid_by_sessionid(session_id)
            return await conn.execute("INSERT INTO addresses (customer_id, reciever_first_name, reciever_last_name, street, city, neighborhood, zip_code, alley, house_number, vahed)"
                                      "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
                                       customer_id, address.reciever_first_name, address.reciever_last_name, address.street, address.city, address.neighborhood, address.zipCode, address.alley, address.houseNumber, address.vahed)
    
    async def get_ratings(self, plant_id):
        async with self.pool.acquire() as conn:
            return await conn.fetch("SELECT ratings.rating, ratings.reaction, users.username FROM ratings JOIN users ON ratings.user_id = users.userid WHERE ratings.plantid = $1", plant_id)

    async def rate_plant(self, session_id, rating: Rating):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            await conn.execute("INSERT INTO ratings (user_id, plantid, rating, reaction) "
                                "VALUES ($1, $2, $3, $4) "
                                "ON CONFLICT (user_id, plantid) DO UPDATE SET rating = EXCLUDED.rating",
                                user_id, rating.plant_id, rating.rating, rating.reaction)

    async def get_rating_by_user_and_plant(self,session_id, plant_id):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            return await conn.fetchrow("SELECT * FROM ratings WHERE user_id = $1 AND plantid = $2", user_id, plant_id)

    async def update_rating(self, session_id, rating):
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            await conn.execute(
                "UPDATE ratings SET rating = $1, reaction = $2 WHERE user_id = $3 AND plantid = $4",
                rating.rating, rating.reaction, user_id, rating.plant_id)

    async def get_plants_new(self, query, category, user_id=None):
        async with self.pool.acquire() as conn:
            if user_id:
                base_query = """
                    SELECT 
                        p.*,
                        CASE WHEN f.user_id IS NOT NULL THEN true ELSE false END as isfavorite
                    FROM plants p
                    LEFT JOIN favorites f ON p.plantid = f.plantid AND f.user_id = $1
                """
                if query and category:
                    return await conn.fetch(base_query + " WHERE p.plantname ILIKE $2 AND p.category = $3 COLLATE pg_catalog.default", 
                                            user_id, f"%{query}%", category)
                elif query:
                    return await conn.fetch(base_query + " WHERE p.plantname ILIKE $2 COLLATE pg_catalog.default", user_id, f"%{query}%")
                elif category:
                    return await conn.fetch(base_query + " WHERE p.category = $2", user_id, category)
                else:
                    return await conn.fetch(base_query, user_id)
            else:
                if query and category:
                    return await conn.fetch("SELECT *, false as isfavorite FROM plants WHERE plantname ILIKE $1 AND category = $2 COLLATE pg_catalog.default", 
                                            f"%{query}%", category)
                elif query:
                    return await conn.fetch("SELECT *, false as isfavorite FROM plants WHERE plantname ILIKE $1 COLLATE pg_catalog.default", f"%{query}%")
                elif category:
                    return await conn.fetch("SELECT *, false as isfavorite FROM plants WHERE category = $1", category)
                else:
                    return await conn.fetch("SELECT *, false as isfavorite FROM plants")

    async def get_categories(self):
        async with self.pool.acquire() as conn:
            categories = await conn.fetch("SELECT DISTINCT category AS name FROM plants")
            return [Categories(name=row['name']) for row in categories]

    async def notification(self, notification):
        async with self.pool.acquire() as conn:
            return await conn.execute("INSERT INTO notifications (notification_title, notification_comment)"
                                    "VALUES($1, $2)",
                                    notification.notification_title, notification.notification)

    async def get_notifications(self):
        async with self.pool.acquire() as conn:
            return await conn.fetch("SELECT * FROM notifications")

    async def delete_notification(self, notification_id: int):
        async with self.pool.acquire() as conn:
            return await conn.execute("DELETE FROM notifications WHERE notification_id = $1", notification_id)

    async def backup_database(self, backup_dir: str = "backups") -> str:
        """Create a backup of the database and return the backup file path"""
        os.makedirs(backup_dir, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"{self.db_info['database']}_backup_{timestamp}.sql"
        backup_path = os.path.join(backup_dir, backup_filename)
        
        # Build pg_dump command
        env = os.environ.copy()
        env['PGPASSWORD'] = self.db_info['password']
        
        cmd = [
            'pg_dump',
            '-h', self.db_info['host'],
            '-p', str(self.db_info['port']),
            '-U', self.db_info['user'],
            '-d', self.db_info['database'],
            '-f', backup_path,
            '--no-password'
        ]
        
        try:
            result = subprocess.run(
                cmd,
                env=env,
                capture_output=True,
                text=True,
                check=True
            )
            return backup_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Backup failed: {e.stderr}")

    async def restore_database(self, backup_file_path: str) -> bool:
        """Restore database from a backup file"""
        if not os.path.exists(backup_file_path):
            raise Exception(f"Backup file not found: {backup_file_path}")
        
        # Build psql command
        env = os.environ.copy()
        env['PGPASSWORD'] = self.db_info['password']
        
        cmd = [
            'psql',
            '-h', self.db_info['host'],
            '-p', str(self.db_info['port']),
            '-U', self.db_info['user'],
            '-d', self.db_info['database'],
            '-f', backup_file_path,
            '--no-password'
        ]
        
        try:
            result = subprocess.run(
                cmd,
                env=env,
                capture_output=True,
                text=True,
                check=True
            )
            return True
        except subprocess.CalledProcessError as e:
            raise Exception(f"Restore failed: {e.stderr}")

    async def change_password(self, session_id: str, old_password: str, new_password: str) -> bool:
        """Change password for a user"""
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            if not user_id:
                raise Exception("User not found")
            
            # Verify old password
            current_password = await conn.fetchval(
                "SELECT password FROM users WHERE userid = $1", user_id
            )
            if current_password != old_password:
                raise Exception("Old password is incorrect")
            
            # Update password
            await conn.execute(
                "UPDATE users SET password = $1 WHERE userid = $2",
                new_password, user_id
            )
            return True

    async def create_user_by_admin(self, user_data, is_admin: bool = False):
        """Create a new user by admin with access level"""
        async with self.pool.acquire() as conn:
            # Check if username or email already exists
            existing = await conn.fetchrow(
                "SELECT userid FROM users WHERE username = $1 OR email = $2",
                user_data.username, user_data.email
            )
            if existing:
                raise Exception("Username or email already exists")
            
            await conn.execute(
                "INSERT INTO users (firstname, lastname, password, username, email, is_admin) "
                "VALUES ($1, $2, $3, $4, $5, $6)",
                user_data.firstName, user_data.lastName, user_data.password,
                user_data.username, user_data.email, is_admin
            )
            return True

    async def get_sales_report(self, start_date: str = None, end_date: str = None):
        """Generate sales report using temporary table based on cart items"""
        async with self.pool.acquire() as conn:
            # Drop temporary table if exists (to avoid conflicts)
            await conn.execute("DROP TABLE IF EXISTS temp_sales_report")
            
            # Create temporary table for report based on cart items
            await conn.execute("""
                CREATE TEMP TABLE temp_sales_report AS
                SELECT 
                    u.userid AS user_id,
                    u.username,
                    u.email,
                    COUNT(DISTINCT ci.plantid) AS items_count,
                    COALESCE(SUM(ci.quantity), 0) AS total_quantity,
                    COALESCE(SUM(ci.quantity * p.price), 0) AS total_amount
                FROM users u
                LEFT JOIN cart_items ci ON u.userid = ci.userid
                LEFT JOIN plants p ON ci.plantid = p.plantid
                GROUP BY u.userid, u.username, u.email
            """)
            
            # Fetch from temporary table
            result = await conn.fetch("SELECT * FROM temp_sales_report ORDER BY total_amount DESC")
            
            # Temporary table will be automatically dropped when connection closes
            return result

    async def get_plant_sales_report(self):
        """Generate plant sales report based on cart items and ratings"""
        async with self.pool.acquire() as conn:
            return await conn.fetch("""
                SELECT 
                    p.plantid,
                    p.plantname,
                    p.category,
                    p.price,
                    COUNT(DISTINCT ci.userid) AS times_sold,
                    COALESCE(SUM(ci.quantity), 0) AS total_quantity_sold,
                    COALESCE(SUM(ci.quantity * p.price), 0) AS total_revenue,
                    COALESCE(AVG(r.rating), 0) AS average_rating,
                    COUNT(DISTINCT r.user_id) AS total_ratings
                FROM plants p
                LEFT JOIN cart_items ci ON p.plantid = ci.plantid
                LEFT JOIN ratings r ON p.plantid = r.plantid
                GROUP BY p.plantid, p.plantname, p.category, p.price
                ORDER BY total_revenue DESC NULLS LAST
            """)

    async def get_user_activity_report(self):
        """Generate user activity report based on cart items, ratings, and orders"""
        async with self.pool.acquire() as conn:
            return await conn.fetch("""
                SELECT 
                    u.userid,
                    u.username,
                    u.email,
                    u.is_admin,
                    COUNT(DISTINCT ci.plantid) AS plants_in_cart,
                    COALESCE(SUM(ci.quantity), 0) AS total_cart_items,
                    COUNT(DISTINCT r.plantid) AS plants_rated,
                    COUNT(*) FILTER (WHERE r.rating IS NOT NULL) AS total_ratings_given,
                    COALESCE(COUNT(DISTINCT o.order_id), 0) AS orders_count
                FROM users u
                LEFT JOIN cart_items ci ON u.userid = ci.userid
                LEFT JOIN ratings r ON u.userid = r.user_id
                LEFT JOIN orders o ON u.userid = o.user_id
                GROUP BY u.userid, u.username, u.email, u.is_admin
                ORDER BY orders_count DESC NULLS LAST
            """)

    async def add_to_favorites(self, session_id: str, plant_id: int):
        """Add a plant to user's favorites"""
        async with self.pool.acquire() as conn:
            if not session_id:
                raise Exception("Session ID is required")
            
            try:
                user_id = await self.get_userid_by_sessionid(session_id)
                print(f"DEBUG: user_id from session: {user_id}, type: {type(user_id)}")
                if not user_id:
                    raise Exception("User not found")
                
                # Check if plant exists
                plant_exists = await conn.fetchval("SELECT plantid FROM plants WHERE plantid = $1", plant_id)
                if not plant_exists:
                    raise Exception(f"Plant with ID {plant_id} not found")
                
                # Check if already in favorites
                existing = await conn.fetchrow(
                    "SELECT * FROM favorites WHERE user_id = $1 AND plantid = $2",
                    user_id, plant_id
                )
                if existing:
                    print(f"DEBUG: Plant {plant_id} already in favorites for user {user_id}")
                    return  # Already in favorites
                
                print(f"DEBUG: Inserting into favorites: user_id={user_id}, plantid={plant_id}")
                try:
                    await conn.execute(
                        "INSERT INTO favorites (user_id, plantid) VALUES ($1, $2) ON CONFLICT DO NOTHING",
                        user_id, plant_id
                    )
                    print(f"DEBUG: Successfully added plant {plant_id} to favorites")
                except Exception as insert_error:
                    # If ON CONFLICT doesn't work, try without it
                    print(f"DEBUG: ON CONFLICT not supported, trying regular INSERT: {insert_error}")
                    await conn.execute(
                        "INSERT INTO favorites (user_id, plantid) VALUES ($1, $2)",
                        user_id, plant_id
                    )
                    print(f"DEBUG: Successfully added plant {plant_id} to favorites")
            except Exception as e:
                import traceback
                print(f"ERROR in add_to_favorites: {e}")
                print(f"Session ID: {session_id}, Plant ID: {plant_id}")
                print(traceback.format_exc())
                raise

    async def remove_from_favorites(self, session_id: str, plant_id: int):
        """Remove a plant from user's favorites"""
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            if not user_id:
                raise Exception("User not found")
            
            await conn.execute(
                "DELETE FROM favorites WHERE user_id = $1 AND plantid = $2",
                user_id, plant_id
            )

    async def get_favorite_plants(self, session_id: str):
        """Get all favorite plants for a user"""
        async with self.pool.acquire() as conn:
            if not session_id:
                return []
            
            try:
                user_id = await self.get_userid_by_sessionid(session_id)
                if not user_id:
                    return []
                
                return await conn.fetch("""
                    SELECT 
                        p.plantid,
                        p.plantname,
                        p.price,
                        p.category,
                        p.humidity,
                        p.temperature,
                        p.size,
                        p.description,
                        true as isfavorite
                    FROM favorites f
                    JOIN plants p ON f.plantid = p.plantid
                    WHERE f.user_id = $1
                """, user_id)
            except Exception as e:
                # Log error and return empty list
                print(f"Error in get_favorite_plants: {e}")
                return []

    async def check_is_favorite(self, session_id: str, plant_id: int) -> bool:
        """Check if a plant is in user's favorites"""
        async with self.pool.acquire() as conn:
            user_id = await self.get_userid_by_sessionid(session_id)
            if not user_id:
                return False
            
            result = await conn.fetchrow(
                "SELECT * FROM favorites WHERE user_id = $1 AND plantid = $2",
                user_id, plant_id
            )
            return result is not None