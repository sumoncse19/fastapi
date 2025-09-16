from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from datetime import date, datetime
from typing import List, Optional
import os
import shutil
from pathlib import Path

from src.database import get_db
from src.users.router import get_current_user
from src.meals import service, schemas
from src.config import settings

router = APIRouter()

# Ensure upload directory exists
upload_dir = Path(settings.UPLOAD_DIRECTORY)
upload_dir.mkdir(exist_ok=True)

@router.post("/photos/upload", response_model=schemas.PhotoAnalysisResult)
async def upload_and_analyze_photo(
    file: UploadFile = File(...),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload food photo and get AI analysis"""
    
    # Validate file type
    if file.content_type not in settings.ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File type {file.content_type} not allowed. Allowed types: {settings.ALLOWED_IMAGE_TYPES}"
        )
    
    # Validate file size
    file_size = 0
    content = await file.read()
    file_size = len(content)
    
    if file_size > settings.MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File size {file_size} exceeds maximum allowed size {settings.MAX_FILE_SIZE}"
        )
    
    # Save uploaded file temporarily
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_extension = os.path.splitext(file.filename)[1] if file.filename else ".jpg"
    temp_filename = f"user_{current_user.id}_{timestamp}{file_extension}"
    temp_file_path = upload_dir / temp_filename
    
    try:
        # Save file
        with open(temp_file_path, "wb") as buffer:
            buffer.write(content)
        
        # Create meal from photo analysis
        meal = service.create_meal_from_photo(db, current_user.id, str(temp_file_path))
        
        # If auto-delete is enabled, remove the original file
        if current_user.auto_delete_images and settings.AUTO_DELETE_IMAGES:
            os.unlink(temp_file_path)
            meal.thumbnail_url = None  # Remove file reference
            db.commit()
        
        return schemas.PhotoAnalysisResult(
            id=meal.id,
            estimated_calories=meal.estimated_calories,
            items=meal.items_json,
            confidence=meal.confidence
        )
        
    except Exception as e:
        # Clean up temp file if something goes wrong
        if temp_file_path.exists():
            os.unlink(temp_file_path)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to process image"
        )

@router.post("/meals/{meal_id}/confirm", response_model=schemas.MealResponse)
async def confirm_meal(
    meal_id: int,
    confirmation: schemas.MealConfirmation,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Confirm whether to count the meal's calories (eat/not eat)"""
    meal_update = schemas.MealUpdate(
        status=confirmation.action,
        notes=None
    )
    
    meal = service.confirm_meal(db, meal_id, current_user.id, meal_update)
    return meal

@router.get("/meals", response_model=List[schemas.MealResponse])
async def get_meals(
    date: Optional[str] = Query(None, description="Filter meals by date (YYYY-MM-DD)"),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's meals with optional date filtering and pagination"""
    if date:
        # Parse date and get meals for specific date
        try:
            filter_date = datetime.strptime(date, "%Y-%m-%d").date()
            meals = service.get_user_meals_by_date(db, current_user.id, filter_date)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD")
    else:
        # Get all meals with pagination
        meals = service.get_user_meals(db, current_user.id, limit, offset)
    return meals

@router.get("/meals/{meal_id}", response_model=schemas.MealResponse)
async def get_meal(
    meal_id: int,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific meal"""
    meal = db.query(service.Meal).filter(
        service.and_(service.Meal.id == meal_id, service.Meal.user_id == current_user.id)
    ).first()
    
    if not meal:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Meal not found"
        )
    
    return meal

@router.delete("/meals/{meal_id}")
async def delete_meal(
    meal_id: int,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a meal"""
    deleted = service.delete_meal(db, meal_id, current_user.id)
    
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Meal not found"
        )
    
    return {"message": "Meal deleted successfully"}

@router.get("/users/{user_id}/summary", response_model=schemas.DailySummary)
async def get_daily_summary(
    user_id: int,
    date_param: Optional[str] = Query(None, alias="date"),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get daily calorie summary for a specific date"""
    
    # Users can only access their own summary
    if user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    # Parse date parameter or use today
    if date_param:
        try:
            target_date = datetime.strptime(date_param, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid date format. Use YYYY-MM-DD"
            )
    else:
        target_date = date.today()
    
    summary = service.get_daily_summary(db, current_user.id, target_date)
    return summary

@router.get("/summary", response_model=schemas.DailySummary)
async def get_my_daily_summary(
    date_param: Optional[str] = Query(None, alias="date"),
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current user's daily calorie summary"""
    
    # Parse date parameter or use today
    if date_param:
        try:
            target_date = datetime.strptime(date_param, "%Y-%m-%d").date()
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid date format. Use YYYY-MM-DD"
            )
    else:
        target_date = date.today()
    
    summary = service.get_daily_summary(db, current_user.id, target_date)
    return summary
