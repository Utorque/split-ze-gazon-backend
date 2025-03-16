CREATE DATABASE IF NOT EXISTS leaderboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE leaderboard;

CREATE TABLE IF NOT EXISTS scores (
    username VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    level_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    score FLOAT NOT NULL
);

-- Create an index on level_id and score for faster leaderboard queries
CREATE INDEX idx_level_score ON scores (level_id, score DESC);

-- Add function to handle special characters in searches
DELIMITER //
CREATE FUNCTION IF NOT EXISTS normalize_string(input_str TEXT) 
RETURNS TEXT DETERMINISTIC
BEGIN
  DECLARE result TEXT;
  -- Remove zero-width spaces and other invisible Unicode characters
  SET result = REPLACE(input_str, CHAR(0x200B), ''); -- Zero width space
  SET result = REPLACE(result, CHAR(0x200C), '');    -- Zero width non-joiner
  SET result = REPLACE(result, CHAR(0x200D), '');    -- Zero width joiner
  SET result = REPLACE(result, CHAR(0x2060), '');    -- Word joiner
  SET result = REPLACE(result, CHAR(0xFEFF), '');    -- Zero width no-break space
  RETURN result;
END //
DELIMITER ;