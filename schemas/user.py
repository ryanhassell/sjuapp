from datetime import datetime

from pydantic import BaseModel


class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int


class UserCreate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int


class UserUpdate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int
    