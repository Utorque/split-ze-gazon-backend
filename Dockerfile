FROM mariadb:latest

# Copy database initialization script
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Set default environment variables
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=leaderboard
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=password

# Expose the MariaDB port
EXPOSE 3306

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} || exit 1