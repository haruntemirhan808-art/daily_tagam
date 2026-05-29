from pydantic import BaseModel
from datetime import datetime

class OrderCreate(BaseModel):
    food_offer_id: int
    quantity: int = 1

class OrderResponse(BaseModel):
    id: int
    food_offer_id: int
    customer_id: int
    quantity: int
    status: str
    created_at: datetime

    class Config:
        from_attributes = True