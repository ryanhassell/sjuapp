from datetime import datetime
from typing import List
from pydantic import BaseModel
from enum import Enum


class VehicleResponse(BaseModel):
    id: int
    make: str
    model: str
    year: str
    color: str
    seatsAvailable: int
    licensePlate: int

class VehicleCreate(BaseModel):
    make: str
    model: str
    year: str
    color: str
    seatsAvailable: int
    licensePlate: int

class VehicleUpdate(BaseModel):
    make: str
    model: str
    year: str
    color: str
    seatsAvailable: int
    licensePlate: int
