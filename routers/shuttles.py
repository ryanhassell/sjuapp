from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, Shuttle
from schemas.shuttle import ShuttleResponse, ShuttleCreate, ShuttleUpdate
from schemas.shuttle import ShuttleCreate
from pydantic import BaseModel


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


@router.get("", response_model=list[ShuttleResponse])
async def list_shuttles(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch shuttles
    shuttles = db.query(Shuttle).offset(skip).limit(limit).all()
    return shuttles


@router.get("/{shuttle_id}", response_model=ShuttleResponse)
async def get_shuttle(shuttle_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single shuttle by ID
    shuttle = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()
    if shuttle is None:
        raise HTTPException(status_code=404, detail="Shuttle not found")
    return shuttle


@router.post("", response_model=ShuttleResponse)
async def create_shuttle(shuttle: ShuttleCreate, db: Session = Depends(get_db)):
    # Create a new shuttle in the database
    new_shuttle = Shuttle(**shuttle.dict())
    db.add(new_shuttle)
    db.commit()
    db.refresh(new_shuttle)
    return new_shuttle


@router.delete("/{shuttle_id}", response_model=str)
async def delete_shuttle(shuttle_id: int, db: Session = Depends(get_db)):
    # Retrieve the Shuttle object by its ID
    shuttle_to_delete = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()

    if shuttle_to_delete:
        # Delete the Shuttle object
        db.delete(shuttle_to_delete)
        db.commit()
        return f"Shuttle {shuttle_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"Shuttle with ID {shuttle_id} not found")


@router.put("/{shuttle_id}", response_model=ShuttleResponse)
async def update_shuttle(shuttle_id: int, shuttle_data: ShuttleUpdate, db: Session = Depends(get_db)):
    # Retrieve the Shuttle object by its ID
    shuttle_to_update = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()

    if shuttle_to_update:
        # Update the Shuttle object with the new data
        for field, value in shuttle_data.dict().items():
            setattr(shuttle_to_update, field, value)

        db.commit()
        db.refresh(shuttle_to_update)
        return shuttle_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Shuttle with ID {shuttle_id} not found")

@router.get("/{shuttle_id}/status", response_model=dict)
async def get_shuttle_status(shuttle_id: int, db: Session = Depends(get_db)):
    shuttle = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()
    if shuttle is None:
        raise HTTPException(status_code=404, detail="Shuttle not found")

    shuttle_status = {
        "shuttle_id": shuttle.id,
        "status": shuttle.shuttle_status
    }
    return shuttle_status


@router.get("/{shuttle_id}/type", response_model=dict)
async def get_shuttle_type(shuttle_id: int, db: Session = Depends(get_db)):
    shuttle = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()
    if shuttle is None:
        raise HTTPException(status_code=404, detail="Shuttle not found")

    shuttle_type = {
        "shuttle_id": shuttle.id,
        "type": shuttle.shuttle_type
    }
    return shuttle_type


@router.put("/{shuttle_id}/location", response_model=ShuttleResponse)
async def update_shuttle_location(shuttle_id: int, latitude: float, longitude: float, db: Session = Depends(get_db)):
    shuttle_to_update = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()

    if shuttle_to_update:
        shuttle_to_update.current_location_latitude = latitude
        shuttle_to_update.current_location_longitude = longitude

        db.commit()
        db.refresh(shuttle_to_update)
        return shuttle_to_update
    else:
        raise HTTPException(status_code=404, detail=f"Shuttle with ID {shuttle_id} not found")


@router.get("/{shuttle_id}/direction", response_model=dict)
async def get_shuttle_direction(shuttle_id: int, db: Session = Depends(get_db)):
    shuttle = db.query(Shuttle).filter(Shuttle.id == shuttle_id).first()
    if shuttle is None:
        raise HTTPException(status_code=404, detail="Shuttle not found")

    shuttle_direction = {
        "shuttle_id": shuttle.id,
        "direction": shuttle.shuttle_direction.value  # Accessing the direction enum value
    }
    return shuttle_direction

class ShuttleSchedule(BaseModel):
    east_shuttle_schedule: str = (
        "The East Shuttle runs continuous loops between Main Campus and "
        "the Presidential City Apartments (3900 City Avenue) during the following hours: "
        "\n\nMonday-Friday –  7:20 a.m.-10:50 p.m.\nSaturday and Sunday – 10:20 a.m.-10:50 p.m."
        "\n\nStops:\nMandeville Hall\n50th and City Avenue"
        "\n47th & City Avenue (City Ave North of 47th Street)\nTarget Shopping Center (City Ave North of Monument)"
        "\nPresidential/Lincoln Green (Stop is at Lincoln Green)"
        "\nBala Shopping Center (City Ave South of 47th Street)\nBala Ave & City Avenue"
        "\n\n*Please note that there is a stoppage in service from 10:20 a.m.-1:20 p.m., "
        "Monday-Friday and from 1:20 p.m.-3:20 p.m. on Saturday and Sunday."
    )

    west_shuttle_schedule: str = (
        "The West Shuttle runs continuous loops between Main Campus and Merion Gardens during the following hours: "
        "\n\nMonday-Friday: \nShuttle 1: 8:00 a.m.-3:15 p.m."
        "\nShuttle 2: 7:15 a.m.-10:50 p.m.\n\nSaturday-Sunday:\n10:20 a.m.-10:50 p.m."
        "\n\nStops:\nMandeville Hall\nCardinal Avenue Entrance Gate\nMerion Gardens"
        "\nOverbrook and City (Septa Stop)\nCardinal Avenue (Septa Stop)"
    )


@router.get("/schedules", response_model=ShuttleSchedule)
async def get_shuttle_schedules():
    return ShuttleSchedule()
