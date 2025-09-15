from pydantic_settings import BaseSettings
from enum import Enum

class Environment(str, Enum):
    DEVELOPMENT = "development"
    PRODUCTION = "production"
    TESTING = "testing"

class Config(BaseSettings):
    DATABASE_URL: str = "postgresql://dev_user:dev_pass@localhost:5432/dev_db"
    SECRET_KEY: str = "secret-key-for-development"
    
    ENVIRONMENT: Environment = Environment.DEVELOPMENT
    
    APP_VERSION: str = "1.0.0"
    APP_TITLE: str = "FastAPI API"
    APP_DESCRIPTION: str = "A simple API with CRUD operations for posts and partners"
    
    # Database
    DB_ECHO: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Config()
