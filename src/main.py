from fastapi import FastAPI
from src.config import settings
from src.database import engine
from src.posts.models import BlogPost  # Import to register with Base
from src.partners.models import Partner  # Import to register with Base
from src.database import Base
from src.posts.router import router as posts_router
from src.partners.router import router as partners_router

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.APP_TITLE,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION
)

@app.get("/")
async def root():
    return {
        "message": "Welcome to FastAPI Blog API with Best Practices Structures", 
        "status": "running",
        "version": settings.APP_VERSION
    }

# Include routers
app.include_router(posts_router, prefix="/posts", tags=["posts"])
app.include_router(partners_router, prefix="/partners", tags=["partners"])
