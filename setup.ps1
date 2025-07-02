# Northwind MCP Setup Script (Windows PowerShell)
# This script sets up the Northwind MCP project for first-time use

$ErrorActionPreference = "Stop"

Write-Host "🚀 Setting up Northwind MCP Project..." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check for Docker
try {
    docker --version | Out-Null
    Write-Host "✅ Docker found" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check for Docker Compose
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose found" -ForegroundColor Green
} catch {
    try {
        docker compose version | Out-Null
        Write-Host "✅ Docker Compose (v2) found" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker Compose is not installed. Please install Docker Compose first." -ForegroundColor Red
        exit 1
    }
}

# Check for .NET
try {
    dotnet --version | Out-Null
    Write-Host "✅ .NET SDK found" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET SDK is not installed. Please install .NET 8.0 SDK first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Prerequisites check passed!" -ForegroundColor Green

# Setup environment file
Write-Host "Setting up environment file..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Created .env file from .env.example" -ForegroundColor Green
    } else {
        Write-Host "⚠️  .env.example not found. Creating basic .env file..." -ForegroundColor Yellow
        @"
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
"@ | Out-File -FilePath ".env" -Encoding UTF8
        Write-Host "✅ Created basic .env file" -ForegroundColor Green
    }
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Build and start the database
Write-Host "Building and starting the Northwind database..." -ForegroundColor Yellow
try {
    # Try docker-compose first
    docker-compose build
    docker-compose up -d
} catch {
    try {
        # Fallback to docker compose v2
        docker compose build
        docker compose up -d
    } catch {
        Write-Host "❌ Failed to start database container" -ForegroundColor Red
        exit 1
    }
}

# Wait for database to be ready
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 1

do {
    try {
        docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT 1" | Out-Null
        Write-Host "✅ Database is ready!" -ForegroundColor Green
        break
    } catch {
        if ($attempt -eq $maxAttempts) {
            Write-Host "❌ Database failed to start after $maxAttempts attempts" -ForegroundColor Red
            Write-Host "Please check the logs with: docker logs northwind-database" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "⏳ Waiting for database... (attempt $attempt/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        $attempt++
    }
} while ($attempt -le $maxAttempts)

# Build the .NET solution
Write-Host "Building .NET solution..." -ForegroundColor Yellow
try {
    dotnet build
    Write-Host "✅ .NET solution built successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to build .NET solution" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. To run the MCP client (recommended):" -ForegroundColor White
Write-Host "   cd Client; dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "2. To run server and client separately:" -ForegroundColor White
Write-Host "   Terminal 1: cd Server; dotnet run" -ForegroundColor Gray
Write-Host "   Terminal 2: cd Client; dotnet run" -ForegroundColor Gray
Write-Host ""
Write-Host "3. To test the database connection:" -ForegroundColor White
Write-Host "   docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q `"SELECT COUNT(*) FROM Customers`"" -ForegroundColor Gray
Write-Host ""
Write-Host "4. To open an interactive SQL shell:" -ForegroundColor White
Write-Host "   docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Optional: Set up Anthropic API key for AI features:" -ForegroundColor White
Write-Host "   dotnet user-secrets set `"ANTHROPIC_API_KEY`" `"your-api-key`" --project Client" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 For more information, check the README.md file" -ForegroundColor Cyan
Write-Host "🐛 If you encounter issues, run: docker logs northwind-database" -ForegroundColor Cyan
