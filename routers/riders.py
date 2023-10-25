from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, Rider
from schemas.rider import RiderResponse, RiderCreate, RiderUpdate
from schemas.rider import RiderCreate

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


@router.get("", response_model=list[RiderResponse])
async def list_riders(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch riders
    riders = db.query(Rider).offset(skip).limit(limit).all()
    return riders


@router.get("/{rider_id}", response_model=RiderResponse)
async def get_rider(rider_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single rider by ID
    rider = db.query(Rider).filter(Rider.id == rider_id).first()
    if rider is None:
        raise HTTPException(status_code=404, detail="Rider not found")
    return rider


@router.post("", response_model=RiderResponse)
async def create_rider(rider: RiderCreate, db: Session = Depends(get_db)):
    # Create a new rider in the database
    new_rider = Rider(**rider.dict())
    db.add(new_rider)
    db.commit()
    db.refresh(new_rider)
    return new_rider


@router.delete("/{rider_id}", response_model=str)
async def delete_rider(rider_id: int, db: Session = Depends(get_db)):
    # Retrieve the Rider object by its ID
    rider_to_delete = db.query(Rider).filter(Rider.id == rider_id).first()

    if rider_to_delete:
        # Delete the Rider object
        db.delete(rider_to_delete)
        db.commit()
        return f"Rider {rider_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Rider with ID {rider_id} not found")


@router.put("/{rider_id}", response_model=RiderResponse)
async def update_rider(rider_id: int, rider_data: RiderUpdate, db: Session = Depends(get_db)):
    # Retrieve the Rider object by its ID
    rider_to_update = db.query(Rider).filter(Rider.id == rider_id).first()

    if rider_to_update:
        # Update the Rider object with the new data
        for field, value in rider_data.dict().items():
            setattr(rider_to_update, field, value)

        db.commit()
        db.refresh(rider_to_update)
        return rider_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Rider with ID {rider_id} not found")
