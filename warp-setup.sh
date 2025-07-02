#!/bin/bash

# Northwind MCP Setup Script for Warp Terminal
# This script leverages Warp's AI and package management features

set -e

echo "🚀 Setting up Northwind MCP Project with Warp..."
echo "==============================================="

# Check if we're running in Warp
if [[ "$TERM_PROGRAM" != "WarpTerminal" ]]; then
    echo "⚠️  This script is optimized for Warp Terminal"
    echo "   Consider downloading Warp from https://www.warp.dev/"
    echo "   Continuing with standard setup..."
fi

# Function to run commands with Warp AI suggestions
run_with_warp_help() {
    local cmd="$1"
    local description="$2"
    
    echo ""
    echo "🤖 Warp AI Tip: $description"
    echo "   Running: $cmd"
    echo "   (In Warp, you can ask AI: 'What does this command do?')"
    
    eval "$cmd"
}

echo "Installing prerequisites with Warp's package management..."

# Check and install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    run_with_warp_help "brew install --cask docker" "Install Docker Desktop via Homebrew"
    
    echo "📝 Note: Docker Desktop will open. Please complete the setup and then return here."
    echo "💡 Warp Tip: Type 'open -a Docker' to start Docker Desktop"
    read -p "Press Enter when Docker Desktop is ready..."
else
    echo "✅ Docker is already installed"
fi

# Check and install .NET
if ! command -v dotnet &> /dev/null; then
    echo "Installing .NET SDK..."
    run_with_warp_help "brew install dotnet" "Install .NET SDK via Homebrew"
else
    echo "✅ .NET SDK is already installed"
fi

# Check and install Make
if ! command -v make &> /dev/null; then
    echo "Installing Xcode Command Line Tools (includes Make)..."
    run_with_warp_help "xcode-select --install" "Install Xcode Command Line Tools for Make and Git"
else
    echo "✅ Make is already installed"
fi

echo "✅ Prerequisites installation complete!"

# Setup environment file
echo "Setting up environment file..."
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ Created .env file from .env.example"
    else
        echo "Creating basic .env file..."
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

# Build and start the database with Warp AI tips
echo "Building and starting the Northwind database..."
run_with_warp_help "make build" "Build the Docker image for SQL Server with Northwind database"
run_with_warp_help "make up" "Start the database container with health checks"

# Wait for database with Warp-friendly progress
echo "Waiting for database to be ready..."
echo "💡 Warp Tip: Try asking AI 'How can I check if a Docker container is healthy?'"

max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
    if make test > /dev/null 2>&1; then
        echo "✅ Database is ready!"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ Database failed to start after $max_attempts attempts"
        echo "🤖 Warp AI Help: Ask 'How do I troubleshoot Docker container startup issues?'"
        echo "📝 Check logs with: make logs"
        exit 1
    fi
    
    echo "⏳ Waiting for database... (attempt $attempt/$max_attempts)"
    sleep 2
    ((attempt++))
done

# Build the .NET solution
echo "Building .NET solution..."
run_with_warp_help "dotnet build" "Build the MCP server and client projects"

# Create Warp workflows (if Warp supports it)
echo "🎯 Creating helpful Warp shortcuts..."
echo ""
echo "Consider saving these as Warp workflows:"
echo "  1. 'northwind-start' → make up"
echo "  2. 'northwind-test' → make test"  
echo "  3. 'northwind-query' → make query"
echo "  4. 'northwind-logs' → make logs"
echo "  5. 'mcp-run' → cd Client && dotnet run"

echo ""
echo "🎉 Warp setup complete!"
echo "======================"
echo ""
echo "🤖 Next steps (try asking Warp AI for help with any of these):"
echo ""
echo "1. Test your setup:"
echo "   make test"
echo "   💡 Ask Warp AI: 'What does this command test?'"
echo ""
echo "2. Run the MCP client:"
echo "   cd Client && dotnet run"
echo "   💡 Ask Warp AI: 'What is Model Context Protocol?'"
echo ""
echo "3. Query the database:"
echo "   make query"
echo "   💡 Try asking: 'Show me some SQL queries for the Northwind database'"
echo ""
echo "4. Optional - Set up AI features:"
echo "   dotnet user-secrets set \"ANTHROPIC_API_KEY\" \"your-key\" --project Client"
echo "   💡 Ask Warp AI: 'What are .NET user secrets?'"
echo ""
echo "🌟 Warp Terminal Features to Try:"
echo "   • Cmd+P: Command palette"
echo "   • Ask AI: Natural language help"
echo "   • Workflows: Save command sequences"  
echo "   • Share: Collaborate with teammates"
echo ""
echo "📚 For more info: check README.md"
echo "🐛 Issues? Try: make logs or ask Warp AI for debugging help"
