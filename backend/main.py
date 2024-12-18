import time
from fastapi import FastAPI, HTTPException, Request
from database import Database
from contextlib import asynccontextmanager
from fastapi.responses import FileResponse
from pathlib import Path
from session import create_session
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import os

from models import *

db = Database(
    os.getenv("POSTGRES_USER"),
    os.getenv("POSTGRES_PASSWORD"),
    os.getenv("POSTGRES_HOST"),
    os.getenv("POSTGRES_PORT"),
    os.getenv("POSTGRES_DB")
)    

@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.create_pool()
    yield
    await db.dispose()

app = FastAPI(lifespan=lifespan)

app.mount("/images", StaticFiles(directory="images"), name="images")

@app.get("/images")
def get_images():
    image_folder = "images/"
    image_files = [f for f in os.listdir(image_folder) if os.path.isfile(os.path.join(image_folder, f))]
    image_urls = [f"http://45.156.23.34:8000/images/{image}" for image in image_files]
    return JSONResponse(content={"images": image_urls})

@app.post("/plants/add")
async def create_plant(request: Request, plant: Plant):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    await db.create_plant(plant)
    return {"message": "Plant posted successfully"}


@app.get("/plants")
async def get_plants():
    plants = await db.get_plants()
    return plants


@app.get("/plants/{plant_id}")
async def get_plant(plant_id: int):
    plant = await db.get_plant(plant_id)
    return plant

@app.patch("/plants/{plant_id}")
async def update_plant_price(request: Request, plant_id: int, updated_price: int):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    await db.update_plant_price(plant_id, updated_price)
    return {"message": "Price updated successfully"}

@app.delete("/plants/{plant_id}")
async def delete_plant(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    await db.delete_plant(plant_id)
    return {"message": "Plant deleted successfully"}

@app.post("/sign_up")
async def create_user(user: SignUp):
    userid = await db.check_user_exists(user)
    if not userid:
        await db.create_user(user)
        session_id = create_session()
        userid = await db.check_user_exists(user)
        await db.add_new_session(userid, session_id)
        return {"message": "user added successfully", "session_id": session_id}
    return {"error": "This user already exist"}

@app.post("/login")
async def login_user(user: Login):
    userid = await db.check_user_exists(user)
    if not userid:
        return {"error": f"Wrong {"email" if user.email else "username"} or password has been given."}
    session_id = create_session()
    await db.add_new_session(userid, session_id)
    return {"message": "Logged in successfully", "session_id": session_id}

@app.get("/users")
async def get_users(request: Request):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    users = await db.get_users()
    return users

@app.post("/cart/add/{plant_id}")
async def add_to_cart(request: Request, plant_id):
    session_id = request.headers.get("session_id")
    await db.add_to_cart(session_id, plant_id)
    return {"message": "Plant added to cart successfully"}

@app.delete("/cart/delete/{plant_id}")
async def delete_cart_item(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    await db.delete_cart_item(session_id, plant_id)
    return {"message": "Plant deleted successfully"}

@app.get("/cart")
async def get_cart_items(request: Request):
    session_id = request.headers.get("session_id")
    cart_items = await db.get_cart_items(session_id)
    return cart_items

@app.delete("/cart/clear")
async def clear_cart_items(request: Request):
    session_id = request.headers.get("session_id")
    await db.clear_cart_items(session_id)
    return {"message": "Cart cleared successfully"}

@app.post("/cart/increase_quantity")
async def increase_quantity_to_cart_item(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    await db.increase_quantity_to_cart_item(session_id, plant_id)
    return {"message": "item's quantity increased successfully"}

@app.post("/cart/decrease_quantity")
async def decrease_quantity_from_cart_item(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    await db.decrease_quantity_from_cart_item(session_id, plant_id)
    return {"message": "item's quantity decreased successfully"}

@app.get("/is_admin/{session_id}")
async def is_admin(session_id: str):
    return await db.check_user_is_admin(session_id)