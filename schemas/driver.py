from datetime import datetime

from pydantic import BaseModel


class DriverResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    public_safety_office: str
    phone_number: int


class DriverCreate(BaseModel):
    first_name: str
    last_name: str
    public_safety_office: str
    phone_number: int


class DriverUpdate(BaseModel):
    first_name: str
    last_name: str
    public_safety_office: str
    phone_number: int

