from sqlalchemy import (
    Column,
    Integer,
    String,
    ARRAY,
    DateTime,
    Enum,
    Float,
    Double,
    ForeignKey,
    Boolean,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from schemas.shuttle import ShuttleDirectionEnum
from schemas.trip import TripTypeEnum, TripStatusEnum
from schemas.user import UserTypeEnum

Base = declarative_base()


class Trip(Base):
    __tablename__ = "trips"
    id = Column(Integer, primary_key=True, index=True)
    trip_type = Column(Enum(TripTypeEnum, name="trip_type"))
    date_requested = Column(DateTime)
    start_location_latitude = Column(Double)
    start_location_longitude = Column(Double)
    end_location_latitude = Column(Double)
    end_location_longitude = Column(Double)
    driver = Column(Integer, nullable=True)
    trip_status = Column(Enum(TripStatusEnum, name="trip_status"))
    passengers = Column(ARRAY(Integer))


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    user_type = Column(Enum(UserTypeEnum, name="user_type"))
    first_name = Column(String)
    last_name = Column(String)
    date_registered = Column(DateTime)
    email_address = Column(String)
    phone_number = Column(String)
    driver = relationship("Driver", back_populates="user")
    sju_id = Column(String)
    password = Column(String)
    authenticated = Column(Boolean)


class CampusLocation(Base):
    __tablename__ = "campus_locations"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    campus = Column(String)


class Vehicle(Base):
    __tablename__ = "vehicles"
    id = Column(Integer, primary_key=True, index=True)
    make = Column(String)
    model = Column(String)
    year = Column(String)
    color = Column(String)
    seatsAvailable = Column(Integer)
    licensePlate = Column(String)


class Shuttle(Base):
    __tablename__ = "shuttles"
    id = Column(Integer, primary_key=True, index=True)
    shuttle_direction = Column(Enum(ShuttleDirectionEnum, name="shuttle_direction"))
    arrival_time = Column(DateTime)
    departure_time = Column(DateTime)
    current_location_latitude = Column(Float)
    current_location_longitude = Column(Float)
    shuttle_type = Column(String)  # type of vehicle
    shuttle_status = Column(String)


class Driver(Base):
    __tablename__ = "drivers"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    available = Column(Boolean)
    current_trip = Column(Integer)
    current_location_latitude = Column(Float)
    current_location_longitude = Column(Float)
    user = relationship("User", back_populates="driver")
