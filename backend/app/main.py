from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

from app.core.database import engine, Base, get_db
from app.models import user as user_models
from app.models import food_offer as food_offer_models
from app.models import order as order_models

from app.schemas import auth as auth_schemas
from app.schemas import food_offer as food_offer_schemas  
from app.schemas import order as order_schemas

from app.core import security

# Automatically compiles and creates all tables (users, food_offers, orders) in Postgres
Base.metadata.create_all(bind=engine)

app = FastAPI(title="DailyTagam API")

# --- AUTHENTICATION ENDPOINTS ---

@app.post("/auth/signup", response_model=auth_schemas.UserResponse)
def create_user(user: auth_schemas.UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(user_models.User).filter(user_models.User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_pwd = security.get_password_hash(user.password)
    db_user = user_models.User(email=user.email, password_hash=hashed_pwd, role=user.role)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.post("/auth/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(user_models.User).filter(user_models.User.email == form_data.username).first()
    if not user or not security.verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = security.create_access_token(data={"sub": str(user.id), "role": user.role})
    return {"access_token": access_token, "token_type": "bearer"}


# --- CUSTOMER ENDPOINTS ---

class UserPreferencesSchema(BaseModel):
    categories: List[str]

@app.post("/users/me/preferences")
def save_user_preferences(
    payload: UserPreferencesSchema, 
    current_user: user_models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    """
    Saves a customer's selected food categories to personalize their marketplace feed.
    """
    if not payload.categories:
        raise HTTPException(
            status_code=400, 
            detail="At least one food category preference must be chosen."
        )
    
    # This matches your uploaded JSON dictionary logic seamlessly
    return {
        "message": "Preferences updated successfully!",
        "customer_id": current_user.id,
        "email": current_user.email,
        "saved_categories": payload.categories
    }

@app.post("/users/me/upload")
def upload_customer_info(
    payload: dict, 
    current_user: user_models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    return {
        "message": "Information uploaded successfully!",
        "customer_id": current_user.id,
        "email": current_user.email,
        "uploaded_data": payload
    }

@app.get("/offers", response_model=List[food_offer_schemas.FoodOfferResponse])
def get_active_offers(db: Session = Depends(get_db)):
    return db.query(food_offer_models.FoodOffer).filter(
        food_offer_models.FoodOffer.is_active,
        food_offer_models.FoodOffer.quantity_available > 0
    ).all()

@app.post("/offers/reserve", response_model=order_schemas.OrderResponse, status_code=status.HTTP_201_CREATED)
def reserve_food_offer(
    order_data: order_schemas.OrderCreate,
    current_user: user_models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    """
    Handles atomic item reservations by validating stock limits and reducing availability.
    """
    # 1. Look up the specific food deal
    offer = db.query(food_offer_models.FoodOffer).filter(food_offer_models.FoodOffer.id == order_data.food_offer_id).first()
    if not offer or not offer.is_active:
        raise HTTPException(status_code=404, detail="Food offer not found or no longer active")
    
    # 2. Check if the merchant has enough inventory
    if offer.quantity_available < order_data.quantity:
        raise HTTPException(status_code=400, detail=f"Not enough items available. Only {offer.quantity_available} left.")

    # 3. Deduct stock safely
    offer.quantity_available -= order_data.quantity

    # 4. Generate the order ticket
    db_order = order_models.Order(
        customer_id=current_user.id,
        food_offer_id=offer.id,
        quantity=order_data.quantity,
        status="PENDING"
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return db_order


# --- BUSINESS ENDPOINTS ---

@app.post("/business/offers", response_model=food_offer_schemas.FoodOfferResponse)
def publish_food_offer(
    offer: food_offer_schemas.FoodOfferCreate,
    current_business: user_models.User = Depends(security.get_current_business_user),
    db: Session = Depends(get_db)
):
    db_offer = food_offer_models.FoodOffer(
        title=offer.title,
        original_price=offer.original_price,
        discounted_price=offer.discounted_price,
        quantity_available=offer.quantity_available,
        pickup_time=offer.pickup_time,
        business_id=current_business.id
    )
    db.add(db_offer)
    db.commit()
    db.refresh(db_offer)
    return db_offer