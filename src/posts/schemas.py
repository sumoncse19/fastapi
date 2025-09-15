from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class BlogPostBase(BaseModel):
    title: str
    content: str
    published: bool = True

class BlogPostCreate(BlogPostBase):
    pass

class BlogPostUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    published: Optional[bool] = None

class BlogPost(BlogPostBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
