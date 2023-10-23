from fastapi import FastAPI
from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from schemas.trip import TripResponse
import psycopg2
import urllib.parse


urllib.parse.quote_plus("password")
# declare the connection string specifying
# the host name database name use name
# and password
conn_string = f"host={DB_HOST} dbname={DB_NAME} user={DB_USER} password={DB_PASS}"

# use connect function to establish the connection
conn = psycopg2.connect(conn_string)
engine = create_engine('postgresql+psycopg2://user:password\
@hostname/sjuapp')

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/trips", response_model=Trip)
async def list_trips(session: Session):
    async with session as _session:
        trips = select(Trip)
        session.execute(trips)
        list_of_trips = trips.scalar()
        return list_of_trips


@app.get("/trip", response_model=Trip)
async def get_trip(trip_id: int, session: Session):
    async with session as _session:
        trips = select(Trip).where(Trip.id == trip_id)
        session.execute(trips)
        trip = trips.scalar()
        return trip
