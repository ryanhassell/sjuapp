from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Trip, Base
from schemas.trip import TripResponse, TripCreate

# Define your connection string
conn_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
engine = create_engine(conn_string)
Base.metadata.create_all(bind=engine)

# Use the create_engine function to establish the connection
engine = create_engine(conn_string)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI()


# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/trips", response_model=list[TripResponse])
async def list_trips(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch trips
    trips = db.query(Trip).offset(skip).limit(limit).all()
    return trips


@app.get("/trip/{trip_id}", response_model=TripResponse)
async def get_trip(trip_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single trip by ID
    trip = db.query(Trip).filter(Trip.id == trip_id).first()
    if trip is None:
        raise HTTPException(status_code=404, detail="Trip not found")
    return trip


@app.post("/trips", response_model=TripResponse)
async def create_trip(trip: TripCreate, db: Session = Depends(get_db)):
    # Create a new trip in the database
    new_trip = Trip(**trip.dict())
    db.add(new_trip)
    db.commit()
    db.refresh(new_trip)
    return new_trip
