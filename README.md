# split-ze-gazon-backend
code for backend server for https://github.com/ylked/split-the-gazon

# Game Leaderboard API

A Docker Compose setup with MariaDB and FastAPI to handle game scores and leaderboards.

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── docker-publish.yml
├── api/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── docker-compose.yml
├── Dockerfile
├── init.sql
└── README.md
```

## Features

- MariaDB database to store game scores
- FastAPI server with endpoints:
  - `POST /upload_score` - Upload a new score or update existing one
  - `GET /leaderboard` - Get leaderboards for all levels
- GitHub Actions workflow to build and publish Docker images to GitHub Container Registry

## Setup and Running

### Local Development

1. Clone the repository
2. Run the Docker Compose setup:

```bash
docker-compose up -d
```

The API will be available at http://localhost:8000

### API Documentation

Once running, you can access the API documentation at http://localhost:8000/docs

## API Endpoints

### Upload Score

```
POST /upload_score
```

Request body:
```json
{
  "username": "player1",
  "level_id": "level_1",
  "score": 123.45
}
```

### Get Leaderboard

```
GET /leaderboard?n_best=7
```

Response:
```json
{
  "level_1": [
    {"username": "player1", "score": 123.45},
    {"username": "player2", "score": 100.0}
  ],
  "level_2": [
    {"username": "player3", "score": 200.0}
  ]
}
```

## GitHub Actions

The included GitHub Actions workflow will:

1. Build the Docker images for the API and the full Compose setup
2. Push the images to GitHub Container Registry (ghcr.io)

To use it, you need to:

1. Add the repository to GitHub
2. Make sure your GitHub account has the necessary permissions
3. The workflow will run automatically on pushes to the main branch

## Deployment

You can deploy using Docker Compose directly from the GitHub Container Registry:

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/yourusername/your-repo-name up -d
```