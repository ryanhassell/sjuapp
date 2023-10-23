from typing import List

from pydantic import BaseModel


class TripResponse(BaseModel):
    id: int
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]


class TripCreate(BaseModel):
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]


class TripUpdate(BaseModel):
    start_location: str
    end_location: str
    driver: str
    passengers: List[int]
