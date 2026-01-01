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
from pathlib import Path

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
async def get_plants(request: Request):
    session_id = request.headers.get("session_id")
    user_id = None
    if session_id:
        try:
            user_id = await db.get_userid_by_sessionid(session_id)
        except:
            pass
    plants = await db.get_plants(user_id)
    return plants

@app.get("/plants/{plant_id}")
async def get_plant(plant_id: int):
    plant = await db.get_plant(plant_id)
    return plant

@app.get("/plants_new")
async def get_plants_new(request: Request, query: str = Query(None), category: Optional[str] = Query(None)):
    session_id = request.headers.get("session_id")
    user_id = None
    if session_id:
        try:
            user_id = await db.get_userid_by_sessionid(session_id)
        except:
            pass
    plants = await db.get_plants_new(query, category, user_id)
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

@app.post("/database/backup")
async def backup_database(request: Request):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    try:
        backup_path = await db.backup_database()
        backup_filename = os.path.basename(backup_path)
        return FileResponse(
            backup_path,
            media_type='application/sql',
            filename=backup_filename
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/database/restore")
async def restore_database(request: Request, file: UploadFile = File(...)):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    
    # Save uploaded file temporarily
    restore_dir = "restore_temp"
    os.makedirs(restore_dir, exist_ok=True)
    temp_file_path = os.path.join(restore_dir, file.filename)
    
    try:
        # Save uploaded file
        async with aiofiles.open(temp_file_path, 'wb') as out_file:
            content = await file.read()
            await out_file.write(content)
        
        # Restore database
        await db.restore_database(temp_file_path)
        
        # Clean up temp file
        os.remove(temp_file_path)
        
        return {"message": "Database restored successfully"}
    except Exception as e:
        # Clean up temp file on error
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/change_password")
async def change_password(request: Request, password_data: ChangePassword):
    session_id = request.headers.get("session_id")
    if not session_id:
        raise HTTPException(status_code=400, detail="Missing session_id")
    try:
        await db.change_password(session_id, password_data.oldPassword, password_data.newPassword)
        return {"message": "Password changed successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/admin/create_user")
async def create_user_by_admin(request: Request, user_data: CreateUserByAdmin):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    try:
        await db.create_user_by_admin(user_data, user_data.isAdmin)
        return {"message": "User created successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/reports/sales")
async def get_sales_report(request: Request, start_date: Optional[str] = Query(None), end_date: Optional[str] = Query(None)):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    try:
        report = await db.get_sales_report(start_date, end_date)
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/reports/plant_sales")
async def get_plant_sales_report(request: Request):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    try:
        report = await db.get_plant_sales_report()
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/reports/user_activity")
async def get_user_activity_report(request: Request):
    session_id = request.headers.get("session_id")
    if not await db.check_user_is_admin(session_id):
        return {"message": "Forbidden"}
    try:
        report = await db.get_user_activity_report()
        return report
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/favorites/add/{plant_id}")
async def add_to_favorites(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    if not session_id:
        raise HTTPException(status_code=400, detail="Session ID is required")
    try:
        import traceback
        await db.add_to_favorites(session_id, plant_id)
        return {"message": "Plant added to favorites successfully"}
    except Exception as e:
        print(f"Error in add_to_favorites endpoint: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/favorites/remove/{plant_id}")
async def remove_from_favorites(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    try:
        await db.remove_from_favorites(session_id, plant_id)
        return {"message": "Plant removed from favorites successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/favorites")
async def get_favorites(request: Request):
    session_id = request.headers.get("session_id")
    if not session_id:
        return []
    try:
        favorites = await db.get_favorite_plants(session_id)
        return favorites
    except Exception as e:
        import traceback
        print(f"Error in get_favorites: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/favorites/check/{plant_id}")
async def check_is_favorite(request: Request, plant_id: int):
    session_id = request.headers.get("session_id")
    try:
        is_favorite = await db.check_is_favorite(session_id, plant_id)
        return {"is_favorite": is_favorite}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/orders/create")
async def create_order(request: Request):
    session_id = request.headers.get("session_id")
    if not session_id:
        raise HTTPException(status_code=400, detail="Session ID is required")
    try:
        import traceback
        order_data = await request.json()
        print(f"Received order data: {order_data}")
        tracking_code = order_data.get("tracking_code")
        cart_items = order_data.get("cart_items", [])
        if not tracking_code or not cart_items:
            raise HTTPException(status_code=400, detail="tracking_code and cart_items are required")
        
        print(f"Creating order with tracking_code: {tracking_code}, items: {len(cart_items)}")
        order_id = await db.create_order(session_id, tracking_code, cart_items)
        print(f"Order created successfully with ID: {order_id}")
        return {"order_id": order_id, "message": "Order created successfully"}
    except Exception as e:
        import traceback
        print(f"Error in create_order: {e}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))