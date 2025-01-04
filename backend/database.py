import asyncpg

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