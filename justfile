# List all available commands
default:
    @just --list

# Create a new FastAPI basic project
new-fastapi-basic project_name="":
    #!/usr/bin/env bash
    if [ -z "{{project_name}}" ]; then
        read -p "Enter project name: " name
    else
        name="{{project_name}}"
    fi
    
    # Convert project name to lowercase and replace hyphens with underscores
    poetry_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr '-' '_')
    display_name="$name"
    
    # Create project directory
    mkdir -p "$name"
    
    # Copy template files
    cp -r templates/fastapi-basic/* "$name/"
    
    # Replace template variables using perl (more reliable than sed for this case)
    find "$name" -type f -exec perl -pi -e "s/\{\{project_name\}\}/$poetry_name/g" {} +
    find "$name" -type f -exec perl -pi -e "s/\{\{display_name\}\}/$display_name/g" {} +
    
    # Setup Python environment
    cd "$name"
    poetry install || {
        echo "Error: Poetry installation failed. Please check your project name and try again."
        echo "Project names must:"
        echo "  - Start with a letter or number"
        echo "  - Contain only letters, numbers, underscores, and hyphens"
        echo "  - End with a letter or number"
        cd ..
        rm -rf "$name"
        exit 1
    }
    
    echo "Project '$name' created successfully!"
    echo "To get started:"
    echo "  cd $name"
    echo "  just setup"
    echo "  just dev"

# List available templates
list-templates:
    @echo "Available templates:"
    @ls -1 templates/

# Create template directory structure
create-template template_name:
    #!/usr/bin/env bash
    mkdir -p "templates/{{template_name}}"
    echo "# {{template_name}} Template" > "templates/{{template_name}}/README.md"
    echo "Template directory created at templates/{{template_name}}"
    echo "Don't forget to:"
    echo "1. Add template files"
    echo "2. Update the justfile with a new recipe"
    echo "3. Update the main README.md" 