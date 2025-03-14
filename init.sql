CREATE DATABASE IF NOT EXISTS leaderboard;
USE leaderboard;

CREATE TABLE IF NOT EXISTS scores (
    username VARCHAR(255) NOT NULL,
    level_id VARCHAR(255) NOT NULL,
    score FLOAT NOT NULL
);

-- Create an index on level_id and score for faster leaderboard queries
CREATE INDEX idx_level_score ON scores (level_id, score DESC);