from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class FoodOffer(Base):
    __tablename__ = "food_offers"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    original_price = Column(Integer, nullable=False)
    discounted_price = Column(Integer, nullable=False)
    quantity_available = Column(Integer, nullable=False)
    pickup_time = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Foreign key pointing back to the business user
    business_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)