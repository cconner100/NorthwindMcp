#!/bin/bash

# Northwind MCP Setup Script
# This script sets up the Northwind MCP project for first-time use

set -e  # Exit on any error

echo "🚀 Setting up Northwind MCP Project..."
echo "======================================"

# Check prerequisites
echo "Checking prerequisites..."

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check for .NET
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK is not installed. Please install .NET 8.0 SDK first."
    exit 1
fi

# Check for Make (optional)
if ! command -v make &> /dev/null; then
    echo "⚠️  Make is not installed. You can still use docker-compose commands directly."
fi

echo "✅ Prerequisites check passed!"

# Setup environment file
echo "Setting up environment file..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ Created .env file from .env.example"
    else
        echo "⚠️  .env.example not found. Creating basic .env file..."
        cat > .env << 'EOF'
# Database Configuration
SA_PASSWORD=YourStrong@Passw0rd
MSSQL_PID=Developer
ACCEPT_EULA=Y

# Container Configuration
CONTAINER_NAME=northwind-database
HOST_PORT=1433

# Connection Details
SERVER_NAME=localhost
DATABASE_NAME=Northwind

# Healthcheck
HEALTHCHECK_ENABLED=true

# Persistence
ENABLE_PERSISTENCE=true
EOF
        echo "✅ Created basic .env file"
    fi
else
    echo "✅ .env file already exists"
fi

# Build and start the database
echo "Building and starting the Northwind database..."
if command -v make &> /dev/null; then
    make build
    make up
else
    docker-compose build
    docker-compose up -d
fi

# Wait for database to be ready
echo "Waiting for database to be ready..."
max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT 1" > /dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ Database failed to start after $max_attempts attempts"
        echo "Please check the logs with: docker logs northwind-database"
        exit 1
    fi
    
    echo "⏳ Waiting for database... (attempt $attempt/$max_attempts)"
    sleep 2
    ((attempt++))
done

# Build the .NET solution
echo "Building .NET solution..."
dotnet build

echo ""
echo "🎉 Setup complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. To run the MCP client (recommended):"
echo "   cd Client && dotnet run"
echo ""
echo "2. To run server and client separately:"
echo "   Terminal 1: cd Server && dotnet run"
echo "   Terminal 2: cd Client && dotnet run"
echo ""
echo "3. To test the database connection:"
if command -v make &> /dev/null; then
    echo "   make test"
else
    echo "   docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q \"SELECT COUNT(*) FROM Customers\""
fi
echo ""
echo "4. To open an interactive SQL shell:"
if command -v make &> /dev/null; then
    echo "   make query"
else
    echo "   docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C"
fi
echo ""
echo "5. Optional: Set up Anthropic API key for AI features:"
echo "   dotnet user-secrets set \"ANTHROPIC_API_KEY\" \"your-api-key\" --project Client"
echo ""
echo "📚 For more information, check the README.md file"
echo "🐛 If you encounter issues, run: docker logs northwind-database"
