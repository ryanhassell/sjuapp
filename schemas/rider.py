from datetime import datetime

from pydantic import BaseModel


class RiderResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int


class RiderCreate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int


class RiderUpdate(BaseModel):
    first_name: str
    last_name: str
    date_registered: datetime
    email_address: str
    phone_number: int
    