from fastapi import FastAPI
from routers import users, trips, campus_locations, vehicles
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
origins = [
    "http://10.0.0.21/",
    "http://10.0.0.21/:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Include routers so their APIs are in FastAPI
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(trips.router, prefix="/trips", tags=["Trips"])
app.include_router(campus_locations.router, prefix="/campus_locations", tags=["Campus Locations"])
app.include_router(vehicles.router, prefix="/vehicles", tags=["Vehicles"])

