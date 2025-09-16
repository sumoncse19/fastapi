from typing import List, Optional
from datetime import datetime, date
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from fastapi import HTTPException, status
from src.meals.models import Meal, MealStatus
from src.meals.schemas import MealCreate, MealUpdate, DailySummary, FoodItem
from src.users.models import User
import random
import json

# Mock AI food recognition service
class MockFoodRecognitionService:
    """Mock service for food recognition during development"""
    
    MOCK_FOODS = [
        {"name": "grilled chicken breast", "calories_per_100g": 165, "typical_portion": 150},
        {"name": "white rice", "calories_per_100g": 130, "typical_portion": 200},
        {"name": "mixed salad", "calories_per_100g": 20, "typical_portion": 100},
        {"name": "apple", "calories_per_100g": 52, "typical_portion": 180},
        {"name": "banana", "calories_per_100g": 89, "typical_portion": 120},
        {"name": "pasta", "calories_per_100g": 131, "typical_portion": 200},
        {"name": "pizza slice", "calories_per_100g": 266, "typical_portion": 100},
        {"name": "burger", "calories_per_100g": 295, "typical_portion": 250},
        {"name": "french fries", "calories_per_100g": 365, "typical_portion": 150},
        {"name": "sushi roll", "calories_per_100g": 200, "typical_portion": 120},
    ]
    
    @classmethod
    def analyze_image(cls, image_path: str) -> dict:
        """Mock image analysis that returns random food items"""
        # Randomly select 1-3 food items
        num_items = random.randint(1, 3)
        selected_foods = random.sample(cls.MOCK_FOODS, num_items)
        
        items = []
        total_calories = 0
        
        for food in selected_foods:
            # Calculate calories based on typical portion
            calories = int((food["calories_per_100g"] * food["typical_portion"]) / 100)
            confidence = round(random.uniform(0.7, 0.95), 2)
            
            item = {
                "name": food["name"],
                "calories": calories,
                "confidence": confidence,
                "portion_label": random.choice(["small", "medium", "large"])
            }
            items.append(item)
            total_calories += calories
        
        # Overall confidence is average of individual confidences
        overall_confidence = round(sum(item["confidence"] for item in items) / len(items), 2)
        
        return {
            "items": items,
            "total_calories": total_calories,
            "confidence": overall_confidence
        }

def create_meal_from_photo(db: Session, user_id: int, image_path: str) -> Meal:
    """Create a meal from uploaded photo analysis"""
    # Analyze the image using mock service
    analysis_result = MockFoodRecognitionService.analyze_image(image_path)
    
    # Create meal record
    meal = Meal(
        user_id=user_id,
        estimated_calories=analysis_result["total_calories"],
        items_json=analysis_result["items"],
        confidence=analysis_result["confidence"],
        status=MealStatus.PENDING.value,
        thumbnail_url=image_path  # In production, this would be processed/resized
    )
    
    db.add(meal)
    db.commit()
    db.refresh(meal)
    return meal

def confirm_meal(db: Session, meal_id: int, user_id: int, meal_update: MealUpdate) -> Meal:
    """Confirm or reject a meal"""
    meal = db.query(Meal).filter(
        and_(Meal.id == meal_id, Meal.user_id == user_id)
    ).first()
    
    if not meal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Meal not found"
        )
    
    meal.status = meal_update.action.value
    if meal_update.notes:
        meal.notes = meal_update.notes
    
    db.commit()
    db.refresh(meal)
    return meal

def get_user_meals(db: Session, user_id: int, limit: int = 10, offset: int = 0) -> List[Meal]:
    """Get user's meals with pagination"""
    return db.query(Meal).filter(Meal.user_id == user_id).order_by(
        Meal.timestamp.desc()
    ).offset(offset).limit(limit).all()

def get_user_meals_by_date(db: Session, user_id: int, target_date: date) -> List[Meal]:
    """Get user's meals for a specific date"""
    start_of_day = datetime.combine(target_date, datetime.min.time())
    end_of_day = datetime.combine(target_date, datetime.max.time())
    
    return db.query(Meal).filter(
        and_(
            Meal.user_id == user_id,
            Meal.timestamp >= start_of_day,
            Meal.timestamp <= end_of_day
        )
    ).order_by(Meal.timestamp.desc()).all()

def get_daily_summary(db: Session, user_id: int, target_date: date) -> DailySummary:
    """Get daily calorie summary for a specific date"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Get meals for the specific date where status is 'eat'
    start_of_day = datetime.combine(target_date, datetime.min.time())
    end_of_day = datetime.combine(target_date, datetime.max.time())
    
    meals = db.query(Meal).filter(
        and_(
            Meal.user_id == user_id,
            Meal.timestamp >= start_of_day,
            Meal.timestamp <= end_of_day,
            Meal.status == MealStatus.EAT.value
        )
    ).order_by(Meal.timestamp.desc()).all()
    
    # Calculate consumed calories
    consumed = sum(meal.estimated_calories for meal in meals)
    
    # Get all meals for the day (including not eaten for history)
    all_meals = db.query(Meal).filter(
        and_(
            Meal.user_id == user_id,
            Meal.timestamp >= start_of_day,
            Meal.timestamp <= end_of_day
        )
    ).order_by(Meal.timestamp.desc()).all()
    
    return DailySummary(
        date=target_date,
        goal=user.calorie_goal,
        consumed=consumed,
        remaining=max(0, user.calorie_goal - consumed),
        meals=all_meals
    )

def delete_meal(db: Session, meal_id: int, user_id: int) -> bool:
    """Delete a meal"""
    meal = db.query(Meal).filter(
        and_(Meal.id == meal_id, Meal.user_id == user_id)
    ).first()
    
    if not meal:
        return False
    
    db.delete(meal)
    db.commit()
    return True
