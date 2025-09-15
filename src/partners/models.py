from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from src.database import Base

class Partner(Base):
    __tablename__ = "partners"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    company = Column(String(200), nullable=False)
    phone = Column(String(20), nullable=True)
    website = Column(String(255), nullable=True)
    active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
