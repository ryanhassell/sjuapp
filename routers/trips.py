from fastapi import FastAPI
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import text
from sqlalchemy.orm import Session

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/trips")
async def list_trips(lat: float, long: float):
    print("Latitude is ", lat)
    print("Longitude is ", long)

