from datetime import datetime
from pydantic import BaseModel
from enum import Enum


class ShuttleDirectionEnum(str, Enum):
    east = "east"
    west = "west"


class ShuttleResponse(BaseModel):
    id: int
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_status: str

    class Config:
        arbitrary_types_allowed = True


class ShuttleCreate(BaseModel):
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_status: str



class ShuttleUpdate(BaseModel):
    shuttle_direction: ShuttleDirectionEnum
    arrival_time: datetime
    departure_time: datetime
    current_location_latitude: float
    current_location_longitude: float
    shuttle_type: str
    shuttle_status: str

