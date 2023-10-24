from datetime import datetime
from typing import List
from pydantic import BaseModel
from enum import Enum


class CampusEnum(str, Enum):
    hawkhill = "Hawk Hill"
    ucity = "University City"


class CampusLocationResponse(BaseModel):
    id: int
    name: str
    longitude: float
    latitude: float
    campus: CampusEnum

    class Config:
        arbitrary_types_allowed = True


class CampusLocationCreate(BaseModel):
    id: int
    name: str
    longitude: float
    latitude: float
    campus: CampusEnum


class CampusLocationUpdate(BaseModel):
    id: int
    name: str
    longitude: float
    latitude: float
    campus: CampusEnum