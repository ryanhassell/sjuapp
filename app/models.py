from sqlalchemy import Column, Integer, String, ARRAY, DateTime, Enum
from sqlalchemy.ext.declarative import declarative_base

from schemas.trip import TripTypeEnum

Base = declarative_base()


class Trip(Base):
    __tablename__ = "trips"
    id = Column(Integer, primary_key=True, index=True)
    trip_type = Column(Enum(TripTypeEnum, name='trip_type'))
    date_requested = Column(DateTime)
    start_location = Column(String)
    end_location = Column(String)
    driver = Column(String)
    passengers = Column(ARRAY(Integer))


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String)
    last_name = Column(String)
    date_registered = Column(DateTime)
    email_address = Column(String)
