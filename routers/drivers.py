from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from starlette import status

from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, User, Trip, Driver
from schemas.driver import DriverResponse, LatitudeLongitudeRequestBody
from schemas.user import UserResponse, UserCreate, UserUpdate
from schemas.user import UserCreate

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


@router.get("/in-user_table", response_model=list[DriverResponse])
async def list_drivers_in_user_table(db: Session = Depends(get_db)):
    drivers = db.query(User).filter(User.user_type == "driver").all()
    return drivers


@router.get("", response_model=list[DriverResponse])
async def list_drivers(db: Session = Depends(get_db)):
    drivers = db.query(Driver).all()
    return drivers


@router.post("", response_model=str)
async def create_driver(user_id: int, db: Session = Depends(get_db)):
    # Check if the user_id already exists in the Driver table
    existing_driver = db.query(Driver).filter(Driver.user_id == user_id).first()

    if existing_driver:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Driver entry already exists for this user",
        )

    # Create a new driver in the database
    new_driver = (
        db.query(User).filter(User.id == user_id, User.user_type == "driver").first()
    )

    if not new_driver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found or not a driver",
        )

    # Create a new driver entry
    driver_entry = Driver(user_id=user_id)
    db.add(driver_entry)
    db.commit()
    db.refresh(driver_entry)

    return "User", new_driver.id, "became a driver."


async def auto_create_driver(user_id: int, db: Session = Depends(get_db)):
    driver_entry = Driver(user_id=user_id, available=True)
    # print(driver_entry.user, driver_entry.user_id)
    db.add(driver_entry)
    db.commit()
    db.refresh(driver_entry)


@router.post(
    "/refresh",
    response_model=list[DriverResponse],
    description="Reset the drivers table and re-add users " "with user_type 'driver'.",
)
async def refresh_drivers(db: Session = Depends(get_db)):
    # Step 1: Delete all existing drivers
    db.query(Driver).delete()
    db.commit()

    # Step 2: Get all users with user_type 'driver'
    drivers = db.query(User).filter(User.user_type == "driver").all()

    # Step 3: Create new driver objects for each user
    new_drivers = []
    for driver in drivers:
        new_driver = Driver(user_id=driver.id, available=False)
        db.add(new_driver)

        # Update this part to handle the potential None value for new_driver.id
        new_drivers.append(
            DriverResponse(
                user_id=new_driver.user_id,
                available=new_driver.available,
                current_trip=0,
            )
        )

    # Step 4: Commit the changes to the database
    db.commit()

    # Step 5: Return the newly created drivers
    return new_drivers


@router.post("/{user_id}/availability/{availability}", response_model=DriverResponse)
async def change_driver_availability(
        user_id: int, availability: bool, db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(Driver.user_id == user_id).first()
    if driver is None:
        raise HTTPException(status_code=404, detail="Driver not found")
    driver.available = availability
    db.add(driver)
    db.commit()
    db.refresh(driver)
    return driver


@router.post("/{user_id}/add-trip/{trip_id}", response_model=DriverResponse)
async def change_current_trip(
        user_id: int, trip_id: int, db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(Driver.user_id == user_id).first()
    if driver is None:
        raise HTTPException(status_code=404, detail="Driver not found")
    driver.current_trip = trip_id
    db.add(driver)
    db.commit()
    db.refresh(driver)
    return driver


@router.get("/available-drivers", response_model=DriverResponse)
async def discover_available_drivers(db: Session = Depends(get_db)):
    driver = db.query(Driver).filter(Driver.available == True).first()
    if driver is None:
        raise HTTPException(status_code=404, detail="No Drivers are Available")
    return driver


@router.put("/location/{driver_id}/{latitude}/{longitude}", response_model=DriverResponse)
async def update_driver_location(
        driver_id: int, latitude: float, longitude: float, db: Session = Depends(get_db)
):
    driver_to_update = db.query(Driver).filter(Driver.id == driver_id).first()

    if driver_to_update:
        driver_to_update.current_location_latitude = latitude
        driver_to_update.current_location_longitude = longitude

        db.commit()
        db.refresh(driver_to_update)
        return driver_to_update
    else:
        raise HTTPException(
            status_code=404, detail=f"Driver with ID {driver_id} not found"
        )


@router.get("/location/{driver_id}", response_model=DriverResponse)
async def get_driver_location(
        driver_id: int, db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(Driver.id == driver_id).first()
    if driver:
        return driver
    else:
        raise HTTPException(
            status_code=404, detail=f"Driver with ID {driver_id} not found"
        )

