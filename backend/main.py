import time
from fastapi import FastAPI, HTTPException, Request, UploadFile, File, Form, Query
from database import Database
from contextlib import asynccontextmanager
from fastapi.responses import FileResponse
from pathlib import Path
from session import create_session
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import aiofiles
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

@app.post("/images/upload_photo/{plant_id}")
async def upload_photo(request: Request, plant_id, file: UploadFile = File(...)):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}

    async with aiofiles.open(f"images/{plant_id}.png", 'wb') as out_file:
        content = await file.read()
        await out_file.write(content)

    return {"message": "Photo uploaded successfully"}


app.mount("/images", StaticFiles(directory="images"), name="images")

@app.get("/images")
def get_images():
    image_folder = "images/"
    image_files = [f for f in os.listdir(image_folder) if os.path.isfile(os.path.join(image_folder, f))]
    image_urls = [f"images/{image}" for image in image_files]
    return JSONResponse(content={"images": image_urls})

UPLOAD_DIR = "profiles"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@app.post("/profiles/upload_profile")
async def upload_profile(request: Request, file: UploadFile = File(...)):
    session_id = request.headers.get("session_id")
    if not session_id:
        raise HTTPException(status_code=400, detail="Missing session_id")
    user_id = await db.get_userid_by_sessionid(session_id)
    file_path = os.path.join(UPLOAD_DIR, f"{user_id}.png")
    async with aiofiles.open(file_path, 'wb') as out_file:
        content = await file.read()
        await out_file.write(content)

    return {"message": "Photo uploaded successfully", "file_path": file_path}

app.mount("/profiles", StaticFiles(directory=UPLOAD_DIR), name="profiles")

@app.get("/profile")
async def get_profile(request: Request):
    session_id = request.headers.get("session_id")
    if not session_id:
        raise HTTPException(status_code=400, detail="Missing session_id")
    user_id = await db.get_userid_by_sessionid(session_id)
    file_path = os.path.join(UPLOAD_DIR, f"{user_id}.png")
    if os.path.exists(file_path):
        image_url = f"profiles/{user_id}.png"
    else:
        image_url = ""
    return image_url

@app.post("/plants/add")
async def create_plant(request: Request, plant: Plant):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    plant_id = await db.create_plant(plant)
    return {"plantid": plant_id, "message": "Plant posted successfully"}

@app.get("/plants")
async def get_plants():
    plants = await db.get_plants()
    return plants

@app.get("/plants/{plant_id}")
async def get_plant(plant_id: int):
    plant = await db.get_plant(plant_id)
    return plant

@app.get("/plants_new")
async def get_plants_new(query: str = Query(None), category: Optional[str] = Query(None)):
    plants = await db.get_plants_new(query, category)
    return plants

@app.get("/categories")
async def get_categories():
    return await db.get_categories()

@app.patch("/edit_price/{plant_id}")
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

@app.post("/rate_plant")
async def rate_plant(request: Request, rating: Rating):
    session_id = request.headers.get("session_id")
    existing_rating = await db.get_rating_by_user_and_plant(session_id, rating.plant_id)
    if existing_rating:
        await db.update_rating(session_id, rating)
    else:
        await db.rate_plant(session_id, rating)
    return {"message": "Rating submitted successfully"}

@app.get("/ratings/{plant_id}")
async def get_ratings(plant_id: int):
        ratings = await db.get_ratings(plant_id)
        if not ratings:
            return {"average_rating": 0.0 , "reaction": []}
        avg_rating = sum(r["rating"] for r in ratings) / len(ratings)
        reactions = [{"rating": r['rating'], "username": r["username"], "reaction": r["reaction"]} for r in ratings]
        return {"average_rating": avg_rating, "reactions": reactions}

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
    profile_picture = f"http://45.156.23.34:8000/profiles/{session_id}.png"
    return {"message": "Logged in successfully", "session_id": session_id}

@app.get("/users")
async def get_users(request: Request):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    users = await db.get_users()
    return users

@app.get("/user")
async def get_user(request: Request):
    session_id = request.headers.get("session_id")
    user = await db.get_user(session_id)
    return user

@app.get("/users_username")
async def get_users_username(request: Request):
    session_id = request.headers.get("session_id")
    users = await db.get_users_username(session_id)
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

@app.get("/checkout")
async def checkout(request: Request):
    session_id = request.headers.get("session_id")
    return await db.checkout(session_id)

@app.post("/verify_address")
async def verify_address(request: Request, address: Address):
    session_id = request.headers.get("session_id")
    await db.verify_address(session_id, address)
    return {"message": "Address verified successfully"}

@app.post("/notification")
async def notification(request: Request, notification: Notification):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    return await db.notification(notification)

@app.get("/get_notifications")
async def get_notifications():
    return await db.get_notifications()

@app.delete("/delete_notification")
async def delete_notification(request: Request, notification_id: int):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    await db.delete_notification(notification_id)
    return {"message": "Notification deleted successfully"}