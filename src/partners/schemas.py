from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

class PartnerBase(BaseModel):
    name: str
    email: EmailStr
    company: str
    phone: Optional[str] = None
    website: Optional[str] = None
    active: bool = True

class PartnerCreate(PartnerBase):
    pass

class PartnerPatch(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    company: Optional[str] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    active: Optional[bool] = None

class Partner(PartnerBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
