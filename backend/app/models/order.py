from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    quantity = Column(Integer, nullable=False, default=1)
    status = Column(String, nullable=False, default="PENDING")  # PENDING, COMPLETED, CANCELLED
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Foreign Keys
    customer_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    food_offer_id = Column(Integer, ForeignKey("food_offers.id", ondelete="CASCADE"), nullable=False)