from fastapi import FastAPI
from routers import users, trips, campus_locations

app = FastAPI()

# Include routers so their APIs are in FastAPI
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(trips.router, prefix="/trips", tags=["Trips"])
app.include_router(campus_locations.router, prefix="/campus_locations", tags=["Campus Locations"])
app.include_router(vehicles.router, prefix="/vehicles", tags=["Vehicles"])
app.include_router(drivers.router, prefix="/drivers", tags=["Drivers"])

