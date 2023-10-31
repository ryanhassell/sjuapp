from sqlalchemy import Column, Integer, String, ARRAY, DateTime, Enum, Float, Double
from sqlalchemy.ext.declarative import declarative_base

from schemas.trip import TripTypeEnum

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
    driver = Column(String)
    passengers = Column(ARRAY(Integer))


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String)
    last_name = Column(String)
    date_registered = Column(DateTime)
    email_address = Column(String)
    phone_number = Column(Integer)


class CampusLocation(Base):
    __tablename__ = "campus_locations"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    campus = Column(String)
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
