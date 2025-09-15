from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from src.partners.models import Partner as DBPartner
from src.partners.schemas import PartnerCreate, PartnerPatch
from typing import Optional

def get_partner(db: Session, partner_id: int):
    return db.query(DBPartner).filter(DBPartner.id == partner_id).first()

def get_partner_by_email(db: Session, email: str):
    return db.query(DBPartner).filter(DBPartner.email == email).first()

def get_partners(db: Session, skip: int = 0, limit: int = 100, active_only: bool = False):
    query = db.query(DBPartner)
    if active_only:
        query = query.filter(DBPartner.active == True)
    return query.offset(skip).limit(limit).all()

def create_partner(db: Session, partner: PartnerCreate):
    db_partner = DBPartner(
        name=partner.name,
        email=partner.email,
        company=partner.company,
        phone=partner.phone,
        website=partner.website,
        active=partner.active
    )
    try:
        db.add(db_partner)
        db.commit()
        db.refresh(db_partner)
        return db_partner
    except IntegrityError:
        db.rollback()
        return None

def patch_partner(db: Session, partner_id: int, partner_patch: PartnerPatch):
    db_partner = db.query(DBPartner).filter(DBPartner.id == partner_id).first()
    if db_partner:
        patch_data = partner_patch.dict(exclude_unset=True)
        for field, value in patch_data.items():
            setattr(db_partner, field, value)
        try:
            db.commit()
            db.refresh(db_partner)
            return db_partner
        except IntegrityError:
            db.rollback()
            return None
    return None

def delete_partner(db: Session, partner_id: int):
    db_partner = db.query(DBPartner).filter(DBPartner.id == partner_id).first()
    if db_partner:
        db.delete(db_partner)
        db.commit()
        return True
    return False
