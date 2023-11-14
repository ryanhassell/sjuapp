from datetime import datetime
from typing import List
from pydantic import BaseModel
from enum import Enum


class ShuttleDirectionEnum(str, Enum):
    east = "East"
    west = "West"


class ShuttleResponse(BaseModel):
    id: int
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_color: str

    class Config:
        arbitrary_types_allowed = True


class ShuttleCreate(BaseModel):
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_color: str


class ShuttleUpdate(BaseModel):
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_color: str
