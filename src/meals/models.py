from sqlalchemy import Column, Integer, String, DateTime, Boolean, Float, ForeignKey, Text, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum as PyEnum
from src.database import Base

class MealStatus(PyEnum):
    PENDING = "pending"
    EAT = "eat"
    NOT_EAT = "not_eat"

class Meal(Base):
    __tablename__ = "meals"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    estimated_calories = Column(Integer, nullable=False)
    items_json = Column(JSON)  # Store detected food items with details
    status = Column(String, default=MealStatus.PENDING.value)
    thumbnail_url = Column(String, nullable=True)  # Store image path if kept
    confidence = Column(Float, default=0.0)  # AI confidence score
    notes = Column(Text, nullable=True)  # User notes
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationship to user
    user = relationship("User", back_populates="meals")
    
    def __repr__(self):
        return f"<Meal(id={self.id}, user_id={self.user_id}, calories={self.estimated_calories}, status='{self.status}')>"

# Add relationship to User model
from src.users.models import User
User.meals = relationship("Meal", back_populates="user")
