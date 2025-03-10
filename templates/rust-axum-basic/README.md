# {{display_name}}

A Rust web API using the Axum framework, featuring OpenAPI documentation and health check endpoint.

## Prerequisites

- Rust 1.75.0 or higher
- Cargo (Rust's package manager)
- Just (Command runner)
- cargo-watch (for development, optional)

## Quick Start

### 1. Project Setup

```bash
# Install just (if not already installed)
# On Ubuntu/Debian:
sudo apt-get install just

# On macOS:
brew install just

# Install cargo-watch for development (optional)
cargo install cargo-watch

# Setup the project
just setup
```

### 2. Development Commands

We use `just` as our task runner. Available commands:

```bash
just                 # List all available commands
just setup          # Build the project
just dev            # Run the development server with auto-reload
just fmt            # Format code
just lint           # Run linter (clippy)
just test           # Run tests
just clean          # Clean build artifacts
just build-release  # Build in release mode
just info           # Show Rust and cargo information
```

### 3. Running the Application

```bash
# Start the development server with auto-reload:
just dev

# Or run directly with cargo:
cargo run
```

The server will start at `http://localhost:3000`

## API Documentation

- Interactive API docs (Swagger UI): `http://localhost:3000/docs`
- OpenAPI JSON: `http://localhost:3000/api-docs/openapi.json`

## Available Endpoints

### 1. Root Endpoint (`/`)

Returns a welcome message.

```bash
# Using curl
curl http://localhost:3000/

# Expected response
{"message": "Welcome to {{display_name}}"}
```

### 2. Health Check (`/health`)

Checks if the application is running properly.

```bash
# Using curl
curl http://localhost:3000/health

# Expected response
{"status": "healthy"}
```

## Project Structure
```
{{project_name}}/
├── src/
│   ├── main.rs       # Main application file
│   └── health.rs     # Health check endpoint
├── Cargo.toml        # Project dependencies and metadata
├── justfile          # Task runner commands
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Development

### Adding New Dependencies

To add new dependencies:
```bash
cargo add package-name
```

For development-only dependencies:
```bash
cargo add --dev package-name
```

### Code Style

This project follows Rust's official style guide. To format your code:
```bash
just fmt
```

### Linting

We use clippy for linting:
```bash
just lint
```

### Testing

Run tests with:
```bash
just test
```

## Troubleshooting

If you encounter any issues:

1. Check your Rust version:
```bash
rustc --version  # Should be 1.75.0 or higher
```

2. Check environment info:
```bash
just info  # Shows Rust and cargo details
```

3. Make sure you're in the project directory when running commands

4. If the development server fails to start:
   - Check if port 3000 is available
   - Ensure you have necessary permissions
   - Check the console output for specific error messages

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Format and lint your code (`just fmt && just lint`)
4. Run tests (`just test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 