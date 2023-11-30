from datetime import datetime
from pydantic import BaseModel
from enum import Enum


class UserTypeEnum(str, Enum):
    driver = "driver"
    student = "student"


class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str
    user_type: UserTypeEnum
    sju_id: str
    password: str
    authenticated: bool

    class Config:
        arbitrary_types_allowed = True


class UserCreate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str
    user_type: UserTypeEnum
    sju_id: str
    password: str
    authenticated: bool


class UserUpdate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str
    user_type: UserTypeEnum
    sju_id: str
    password: str
    authenticated: bool
