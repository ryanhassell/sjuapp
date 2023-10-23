from datetime import datetime

from pydantic import BaseModel


class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str


class UserCreate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str


class UserUpdate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
