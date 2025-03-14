FROM docker/compose:latest

WORKDIR /app

COPY docker-compose.yml .
COPY init.sql .
COPY api/ api/

# This image can be used for deployment
# Usage: docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/username/reponame up -d
ENTRYPOINT ["docker-compose"]
CMD ["up", "-d"]