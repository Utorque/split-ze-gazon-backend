#!/bin/bash
set -e

echo "Starting MariaDB server..."
# Start MariaDB in background
service mariadb start || {
    echo "Failed to start MariaDB service. Installing MariaDB server..."
    apt-get update && apt-get install -y mariadb-server
    service mariadb start
}

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
max_attempts=30
attempt=0
while ! mysqladmin ping -h localhost --silent && [ $attempt -lt $max_attempts ]; do
    attempt=$((attempt+1))
    echo "Waiting for database connection... attempt $attempt/$max_attempts"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "Database did not become available in time. Exiting."
    exit 1
fi

# Set up database and user
echo "Setting up database and user..."
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Initialize database schema
echo "Initializing database schema..."
mysql $DB_NAME < /docker-entrypoint-initdb.d/init.sql

echo "Database setup completed."

# Start the FastAPI application
echo "Starting FastAPI application..."
exec uvicorn main:app --host 0.0.0.0 --port 8000