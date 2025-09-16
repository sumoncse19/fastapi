from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional, List
from enum import Enum

class MealStatus(str, Enum):
    PENDING = "pending"
    EAT = "eat"
    NOT_EAT = "not_eat"

class FoodItem(BaseModel):
    name: str
    calories: int
    confidence: float = Field(ge=0.0, le=1.0)
    portion_label: str = "medium"

class PhotoAnalysisResult(BaseModel):
    id: int
    estimated_calories: int
    items: List[FoodItem]
    confidence: float = Field(ge=0.0, le=1.0)

class MealBase(BaseModel):
    estimated_calories: int = Field(ge=0)
    items_json: Optional[List[FoodItem]] = None
    notes: Optional[str] = None

class MealCreate(MealBase):
    pass

class MealUpdate(BaseModel):
    status: MealStatus
    notes: Optional[str] = None

class MealResponse(MealBase):
    id: int
    user_id: int
    timestamp: datetime
    status: MealStatus
    thumbnail_url: Optional[str] = None
    confidence: float
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class DailySummary(BaseModel):
    date: date
    goal: int
    consumed: int
    remaining: int
    meals: List[MealResponse]
    
    @property
    def percentage_of_goal(self) -> float:
        return (self.consumed / self.goal * 100) if self.goal > 0 else 0.0

class MealConfirmation(BaseModel):
    action: MealStatus  # "eat" or "not_eat"
