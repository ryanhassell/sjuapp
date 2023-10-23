from pydantic import BaseModel


class TripResponse(BaseModel):
    id: int
    start_location: str
    end_location: str
    driver: str


class TripCreate(BaseModel):
    start_location: str
    end_location: str
    driver: str

