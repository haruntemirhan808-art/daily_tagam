from pydantic import BaseModel
from datetime import datetime

class FoodOfferCreate(BaseModel):
    title: str
    original_price: int
    discounted_price: int
    quantity_available: int
    pickup_time: str

class FoodOfferResponse(FoodOfferCreate):
    id: int
    business_id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True