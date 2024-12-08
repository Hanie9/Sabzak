import time
from fastapi import FastAPI, HTTPException
from database import Database
from contextlib import asynccontextmanager
from fastapi.responses import FileResponse
from pathlib import Path
from session import create_session
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import os

from models import *

print(
    os.getenv("POSTGRES_USER"),
    os.getenv("POSTGRES_PASSWORD"),
    os.getenv("POSTGRES_HOST"),
    os.getenv("POSTGRES_PORT"),
    os.getenv("POSTGRES_DB"),
    flush=True
)

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
cart = Cart()

app.mount("/images", StaticFiles(directory="images"), name="images")

@app.get("/images")
def get_images():
    image_folder = "images/"
    image_files = [f for f in os.listdir(image_folder) if os.path.isfile(os.path.join(image_folder, f))]
    image_urls = [f"http://45.156.23.34:8000/images/{image}" for image in image_files]
    return JSONResponse(content={"images": image_urls})

@app.post("/plants")
async def create_plant(plant: Plant):
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
async def update_plant_price(plant_id: int, updated_price: int):
    await db.update_plant_price(plant_id, updated_price)
    return {"message": "Price updated successfully"}

@app.delete("/plants/{plant_id}")
async def delete_plant(plant_id: int):
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
    return {"message": "Logged in successfully", "sessionid": session_id}

@app.post("/cart/add")
def add_to_cart(plant: Plant, quantity: int = 1):
    for item in cart.items:
        if item.plant.plantId == plant.plantId:
            item.quantity += quantity
            return {"message": "Added to cart", "cart": cart}
    cart.items.append(CartItem(plant=plant, quantity=quantity))
    return {"message": "Added to cart", "cart": cart}

@app.delete("/cart/remove/{plant_id}")
def remove_from_cart(plant_id: int):
    cart.items = [item for item in cart.items if item.plant.plantId != plant_id]
    return {"message": "Removed from cart", "cart": cart}

@app.get("/cart")
def get_cart():
    return {"cart": cart}

@app.post("/cart/clear")
def clear_cart():
    cart.items = []
    return {"message": "Cart cleared", "cart": cart}