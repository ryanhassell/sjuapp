from pydantic import BaseModel


class DriverResponse(BaseModel):
    user_id: int
    available: bool

    class Config:
        arbitrary_types_allowed = True
