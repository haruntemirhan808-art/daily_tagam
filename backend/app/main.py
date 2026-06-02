from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from datetime import date
from sqlalchemy.orm import Session
from typing import List, Optional
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
    return {"access_token": access_token, "token_type": "bearer", "role": user.role}


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
    Saves a customer's selected food categories to the PostgreSQL database.
    """
    if not payload.categories:
        raise HTTPException(
            status_code=400, 
            detail="At least one food category preference must be chosen."
        )
    
    # 1. Assign the Flutter array to the new JSON database column
    current_user.preferences = payload.categories
    
    # 2. Save the changes permanently to PostgreSQL
    db.commit()
    db.refresh(current_user)
    
    return {
        "message": "Preferences saved to database successfully!",
        "customer_id": current_user.id,
        "saved_categories": current_user.preferences
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

@app.get("/users/me/profile")
def get_customer_profile(
    current_user: user_models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    # Parse out a clean display name
    display_name = current_user.email.split("@")[0].capitalize()

    ordered_items = db.query(order_models.Order, food_offer_models.FoodOffer).join(
        food_offer_models.FoodOffer,
        order_models.Order.food_offer_id == food_offer_models.FoodOffer.id
    ).filter(order_models.Order.customer_id == current_user.id).all()

    meals_saved = sum(order.quantity for order, _ in ordered_items)
    money_saved_tenge = sum(
        max(0, (offer.original_price - offer.discounted_price) * order.quantity)
        for order, offer in ordered_items
    )
    total_spent = sum(
        offer.discounted_price * order.quantity
        for order, offer in ordered_items
    )
    bonus_points = total_spent // 10

    return {
        "name": display_name,
        "email": current_user.email,
        "meals_saved": meals_saved,
        "waste_saved_kg": round(meals_saved * 0.4, 1),
        "money_saved": f"₸{money_saved_tenge:,}",
        "bonus_points": bonus_points,
        "order_count": len(ordered_items),
        "total_spent": f"₸{total_spent:,}",
        "preferences": current_user.preferences or []
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

@app.get("/users/me/dashboard")
def get_customer_dashboard(
    current_user: user_models.User = Depends(security.get_current_user),
    db: Session = Depends(get_db)
):
    """
    Fetches the dynamic dashboard context for the logged-in customer.
    """
    display_name = current_user.email.split("@")[0].capitalize()

    businesses = db.query(user_models.User).filter(user_models.User.role == "business").limit(5).all()

    nearby_restaurants = []
    for biz in businesses:
        active_deals = db.query(food_offer_models.FoodOffer).filter(
            food_offer_models.FoodOffer.business_id == biz.id,
            food_offer_models.FoodOffer.is_active,
            food_offer_models.FoodOffer.quantity_available > 0
        ).count()

        nearby_restaurants.append({
            "id": biz.id,
            "name": f"{biz.email.split('@')[0].capitalize()} Restaurant",
            "distance": "0.5 km",
            "rating": 4.8,
            "active_deals": active_deals
        })

    # Build a customer-specific stats summary from actual completed orders
    customer_orders = db.query(order_models.Order, food_offer_models.FoodOffer).join(
        food_offer_models.FoodOffer,
        order_models.Order.food_offer_id == food_offer_models.FoodOffer.id
    ).filter(order_models.Order.customer_id == current_user.id).all()

    meals_saved = sum(order.quantity for order, _ in customer_orders)

    return {
        "name": display_name,
        "meals_saved": meals_saved,
        "nearby_restaurants": nearby_restaurants
    }


class BusinessProfileResponse(BaseModel):
    name: str
    email: str
    active_offer_count: int
    total_orders: int
    total_revenue: int
    preferences: List[str] = []

class BusinessDealSummary(BaseModel):
    emoji: str
    title: str
    sub: str
    status: str

class BusinessOrderSummary(BaseModel):
    emoji: str
    title: str
    sub: str
    status: str

class BusinessDashboardResponse(BaseModel):
    daily_meals_sold: int
    daily_revenue: int
    total_orders: int
    active_offers: int
    live_orders: List[BusinessOrderSummary]
    active_deals: List[BusinessDealSummary]


# --- BUSINESS ENDPOINTS ---

@app.get("/business/me/profile", response_model=BusinessProfileResponse)
def get_business_profile(
    current_business: user_models.User = Depends(security.get_current_business_user),
    db: Session = Depends(get_db)
):
    active_offers = db.query(food_offer_models.FoodOffer).filter(
        food_offer_models.FoodOffer.business_id == current_business.id,
        food_offer_models.FoodOffer.is_active,
        food_offer_models.FoodOffer.quantity_available > 0
    ).count()

    orders = db.query(order_models.Order, food_offer_models.FoodOffer).join(
        food_offer_models.FoodOffer,
        order_models.Order.food_offer_id == food_offer_models.FoodOffer.id
    ).filter(food_offer_models.FoodOffer.business_id == current_business.id).all()

    total_orders = len(orders)
    total_revenue = sum(offer.discounted_price * order.quantity for order, offer in orders)

    return {
        "name": current_business.email.split("@")[0].capitalize(),
        "email": current_business.email,
        "active_offer_count": active_offers,
        "total_orders": total_orders,
        "total_revenue": total_revenue,
        "preferences": current_business.preferences or []
    }


@app.get("/business/me/dashboard", response_model=BusinessDashboardResponse)
def get_business_dashboard(
    current_business: user_models.User = Depends(security.get_current_business_user),
    db: Session = Depends(get_db)
):
    all_business_orders = db.query(order_models.Order, food_offer_models.FoodOffer).join(
        food_offer_models.FoodOffer,
        order_models.Order.food_offer_id == food_offer_models.FoodOffer.id
    ).filter(food_offer_models.FoodOffer.business_id == current_business.id).all()

    today = date.today()
    daily_orders = [
        (order, offer)
        for order, offer in all_business_orders
        if order.created_at.date() == today
    ]

    def build_order_summary(order, offer):
        return {
            "emoji": offer.title[0] if offer.title else "🍽️",
            "title": offer.title,
            "sub": f"{order.quantity} × ₸{offer.discounted_price}",
            "status": "New" if order.status == "PENDING" else order.status.capitalize(),
        }

    live_orders = [
        build_order_summary(order, offer)
        for order, offer in all_business_orders
        if order.status in {"PENDING", "READY"}
    ][:6]

    active_offers_query = db.query(food_offer_models.FoodOffer).filter(
        food_offer_models.FoodOffer.business_id == current_business.id,
        food_offer_models.FoodOffer.is_active,
        food_offer_models.FoodOffer.quantity_available > 0
    ).all()

    active_deals = [
        {
            "emoji": offer.title[0] if offer.title else "🍽️",
            "title": offer.title,
            "sub": f"{offer.quantity_available} left • ₸{offer.discounted_price}",
            "status": "Live",
        }
        for offer in active_offers_query
    ]

    return {
        "daily_meals_sold": sum(order.quantity for order, _ in daily_orders),
        "daily_revenue": sum(offer.discounted_price * order.quantity for order, offer in daily_orders),
        "total_orders": len(all_business_orders),
        "active_offers": db.query(food_offer_models.FoodOffer).filter(
            food_offer_models.FoodOffer.business_id == current_business.id,
            food_offer_models.FoodOffer.is_active,
            food_offer_models.FoodOffer.quantity_available > 0
        ).count(),
        "live_orders": live_orders,
        "active_deals": active_deals,
    }


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