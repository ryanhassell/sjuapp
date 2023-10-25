from fastapi import FastAPI
from routers import riders, trips, campus_locations

app = FastAPI()

# Include routers so their APIs are in FastAPI
app.include_router(riders.router, prefix="/riders", tags=["Riders"])
app.include_router(trips.router, prefix="/trips", tags=["Trips"])
app.include_router(campus_locations.router, prefix="/campus_locations", tags=["Campus Locations"])

