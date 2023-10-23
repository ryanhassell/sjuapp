from fastapi import FastAPI
from routers import users, trips  # Import your routers

app = FastAPI()

# Include your routers in the FastAPI app
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(trips.router, prefix="/trips", tags=["Trips"])
