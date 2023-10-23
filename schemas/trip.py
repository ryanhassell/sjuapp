from datetime import datetime
from typing import List
from pydantic import BaseModel
from enum import Enum


class TripTypeEnum(str, Enum):
    group = "group"
    single = "single"


class TripResponse(BaseModel):
    id: int
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]
    trip_type: TripTypeEnum
    date_requested: datetime

    class Config:
        arbitrary_types_allowed = True


class TripCreate(BaseModel):
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]
    trip_type: TripTypeEnum
    date_requested: datetime


class TripUpdate(BaseModel):
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]
    trip_type: TripTypeEnum
    date_requested: datetime
