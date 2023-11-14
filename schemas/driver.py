from pydantic import BaseModel


class DriverResponse(BaseModel):
    user_id: int
    available: bool
    current_trip: int

    class Config:
        arbitrary_types_allowed = True
