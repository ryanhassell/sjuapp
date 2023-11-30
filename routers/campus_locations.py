from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, CampusLocation, CampusLocation
from schemas.campus_location import CampusEnum
from schemas.campus_location import (
    CampusLocationResponse,
    CampusLocationCreate,
    CampusLocationUpdate,
)
from schemas.campus_location import CampusLocationCreate

# Define your connection string
conn_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
engine = create_engine(conn_string)
Base.metadata.create_all(bind=engine)

# Use the create_engine function to establish the connection
engine = create_engine(conn_string)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

router = APIRouter()


# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("", response_model=list[CampusLocationResponse])
async def list_campus_locations(
    skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    # Use SQLAlchemy query to fetch campus_locations
    campus_locations = db.query(CampusLocation).offset(skip).limit(limit).all()
    return campus_locations


@router.get("/{campus_location_id}", response_model=CampusLocationResponse)
async def get_campus_location(campus_location_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single campus_location by ID
    campus_location = (
        db.query(CampusLocation).filter(CampusLocation.id == campus_location_id).first()
    )
    if campus_location is None:
        raise HTTPException(status_code=404, detail="CampusLocation not found")
    return campus_location


@router.post("", response_model=CampusLocationResponse)
async def create_campus_location(
    campus_location: CampusLocationCreate, db: Session = Depends(get_db)
):
    # Create a new campus_location in the database
    new_campus_location = CampusLocation(**campus_location.dict())
    db.add(new_campus_location)
    db.commit()
    db.refresh(new_campus_location)
    return new_campus_location


@router.delete("/{campus_location_id}", response_model=str)
async def delete_campus_location(
    campus_location_id: int, db: Session = Depends(get_db)
):
    # Retrieve the CampusLocation object by its ID
    campus_location_to_delete = (
        db.query(CampusLocation).filter(CampusLocation.id == campus_location_id).first()
    )

    if campus_location_to_delete:
        # Delete the CampusLocation object
        db.delete(campus_location_to_delete)
        db.commit()
        return f"CampusLocation {campus_location_id} successfully deleted."
    else:
        raise HTTPException(
            status_code=404,
            detail=f"CampusLocation with ID {campus_location_id} not found",
        )


@router.put("/{campus_location_id}", response_model=CampusLocationResponse)
async def update_campus_location(
    campus_location_name: int,
    campus: CampusEnum,
    campus_location_data: CampusLocationUpdate,
    db: Session = Depends(get_db),
):
    # Retrieve the CampusLocation object by its ID
    campus_location_to_update = (
        db.query(CampusLocation)
        .filter(
            CampusLocation.name == campus_location_name
            and CampusLocation.campus == campus
        )
        .first()
    )

    if campus_location_to_update:
        # Update the CampusLocation object with the new data
        for field, value in campus_location_data.dict().items():
            setattr(campus_location_to_update, field, value)

        db.commit()
        db.refresh(campus_location_to_update)
        return campus_location_to_update
    else:
        raise HTTPException(
            status_code=404,
            detail=f"Campus Location {campus_location_name} not found in the {campus} campus",
        )
