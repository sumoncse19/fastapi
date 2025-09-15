from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from src.database import get_db
from src.posts.schemas import BlogPost, BlogPostCreate, BlogPostUpdate
from src.posts import service

router = APIRouter()

@router.get("/", response_model=List[BlogPost])
async def get_all_posts(
    skip: int = Query(0, ge=0, description="Number of posts to skip"),
    limit: int = Query(100, ge=1, le=100, description="Number of posts to return"),
    published_only: bool = Query(False, description="Show only published posts"),
    db: Session = Depends(get_db)
):
    """Get all blog posts with pagination"""
    posts = service.get_blog_posts(db, skip=skip, limit=limit, published_only=published_only)
    return posts

@router.get("/{post_id}", response_model=BlogPost)
async def get_post(post_id: int, db: Session = Depends(get_db)):
    """Get a specific blog post by ID"""
    post = service.get_blog_post(db, post_id=post_id)
    if post is None:
        raise HTTPException(status_code=404, detail="Blog post not found")
    return post

@router.post("/", response_model=BlogPost, status_code=201)
async def create_post(post: BlogPostCreate, db: Session = Depends(get_db)):
    """Create a new blog post"""
    return service.create_blog_post(db=db, post=post)

@router.put("/{post_id}", response_model=BlogPost)
async def update_post(
    post_id: int, 
    post_update: BlogPostUpdate, 
    db: Session = Depends(get_db)
):
    """Update a blog post"""
    post = service.update_blog_post(db=db, post_id=post_id, post_update=post_update)
    if post is None:
        raise HTTPException(status_code=404, detail="Blog post not found")
    return post

@router.delete("/{post_id}")
async def delete_post(post_id: int, db: Session = Depends(get_db)):
    """Delete a blog post"""
    success = service.delete_blog_post(db=db, post_id=post_id)
    if not success:
        raise HTTPException(status_code=404, detail="Blog post not found")
    return {"message": "Blog post deleted successfully"}
