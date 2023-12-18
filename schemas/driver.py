from pydantic import BaseModel


class DriverResponse(BaseModel):
    user_id: int
    available: bool
    current_trip: int
    current_location_latitude: float
    current_location_longitude: float

    class Config:
        arbitrary_types_allowed = True
