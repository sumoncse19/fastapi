from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.config import settings
from src.database import engine, Base

# Import models to register with Base
from src.users.models import User
from src.meals.models import Meal

# Import routers
from src.users.router import router as auth_router
from src.meals.router import router as meals_router

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.APP_TITLE,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
)

# Configure CORS for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "Welcome to DailyBite - AI-powered food photo calorie tracker", 
        "status": "running",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT
    }

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "version": settings.APP_VERSION
    }

# Include routers
app.include_router(auth_router, prefix="/auth", tags=["authentication"])
app.include_router(meals_router, prefix="/api", tags=["meals"])

# Legacy endpoints (can be removed later)
# from src.posts.router import router as posts_router
# from src.partners.router import router as partners_router
# app.include_router(posts_router, prefix="/posts", tags=["posts"])
# app.include_router(partners_router, prefix="/partners", tags=["partners"])
