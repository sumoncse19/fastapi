from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from src.database import get_db
from src.partners.schemas import Partner, PartnerCreate, PartnerPatch
from src.partners import service

router = APIRouter()

@router.get("/", response_model=List[Partner])
async def get_all_partners(
    skip: int = Query(0, ge=0, description="Number of partners to skip"),
    limit: int = Query(100, ge=1, le=100, description="Number of partners to return"),
    active_only: bool = Query(False, description="Show only active partners"),
    db: Session = Depends(get_db)
):
    """Get all partners with pagination"""
    partners = service.get_partners(db, skip=skip, limit=limit, active_only=active_only)
    return partners

@router.get("/{partner_id}", response_model=Partner)
async def get_partner_by_id(partner_id: int, db: Session = Depends(get_db)):
    """Get a specific partner by ID"""
    partner = service.get_partner(db, partner_id=partner_id)
    if partner is None:
        raise HTTPException(status_code=404, detail="Partner not found")
    return partner

@router.get("/email/{email}", response_model=Partner)
async def get_partner_by_email_endpoint(email: str, db: Session = Depends(get_db)):
    """Get a partner by email address"""
    partner = service.get_partner_by_email(db, email=email)
    if partner is None:
        raise HTTPException(status_code=404, detail="Partner not found")
    return partner

@router.post("/", response_model=Partner, status_code=201)
async def create_new_partner(partner: PartnerCreate, db: Session = Depends(get_db)):
    """Create a new partner"""
    # Check if email already exists
    existing_partner = service.get_partner_by_email(db, email=partner.email)
    if existing_partner:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    db_partner = service.create_partner(db=db, partner=partner)
    if db_partner is None:
        raise HTTPException(status_code=400, detail="Failed to create partner")
    return db_partner

@router.patch("/{partner_id}", response_model=Partner)
async def patch_partner_by_id(
    partner_id: int, 
    partner_patch: PartnerPatch, 
    db: Session = Depends(get_db)
):
    """Partially update a partner using PATCH"""
    # Check if partner exists
    existing_partner = service.get_partner(db, partner_id=partner_id)
    if existing_partner is None:
        raise HTTPException(status_code=404, detail="Partner not found")
    
    # Check if email is being updated and if it already exists
    if partner_patch.email and partner_patch.email != existing_partner.email:
        email_exists = service.get_partner_by_email(db, email=partner_patch.email)
        if email_exists:
            raise HTTPException(status_code=400, detail="Email already registered")
    
    updated_partner = service.patch_partner(db=db, partner_id=partner_id, partner_patch=partner_patch)
    if updated_partner is None:
        raise HTTPException(status_code=400, detail="Failed to update partner")
    return updated_partner

@router.delete("/{partner_id}")
async def delete_partner_by_id(partner_id: int, db: Session = Depends(get_db)):
    """Delete a partner"""
    success = service.delete_partner(db=db, partner_id=partner_id)
    if not success:
        raise HTTPException(status_code=404, detail="Partner not found")
    return {"message": "Partner deleted successfully"}
