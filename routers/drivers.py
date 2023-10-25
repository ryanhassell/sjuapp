from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Driver, Base
from schemas.driver import DriverResponse, DriverCreate, DriverUpdate

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


@router.get("", response_model=list[DriverResponse])
async def list_drivers(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch drivers
    drivers = db.query(Driver).offset(skip).limit(limit).all()
    return drivers


@router.get("/{driver_id}", response_model=DriverResponse)
async def get_driver(driver_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single driver by ID
    driver = db.query(Driver).filter(Driver.id == driver_id).first()
    if driver is None:
        raise HTTPException(status_code=404, detail="Driver not found")
    return driver


@router.post("", response_model=DriverResponse)
async def create_driver(driver: DriverCreate, db: Session = Depends(get_db)):
    # Create a new driver in the database
    new_driver = Driver(**driver.dict())
    db.add(new_driver)
    db.commit()
    db.refresh(new_driver)
    return new_driver


@router.delete("/{driver_id}", response_model=str)
async def delete_driver(driver_id: int, db: Session = Depends(get_db)):
    # Retrieve the Driver object by its ID
    driver_to_delete = db.query(Driver).filter(Driver.id == driver_id).first()
    if driver_to_delete:
        # Delete the Driver object
        db.delete(driver_to_delete)
        db.commit()
        return f"Driver {driver_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Driver with ID {driver_id} not found")


@router.put("/{driver_id}", response_model=DriverResponse)
async def update_driver(driver_id: int, driver_data: DriverUpdate, db: Session = Depends(get_db)):
    # Retrieve the Driver object by its ID
    driver_to_update = db.query(Driver).filter(Driver.id == driver_id).first()

    if driver_to_update:
        # Update the Driver object with the new data
        for field, value in driver_data.dict().items():
            setattr(driver_to_update, field, value)

        db.commit()
        db.refresh(driver_to_update)
        return driver_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Driver with ID {driver_id} not found")
