from datetime import datetime
from typing import List
from pydantic import BaseModel
from enum import Enum


class TripTypeEnum(str, Enum):
    group = "group"
    single = "single"


class TripStatusEnum(str, Enum):
    current = "current"
    completed = "completed"
    no_driver = "no_driver"


class TripResponse(BaseModel):
    id: int
    start_location_latitude: float
    start_location_longitude: float
    end_location_latitude: float
    end_location_longitude: float
    driver: int | None
    passengers: List[int]
    trip_type: TripTypeEnum
    trip_status: TripStatusEnum
    date_requested: datetime

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        orm_mode = True


class TripCreateResponse(BaseModel):
    id: int
    start_location_latitude: float
    start_location_longitude: float
    end_location_latitude: float
    end_location_longitude: float
    passengers: List[int]
    trip_type: TripTypeEnum
    trip_status: TripStatusEnum
    date_requested: datetime

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        orm_mode = True



class TripCreate(BaseModel):
    start_location_latitude: float
    start_location_longitude: float
    end_location_latitude: float
    end_location_longitude: float
    passengers: List[int]
    trip_type: TripTypeEnum
    trip_status: TripStatusEnum
    date_requested: datetime

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        orm_mode = True


class TripUpdate(BaseModel):
    start_location_latitude: float
    start_location_longitude: float
    end_location_latitude: float
    end_location_longitude: float
    driver: int | None
    passengers: List[int]
    trip_type: TripTypeEnum
    trip_status: TripStatusEnum
    date_requested: datetime

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        orm_mode = True


class TripStatusResponse(BaseModel):
    id: int
    trip_status: TripStatusEnum

    class Config:
        from_attributes = True
        arbitrary_types_allowed = True
        orm_mode = True
