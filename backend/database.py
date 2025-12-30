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

    async def get_plants(self):
        async with self.pool.acquire() as conn:
            return await conn.fetch("SELECT * FROM plants")

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
            return await conn.fetchval("SELECT userid from sessions WHERE sessionid = $1", session_id)

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

    async def get_plants_new(self, query, category):
        async with self.pool.acquire() as conn:
            if query and category:
                return await conn.fetch("SELECT * FROM plants WHERE plantname ILIKE $1 AND category = $2 COLLATE pg_catalog.default", 
                                        f"%{query}%", category)
            elif query:
                return await conn.fetch("SELECT * FROM plants WHERE plantname ILIKE $1 COLLATE pg_catalog.default", f"%{query}%")
            elif category:
                return await conn.fetch("SELECT * FROM plants WHERE category = $1", category)
            else:
                return await conn.fetch("SELECT * FROM plants")

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
        """Generate sales report using temporary table"""
        async with self.pool.acquire() as conn:
            # Drop temporary table if exists (to avoid conflicts)
            await conn.execute("DROP TABLE IF EXISTS temp_sales_report")
            
            # Create temporary table for report
            await conn.execute("""
                CREATE TEMP TABLE temp_sales_report AS
                SELECT 
                    o.id AS order_id,
                    o.order_number,
                    o.status,
                    o.order_date,
                    u.username,
                    u.email,
                    SUM(li.quantity * p.price) AS total_amount,
                    COUNT(li.id) AS items_count
                FROM orders o
                JOIN customer_details cd ON o.customer_id = cd.customer_id
                JOIN users u ON cd.customer_id = u.userid
                JOIN order_items oi ON o.id = oi.order_id
                JOIN line_items li ON oi.line_item_id = li.id
                JOIN plants p ON li.product_id = p.plantid
                WHERE ($1::DATE IS NULL OR o.order_date >= $1::DATE)
                  AND ($2::DATE IS NULL OR o.order_date <= $2::DATE)
                GROUP BY o.id, o.order_number, o.status, o.order_date, u.username, u.email
            """, start_date, end_date)
            
            # Fetch from temporary table
            result = await conn.fetch("SELECT * FROM temp_sales_report ORDER BY order_date DESC")
            
            # Temporary table will be automatically dropped when connection closes
            return result

    async def get_plant_sales_report(self):
        """Generate plant sales report"""
        async with self.pool.acquire() as conn:
            return await conn.fetch("""
                SELECT 
                    p.plantid,
                    p.plantname,
                    p.category,
                    p.price,
                    COUNT(li.id) AS times_sold,
                    SUM(li.quantity) AS total_quantity_sold,
                    SUM(li.quantity * p.price) AS total_revenue
                FROM plants p
                LEFT JOIN line_items li ON p.plantid = li.product_id
                LEFT JOIN order_items oi ON li.id = oi.line_item_id
                LEFT JOIN orders o ON oi.order_id = o.id
                GROUP BY p.plantid, p.plantname, p.category, p.price
                ORDER BY total_revenue DESC NULLS LAST
            """)

    async def get_user_activity_report(self):
        """Generate user activity report"""
        async with self.pool.acquire() as conn:
            return await conn.fetch("""
                SELECT 
                    u.userid,
                    u.username,
                    u.email,
                    u.is_admin,
                    COUNT(DISTINCT ci.plantid) AS plants_in_cart,
                    COUNT(DISTINCT r.plantid) AS plants_rated,
                    COUNT(DISTINCT o.id) AS orders_count
                FROM users u
                LEFT JOIN cart_items ci ON u.userid = ci.userid
                LEFT JOIN ratings r ON u.userid = r.user_id
                LEFT JOIN customer_details cd ON u.userid = cd.customer_id
                LEFT JOIN orders o ON cd.customer_id = o.customer_id
                GROUP BY u.userid, u.username, u.email, u.is_admin
                ORDER BY orders_count DESC NULLS LAST
            """)