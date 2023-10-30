from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, Vehicle
from schemas.vehicle import VehicleResponse, VehicleCreate, VehicleUpdate
from schemas.vehicle import VehicleCreate

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


@router.get("", response_model=list[VehicleResponse])
async def list_vehicles(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch vehicles
    vehicles = db.query(Vehicle).offset(skip).limit(limit).all()
    return vehicles


@router.get("/{vehicle_id}", response_model=VehicleResponse)
async def get_vehicle(vehicle_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single vehicle by ID
    vehicle = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()
    if vehicle is None:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle


@router.post("", response_model=VehicleResponse)
async def create_vehicle(vehicle: VehicleCreate, db: Session = Depends(get_db)):
    # Create a new vehicle in the database
    new_vehicle = Vehicle(**vehicle.dict())
    db.add(new_vehicle)
    db.commit()
    db.refresh(new_vehicle)
    return new_vehicle


@router.delete("/{vehicle_id}", response_model=str)
async def delete_vehicle(vehicle_id: int, db: Session = Depends(get_db)):
    # Retrieve the Vehicle object by its ID
    vehicle_to_delete = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()

    if vehicle_to_delete:
        # Delete the Vehicle object
        db.delete(vehicle_to_delete)
        db.commit()
        return f"Vehicle {vehicle_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Vehicle with ID {vehicle_id} not found")


@router.put("/{vehicle_id}", response_model=VehicleResponse)
async def update_vehicle(vehicle_id: int, vehicle_data: VehicleUpdate, db: Session = Depends(get_db)):
    # Retrieve the Vehicle object by its ID
    vehicle_to_update = db.query(Vehicle).filter(Vehicle.id == vehicle_id).first()

    if vehicle_to_update:
        # Update the Vehicle object with the new data
        for field, value in vehicle_data.dict().items():
            setattr(vehicle_to_update, field, value)

        db.commit()
        db.refresh(vehicle_to_update)
        return vehicle_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Vehicle with ID {vehicle_id} not found")
