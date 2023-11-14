from datetime import datetime
from typing import List

from pydantic import BaseModel

class UserTypeEnum(str, Enum):
    driver = "Driver"
    rider = "Rider"

class UserResponse(BaseModel):
    id: int
    user_type: UserTypeEnum
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str

    class Config:
        arbitrary_types_allowed = True

class UserCreate(BaseModel):
    user_type: UserTypeEnum
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str


class UserUpdate(BaseModel):
    user_type: UserTypeEnum
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: str
