# {{project_name}} API

A FastAPI application with basic setup and health check endpoint.

## Available Endpoints

### 1. Root Endpoint (`/`)

Returns a welcome message.

```bash
# Using curl
curl http://localhost:8000/

# Expected response
{"message": "Hello World"}
```

### 2. Health Check (`/health`)

Checks if the application is running properly.

```bash
# Using curl
curl http://localhost:8000/health

# Expected response
{"status": "healthy"}
```

## API Documentation

The API documentation is available in three ways:

### 1. Swagger UI (Interactive)
- URL: `http://localhost:8000/docs`
- Features:
  - Interactive API testing
  - Request/response examples
  - Schema information
  - Try-it-out functionality

### 2. ReDoc (Alternative View)
- URL: `http://localhost:8000/redoc`
- Features:
  - Clean documentation layout
  - Easy-to-read format
  - Search functionality

### 3. OpenAPI Schema (Raw)
- URL: `http://localhost:8000/openapi.json`
- Features:
  - Raw OpenAPI/Swagger specification
  - Useful for automated tools

## Development Commands

```bash
# Start the server
just dev

# Check health
just health

# Open Swagger documentation
just docs

# Format code
just fmt

# Run linter
just lint

# Run tests
just test
``` 