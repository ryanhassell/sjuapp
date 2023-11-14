from sqlalchemy import Column, Integer, String, ARRAY, DateTime, Enum, Float, Double, ForeignKey, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from schemas.shuttle import ShuttleDirectionEnum
from schemas.trip import TripTypeEnum, TripStatusEnum
from schemas.user import UserTypeEnum

Base = declarative_base()


class Trip(Base):
    __tablename__ = "trips"
    id = Column(Integer, primary_key=True, index=True)
    trip_type = Column(Enum(TripTypeEnum, name='trip_type'))
    date_requested = Column(DateTime)
    start_location_latitude = Column(Double)
    start_location_longitude = Column(Double)
    end_location_latitude = Column(Double)
    end_location_longitude = Column(Double)
    driver = Column(Integer)
    trip_status = Column(Enum(TripStatusEnum, name='trip_status'))
    passengers = Column(ARRAY(Integer))


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    user_type = Column(Enum(UserTypeEnum, name='user_type'))
    first_name = Column(String)
    last_name = Column(String)
    date_registered = Column(DateTime)
    email_address = Column(String)
    phone_number = Column(String)
    on_duty = Column(Boolean)
    driver = relationship('Driver', back_populates='user')


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
    shuttle_direction = Column(Enum(ShuttleDirectionEnum, name='shuttle_direction'))
    arrival_time = Column(DateTime)
    departure_time = Column(DateTime)
    current_location_latitude = Column(Double)
    current_location_longitude = Column(Double)
    shuttle_type = Column(String)  # type of vehicle


class Driver(Base):
    __tablename__ = "available_drivers"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'))
    user = relationship('User', back_populates='driver')

