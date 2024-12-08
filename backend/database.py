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

    async def create_plant(self, plant):
        async with self.pool.acquire() as conn:
            await conn.execute("INSERT INTO plants (plantid, plantname, price, category, humidity, temperature, description, size, rating, isfavorite)"
                               "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)", 
                               plant.plantid, plant.plantName, plant.price, plant.category, plant.humidity, plant.temperature, plant.description, plant.size, plant.rating, plant.isfavorite)

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
            return await conn.execute("DELETE FROM plants WHERE plantid = $1",
                                      plant_id)

    async def create_user(self, user):
        async with self.pool.acquire() as conn:
            await conn.execute("INSERT INTO users (firstName, lastName, password, username, email)"
                               "VALUES ($1, $2, $3, $4, $5)", 
                               user.firstName, user.lastName, user.password, user.username, user.email)

    async def check_user_exists(self, user):
        async with self.pool.acquire() as conn:
            if user.email:
                return await conn.fetchval("SELECT userid FROM users WHERE email = $1 AND password = $2",
                                        user.email, user.password)
            else:
                return await conn.fetchval("SELECT userid FROM users WHERE username = $1 AND password = $2",
                                        user.username, user.password)

    async def add_new_session(self, userid, session_id):
        async with self.pool.acquire() as conn:
            await conn.execute("INSERT INTO sessions (userid, sessionid)"
                                "VALUES ($1, $2)",
                                userid, session_id)