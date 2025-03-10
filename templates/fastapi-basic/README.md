# FastAPI Basic Template

A minimal FastAPI project template with health check endpoint and modern Python practices.

## Prerequisites

- Python 3.8.1 or higher
- Poetry (Python package manager)
- Just command runner

## Project Naming

Project names must follow Poetry's naming conventions:
- Start with a letter or number
- Contain only letters, numbers, underscores, and hyphens
- End with a letter or number

Examples:
- ✅ `my-project`
- ✅ `project_1`
- ✅ `myproject`
- ❌ `My-Project` (uppercase not allowed)
- ❌ `project.name` (dots not allowed)
- ❌ `project_` (ends with underscore)

The template will automatically convert your project name to a Poetry-compatible format:
- Uppercase letters → lowercase
- Hyphens → underscores

## Quick Start

After generating your project from this template:

```bash
# 1. Navigate to your project directory
cd your-project-name

# 2. Setup the project (installs dependencies)
just setup

# 3. Activate the virtual environment
just activate

# 4. Start the development server
just dev
```

The server will start at `http://localhost:8000`

## Project Structure

```
your-project-name/
├── app/
│   ├── __init__.py              # Package initialization
│   ├── main.py                  # Main application file
│   ├── health.py               # Health check endpoint
│   └── README.md                # API documentation
├── pyproject.toml               # Project dependencies and metadata
├── justfile                     # Development commands
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## Development Workflow

1. **Environment Management**:
   ```bash
   just activate     # Activate virtual environment
   deactivate       # Deactivate when done
   ```

2. **Running the Server**:
   ```bash
   just dev         # Start development server with auto-reload
   ```

3. **Code Quality**:
   ```bash
   just fmt         # Format code with black
   just lint        # Run linter (flake8)
   just test        # Run tests
   ```

4. **API Documentation**:
   ```bash
   just docs        # Open Swagger UI in browser
   ```

5. **Health Checks**:
   ```bash
   just health      # Check if API is healthy
   ```

6. **Environment Info**:
   ```bash
   just info        # Show Python and dependency info
   ```

## Adding Dependencies

```bash
# Add production dependencies
poetry add package-name

# Add development dependencies
poetry add --group dev package-name
```

## Template Features

- FastAPI with OpenAPI/Swagger documentation
- Poetry for dependency management
- Health check endpoint
- Development tools:
  - Black (code formatting)
  - Flake8 (linting)
  - Pytest (testing)
- Just command runner for common tasks
- Comprehensive documentation
- Modern project structure

## Customization

1. Update project metadata in `pyproject.toml`
2. Modify API information in `app/main.py`
3. Add your endpoints in `app/main.py` or create new modules
4. Update documentation in `app/README.md`

## Best Practices

- Keep endpoints modular and organized by feature
- Document all endpoints with docstrings and OpenAPI decorators
- Write tests for new endpoints
- Run formatter and linter before committing
- Keep dependencies up to date

## Troubleshooting

If you encounter any issues:

1. Check Python version:
   ```bash
   python3 --version  # Should be 3.8.1 or higher
   ```

2. Verify environment:
   ```bash
   just info
   ```

3. Clean Python cache:
   ```bash
   just clean
   ```

4. Recreate virtual environment:
   ```bash
   rm -rf .venv
   just setup
   just activate
   ``` 