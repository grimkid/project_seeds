# Project Seeds

A collection of project templates and setup recipes for quick project bootstrapping.

## Prerequisites

### System Requirements
- Ubuntu (20.04 or newer)
- Python 3.8.1 or higher

### Installing Just Command Runner

```bash
# Install Just on Ubuntu
sudo apt-get update
sudo apt-get install just

# Verify installation
just --version
```

## Available Templates

### 1. FastAPI Basic (`fastapi-basic`)
A minimal FastAPI setup with:
- Poetry for dependency management
- Health check endpoint
- Swagger documentation
- Modern project structure
- Development tools (black, flake8, pytest)

To create a new FastAPI project:
```bash
# Navigate to project_seeds directory
cd project_seeds

# Create new project (will prompt for project name)
just new-fastapi-basic

# Or specify project name directly
just new-fastapi-basic my-api-project
```

## Project Structure
```
project_seeds/
├── templates/                    # Project templates
│   └── fastapi-basic/           # Basic FastAPI template
├── justfile                     # Project recipes
└── README.md                    # This file
```

## Adding New Templates

Templates are stored in the `templates` directory. Each template should:
1. Have its own directory
2. Include a complete project structure
3. Use template variables (e.g., `{{project_name}}`)
4. Include a template-specific README

## Development

To add a new template:
1. Create a new directory in `templates/`
2. Add template files
3. Update the justfile with a new recipe
4. Update this README with template documentation 