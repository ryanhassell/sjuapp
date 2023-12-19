from typing import List

from fastapi import HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Trip, Base, Driver
from routers.drivers import change_driver_availability
from schemas.trip import (
    TripResponse,
    TripCreate,
    TripUpdate,
    TripStatusResponse,
    TripCreateResponse,
)

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


@router.get("", response_model=list[TripResponse])
async def list_trips(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch trips
    trips = db.query(Trip).offset(skip).limit(limit).all()
    return trips


@router.get("/by-user/{user_id}", response_model=list[TripResponse])
async def list_trips_by_passenger_id(
        user_id: int, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    # Use SQLAlchemy query to fetch trips with a certain passenger
    trips = (
        db.query(Trip)
        .filter(Trip.passengers.any(user_id))
        .offset(skip)
        .limit(limit)
        .all()
    )
    return trips


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(trip_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single trip by ID
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if trip is None:
        raise HTTPException(status_code=404, detail="Trip not found")
    return trip


@router.post("", response_model=TripCreateResponse)
async def create_trip(trip: TripCreate, db: Session = Depends(get_db)):
    # Create a new trip in the database
    new_trip = Trip(**trip.dict())

    # Find an available driver
    assigned_driver = db.query(Driver).filter(Driver.available == True).first()

    if assigned_driver:
        new_trip.driver = assigned_driver.id
        assigned_driver.available = False
        assigned_driver.current_trip = new_trip.id
        db.add(assigned_driver)
        new_trip.trip_status = "current"
        db.add(new_trip)
        db.commit()
        db.refresh(new_trip)
        return new_trip
    else:
        new_trip.trip_status = "no_driver"
        new_trip.driver = 0
        db.add(new_trip)
        db.commit()
        db.refresh(new_trip)
        return new_trip


@router.delete("/{trip_id}", response_model=str)
async def delete_trip(trip_id: int, db: Session = Depends(get_db)):
    # Retrieve the Trip object by its ID
    trip_to_delete = db.query(Trip).filter(Trip.id == trip_id).first()
    if trip_to_delete:
        # Delete the Trip object
        db.delete(trip_to_delete)
        db.commit()
        return f"Trip {trip_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Trip with ID {trip_id} not found")


@router.put("/{trip_id}", response_model=TripResponse)
async def update_trip(
        trip_id: int, trip_data: TripUpdate, db: Session = Depends(get_db)
):
    # Retrieve the Trip object by its ID
    trip_to_update = db.query(Trip).filter(Trip.id == trip_id).first()

    if trip_to_update:
        # Update the Trip object with the new data
        for field, value in trip_data.dict().items():
            setattr(trip_to_update, field, value)

        db.commit()
        db.refresh(trip_to_update)
        return trip_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Trip with ID {trip_id} not found")


@router.put("/{trip_id}/status", response_model=TripStatusResponse)
async def update_trip_status(
        trip_id: int, trip_data: TripStatusResponse, db: Session = Depends(get_db)
):
    # Retrieve the Trip object by its ID
    trip_to_update = db.query(Trip).filter(Trip.id == trip_id).first()

    if trip_to_update:
        # Update the Trip object with the new data
        for field, value in trip_data.dict().items():
            setattr(trip_to_update, field, value)

        db.commit()
        db.refresh(trip_to_update)
        return trip_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Trip with ID {trip_id} not found")


@router.get("/current-trips/{user_id}", response_model=TripResponse)
async def list_trips_by_passenger_id(
        user_id: int, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    # Use SQLAlchemy query to fetch trips with a certain passenger
    trips = (
        db.query(Trip)
        .filter(Trip.passengers.any(user_id), Trip.trip_status == "current")
        .offset(skip)
        .limit(limit)
        .first()
    )
    return trips


@router.get("/current-trips-by-driver/{user_id}", response_model=TripResponse)
async def list_trips_by_driver(
        user_id: int, skip: int = 0, limit: int = 10, db: Session = Depends(get_db)
):
    # Use SQLAlchemy query to fetch trips with a certain passenger
    trips = (
        db.query(Trip)
        .filter(Trip.driver == user_id, Trip.trip_status == "current")
        .offset(skip)
        .limit(limit)
        .first()
    )
    return trips


@router.get("/no-drivers", response_model=List[TripResponse])
async def list_trips_with_no_driver(db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch trips with a certain passenger
    trips = db.query(Trip).filter(Trip.trip_status == "no_driver")
    return trips


@router.put("/complete/{trip_id}", response_model=TripResponse)
async def complete_trip(
        trip_id: int, db: Session = Depends(get_db)
):
    # Retrieve the Trip object by its ID
    trip_to_update = db.query(Trip).filter(Trip.id == trip_id).first()
    trip_to_update.trip_status = "completed"
    await change_driver_availability(user_id=trip_to_update.driver, availability=True, db=db)
    db.commit()
    db.refresh(trip_to_update)
    return trip_to_update
