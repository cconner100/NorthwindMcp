# Northwind MCP Setup Script for Warp Terminal (Windows PowerShell)
# This script leverages Warp's AI and package management features on Windows

$ErrorActionPreference = "Stop"

Write-Host "🚀 Setting up Northwind MCP Project with Warp (Windows)..." -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# Check if we're running in Warp (Windows doesn't have TERM_PROGRAM like macOS/Linux)
$isWarp = $false
try {
    # Try to detect Warp-specific environment or features
    if ($env:WARP_SESSION_ID -or $env:WARP_TERMINAL -or (Get-Process -Name "Warp" -ErrorAction SilentlyContinue)) {
        $isWarp = $true
        Write-Host "✅ Detected Warp Terminal!" -ForegroundColor Green
    }
} catch {
    # Assume we might be in Warp anyway
}

if (-not $isWarp) {
    Write-Host "⚠️  This script is optimized for Warp Terminal" -ForegroundColor Yellow
    Write-Host "   Consider downloading Warp from https://www.warp.dev/" -ForegroundColor Yellow
    Write-Host "   Continuing with standard setup..." -ForegroundColor Yellow
}

# Function to run commands with Warp AI suggestions
function Invoke-WithWarpHelp {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "🤖 Warp AI Tip: $Description" -ForegroundColor Cyan
    Write-Host "   Running: $Command" -ForegroundColor Gray
    Write-Host "   (In Warp, you can ask AI: 'What does this command do?')" -ForegroundColor Gray
    
    Invoke-Expression $Command
}

Write-Host "Installing prerequisites with package managers..." -ForegroundColor Yellow

# Check for Chocolatey and install if needed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
    Write-Host "🤖 Warp AI Tip: Chocolatey is like Homebrew for Windows" -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    refreshenv
    Write-Host "✅ Chocolatey installed" -ForegroundColor Green
} else {
    Write-Host "✅ Chocolatey is already installed" -ForegroundColor Green
}

# Check and install Docker
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is already installed" -ForegroundColor Green
} catch {
    Write-Host "Installing Docker Desktop..." -ForegroundColor Yellow
    Invoke-WithWarpHelp "choco install docker-desktop -y" "Install Docker Desktop via Chocolatey"
    
    Write-Host "📝 Note: Docker Desktop will be installed. You may need to restart after installation." -ForegroundColor Yellow
    Write-Host "💡 Warp Tip: After restart, Docker Desktop should start automatically" -ForegroundColor Cyan
    
    # Check if we need to restart
    $dockerInstalled = $false
    try {
        docker --version | Out-Null
        $dockerInstalled = $true
    } catch {
        Write-Host "⚠️  Docker installation completed. You may need to:" -ForegroundColor Yellow
        Write-Host "   1. Restart your computer" -ForegroundColor Yellow
        Write-Host "   2. Start Docker Desktop manually" -ForegroundColor Yellow
        Write-Host "   3. Re-run this script" -ForegroundColor Yellow
        Read-Host "Press Enter to continue or Ctrl+C to exit and restart"
    }
}

# Check and install .NET
try {
    dotnet --version | Out-Null
    Write-Host "✅ .NET SDK is already installed" -ForegroundColor Green
} catch {
    Write-Host "Installing .NET SDK..." -ForegroundColor Yellow
    Invoke-WithWarpHelp "choco install dotnet-sdk -y" "Install .NET SDK via Chocolatey"
    refreshenv
    Write-Host "✅ .NET SDK installed" -ForegroundColor Green
}

# Check and install Git (if not present)
try {
    git --version | Out-Null
    Write-Host "✅ Git is already installed" -ForegroundColor Green
} catch {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    Invoke-WithWarpHelp "choco install git -y" "Install Git via Chocolatey"
    refreshenv
    Write-Host "✅ Git installed" -ForegroundColor Green
}

Write-Host "✅ Prerequisites installation complete!" -ForegroundColor Green

# Setup environment file
Write-Host "Setting up environment file..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Created .env file from .env.example" -ForegroundColor Green
    } else {
        Write-Host "Creating basic .env file..." -ForegroundColor Yellow
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

# Build and start the database with Warp AI tips
Write-Host "Building and starting the Northwind database..." -ForegroundColor Yellow
Invoke-WithWarpHelp "docker-compose build" "Build the Docker image for SQL Server with Northwind database"
Invoke-WithWarpHelp "docker-compose up -d" "Start the database container with health checks"

# Wait for database with Warp-friendly progress
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
Write-Host "💡 Warp Tip: Try asking AI 'How can I check if a Docker container is healthy?'" -ForegroundColor Cyan

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
            Write-Host "🤖 Warp AI Help: Ask 'How do I troubleshoot Docker container startup issues?'" -ForegroundColor Cyan
            Write-Host "📝 Check logs with: docker logs northwind-database" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "⏳ Waiting for database... (attempt $attempt/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        $attempt++
    }
} while ($attempt -le $maxAttempts)

# Build the .NET solution
Write-Host "Building .NET solution..." -ForegroundColor Yellow
Invoke-WithWarpHelp "dotnet build" "Build the MCP server and client projects"

# Create Warp workflows suggestions
Write-Host "🎯 Creating helpful Warp shortcuts..." -ForegroundColor Magenta
Write-Host ""
Write-Host "Consider saving these as Warp workflows:" -ForegroundColor Cyan
Write-Host "  1. 'northwind-start' → docker-compose up -d" -ForegroundColor Gray
Write-Host "  2. 'northwind-test' → docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q `"SELECT COUNT(*) FROM Customers`"" -ForegroundColor Gray
Write-Host "  3. 'northwind-query' → docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C" -ForegroundColor Gray
Write-Host "  4. 'northwind-logs' → docker logs northwind-database" -ForegroundColor Gray
Write-Host "  5. 'mcp-run' → cd Client; dotnet run" -ForegroundColor Gray

Write-Host ""
Write-Host "🎉 Warp setup complete!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host ""
Write-Host "🤖 Next steps (try asking Warp AI for help with any of these):" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Test your setup:" -ForegroundColor White
Write-Host "   docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q `"SELECT COUNT(*) FROM Customers`"" -ForegroundColor Gray
Write-Host "   💡 Ask Warp AI: 'What does this command test?'" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Run the MCP client:" -ForegroundColor White
Write-Host "   cd Client; dotnet run" -ForegroundColor Gray
Write-Host "   💡 Ask Warp AI: 'What is Model Context Protocol?'" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Query the database:" -ForegroundColor White
Write-Host "   docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C" -ForegroundColor Gray
Write-Host "   💡 Try asking: 'Show me some SQL queries for the Northwind database'" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Optional - Set up AI features:" -ForegroundColor White
Write-Host "   dotnet user-secrets set `"ANTHROPIC_API_KEY`" `"your-key`" --project Client" -ForegroundColor Gray
Write-Host "   💡 Ask Warp AI: 'What are .NET user secrets?'" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌟 Warp Terminal Features to Try:" -ForegroundColor Magenta
Write-Host "   • Ctrl+Shift+P: Command palette" -ForegroundColor Gray
Write-Host "   • Ask AI: Natural language help" -ForegroundColor Gray
Write-Host "   • Workflows: Save command sequences" -ForegroundColor Gray
Write-Host "   • Share: Collaborate with teammates" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 For more info: check README.md" -ForegroundColor Cyan
Write-Host "🐛 Issues? Try: docker logs northwind-database or ask Warp AI for debugging help" -ForegroundColor Cyan
