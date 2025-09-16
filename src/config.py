from pydantic_settings import BaseSettings
from enum import Enum

class Environment(str, Enum):
    DEVELOPMENT = "development"
    PRODUCTION = "production"
    TESTING = "testing"

class Config(BaseSettings):
    DATABASE_URL: str = "postgresql://dailybite_user:dailybite_pass@localhost:5432/dailybite_db"
    SECRET_KEY: str = "dailybite-secret-key-for-development"
    
    ENVIRONMENT: Environment = Environment.DEVELOPMENT
    
    APP_VERSION: str = "1.0.0"
    APP_TITLE: str = "DailyBite API"
    APP_DESCRIPTION: str = "AI-powered food photo calorie tracker for mobile devices"
    
    # Database
    DB_ECHO: bool = False
    
    # JWT Configuration
    JWT_SECRET_KEY: str = "dailybite-jwt-secret-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_MINUTES: int = 30
    
    # File Upload Configuration
    MAX_FILE_SIZE: int = 10 * 1024 * 1024  # 10MB
    ALLOWED_IMAGE_TYPES: list[str] = ["image/jpeg", "image/png", "image/heic"]
    UPLOAD_DIRECTORY: str = "uploads"
    
    # AI Provider Configuration (for future integration)
    AI_PROVIDER: str = "mock"  # mock, openai, google, aws
    OPENAI_API_KEY: str = ""
    GOOGLE_VISION_API_KEY: str = ""
    
    # Privacy Settings
    AUTO_DELETE_IMAGES: bool = True
    IMAGE_RETENTION_HOURS: int = 24
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Config()
