from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware  # Add this import
from pydantic import BaseModel
from typing import Dict, List, Optional
import mysql.connector
from mysql.connector import Error
import os
import time
import logging
from contextlib import contextmanager

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Get database connection parameters from environment variables
DB_HOST = os.getenv("DB_HOST", "mariadb")
DB_USER = os.getenv("DB_USER", "user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_NAME = os.getenv("DB_NAME", "leaderboard")

# Connection management
@contextmanager
def get_db_connection():
    """Creates and manages a database connection with retry logic."""
    max_retries = 5
    retry_count = 0
    
    while retry_count < max_retries:
        connection = None
        try:
            logger.info(f"Attempting to connect to database... (attempt {retry_count + 1}/{max_retries})")
            connection = mysql.connector.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASSWORD,
                database=DB_NAME,
                connection_timeout=30
            )
            
            if connection.is_connected():
                logger.info("Database connection successful!")
                yield connection
                break
        except Error as e:
            retry_count += 1
            logger.error(f"Database connection failed: {str(e)}")
            if retry_count < max_retries:
                wait_time = 5 * retry_count
                logger.info(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                logger.error("Max retries reached. Could not connect to the database.")
                raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
        finally:
            if connection is not None and connection.is_connected():
                connection.close()

# Define Pydantic models for request/response
class ScoreUpload(BaseModel):
    username: str
    level_id: str
    score: float

class ScoreResponse(BaseModel):
    username: str
    score: float

app = FastAPI(title="Game Leaderboard API")

# Add CORS middleware to allow all origins (*)
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Allows all origins
#     allow_credentials=True,
#     allow_methods=["*"],  # Allows all methods
#     allow_headers=["*"],  # Allows all headers
# )

@app.post("/upload_score")
def upload_score(score_data: ScoreUpload):
    try:
        with get_db_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            
            # Check if entry exists
            check_query = """
                SELECT username, level_id, score 
                FROM scores 
                WHERE username = %s AND level_id = %s
            """
            cursor.execute(check_query, (score_data.username, score_data.level_id))
            existing_score = cursor.fetchone()
            
            if existing_score:
                # Update only if new score is higher
                if score_data.score > existing_score['score']:
                    update_query = """
                        UPDATE scores 
                        SET score = %s 
                        WHERE username = %s AND level_id = %s
                    """
                    cursor.execute(update_query, (score_data.score, score_data.username, score_data.level_id))
                    connection.commit()
                    return {"message": "Score updated successfully"}
                else:
                    return {"message": "Existing score is higher, no update needed"}
            else:
                # Create new score entry
                insert_query = """
                    INSERT INTO scores (username, level_id, score)
                    VALUES (%s, %s, %s)
                """
                cursor.execute(insert_query, (score_data.username, score_data.level_id, score_data.score))
                connection.commit()
                return {"message": "Score added successfully"}
    except Error as e:
        logger.error(f"Database error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/leaderboard")
def get_leaderboard(n_best: Optional[int] = 7):
    try:
        with get_db_connection() as connection:
            cursor = connection.cursor(dictionary=True)
            
            # Get all distinct level IDs
            cursor.execute("SELECT DISTINCT level_id FROM scores")
            level_ids = [row['level_id'] for row in cursor.fetchall()]
            
            result = {}
            
            # For each level, get the top n_best scores
            for level_id in level_ids:
                query = """
                    SELECT username, score 
                    FROM scores 
                    WHERE level_id = %s 
                    ORDER BY score DESC 
                    LIMIT %s
                """
                cursor.execute(query, (level_id, n_best))
                top_scores = cursor.fetchall()
                
                result[level_id] = [
                    {"username": score['username'], "score": score['score']}
                    for score in top_scores
                ]
            
            return result
    except Error as e:
        logger.error(f"Database error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")

@app.get("/health")
def health_check():
    try:
        with get_db_connection() as connection:
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            return {"status": "healthy", "database": "connected"}
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail=f"Database connection failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)