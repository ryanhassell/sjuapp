from fastapi import FastAPI, HTTPException, Depends, APIRouter
from sqlalchemy.orm import Session
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.global_vars import DB_HOST, DB_NAME, DB_PASS, DB_USER
from app.models import Base, User, Trip
from schemas.user import UserResponse, UserCreate, UserUpdate
from schemas.user import UserCreate

# Define your connection string
conn_string = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}"
engine = create_engine(conn_string)
Base.metadata.create_all(bind=engine)

# Use the create_engine function to establish the connection
engine = create_engine(conn_string)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

router = APIRouter()


# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("", response_model=list[UserResponse])
async def list_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch users
    users = db.query(User).offset(skip).limit(limit).all()
    return users


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    # Use SQLAlchemy query to fetch a single user by ID
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Create a new user in the database
    new_user = User(**user.dict())
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@router.delete("/{user_id}", response_model=str)
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    # Retrieve the User object by its ID
    user_to_delete = db.query(User).filter(User.id == user_id).first()

    if user_to_delete:
        # Delete the User object
        db.delete(user_to_delete)
        db.commit()
        return f"User {user_id} successfully deleted."
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {user_id} not found")


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(user_id: int, user_data: UserUpdate, db: Session = Depends(get_db)):
    # Retrieve the User object by its ID
    user_to_update = db.query(User).filter(User.id == user_id).first()

    if user_to_update:
        # Update the User object with the new data
        for field, value in user_data.dict().items():
            setattr(user_to_update, field, value)

        db.commit()
        db.refresh(user_to_update)
        return user_to_update
    else:
        raise HTTPException(status_code=404, detail=f"User with ID {user_id} not found")


@router.get("/drivers/", response_model=list[UserResponse])
async def list_drivers(db: Session = Depends(get_db)):
    drivers = db.query(User).filter(User.user_type == 'driver').all()
    return drivers
