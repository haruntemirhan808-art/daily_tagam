import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Load the environment variables from the .env file
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://tagam_admin:AmanIsTheBest@localhost:5432/daily_tagam")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set!")

# Create the SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create a session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for our SQLAlchemy models
Base = declarative_base()

# Dependency to get the DB session for each API request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()