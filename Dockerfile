FROM python:3.9-slim

WORKDIR /app

# Install MariaDB client for health checks
RUN apt-get update && apt-get install -y default-mysql-client && apt-get clean

# Copy database initialization script
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Copy API code
COPY api/ /app/

# Install API dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Set environment variables
ENV DB_HOST=localhost
ENV DB_USER=user
ENV DB_PASSWORD=password
ENV DB_NAME=leaderboard

# Expose the API port
EXPOSE 8000

# Start both MariaDB and FastAPI
CMD ["/app/start.sh"]