from sqlalchemy.orm import Session
from src.posts.models import BlogPost as DBBlogPost
from src.posts.schemas import BlogPostCreate, BlogPostUpdate
from typing import Optional

def get_blog_post(db: Session, post_id: int):
    return db.query(DBBlogPost).filter(DBBlogPost.id == post_id).first()

def get_blog_posts(db: Session, skip: int = 0, limit: int = 100, published_only: bool = False):
    query = db.query(DBBlogPost)
    if published_only:
        query = query.filter(DBBlogPost.published == True)
    return query.offset(skip).limit(limit).all()

def create_blog_post(db: Session, post: BlogPostCreate):
    db_post = DBBlogPost(
        title=post.title,
        content=post.content,
        published=post.published
    )
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    return db_post

def update_blog_post(db: Session, post_id: int, post_update: BlogPostUpdate):
    db_post = db.query(DBBlogPost).filter(DBBlogPost.id == post_id).first()
    if db_post:
        update_data = post_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_post, field, value)
        db.commit()
        db.refresh(db_post)
    return db_post

def delete_blog_post(db: Session, post_id: int):
    db_post = db.query(DBBlogPost).filter(DBBlogPost.id == post_id).first()
    if db_post:
        db.delete(db_post)
        db.commit()
        return True
    return False
