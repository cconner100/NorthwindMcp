@echo off
REM Northwind MCP Setup Script (Windows Batch)
REM This script sets up the Northwind MCP project for first-time use

echo 🚀 Setting up Northwind MCP Project...
echo ======================================

REM Check for Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)
echo ✅ Docker found

REM Check for Docker Compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    docker compose version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Docker Compose is not installed. Please install Docker Compose first.
        pause
        exit /b 1
    )
    echo ✅ Docker Compose v2 found
) else (
    echo ✅ Docker Compose found
)

REM Check for .NET
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET SDK is not installed. Please install .NET 8.0 SDK first.
    pause
    exit /b 1
)
echo ✅ .NET SDK found

echo ✅ Prerequisites check passed!

REM Setup environment file
echo Setting up environment file...
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo ✅ Created .env file from .env.example
    ) else (
        echo ⚠️  .env.example not found. Creating basic .env file...
        (
            echo # Database Configuration
            echo SA_PASSWORD=YourStrong@Passw0rd
            echo MSSQL_PID=Developer
            echo ACCEPT_EULA=Y
            echo.
            echo # Container Configuration
            echo CONTAINER_NAME=northwind-database
            echo HOST_PORT=1433
            echo.
            echo # Connection Details
            echo SERVER_NAME=localhost
            echo DATABASE_NAME=Northwind
            echo.
            echo # Healthcheck
            echo HEALTHCHECK_ENABLED=true
            echo.
            echo # Persistence
            echo ENABLE_PERSISTENCE=true
        ) > .env
        echo ✅ Created basic .env file
    )
) else (
    echo ✅ .env file already exists
)

REM Build and start the database
echo Building and starting the Northwind database...
docker-compose build
if %errorlevel% neq 0 (
    docker compose build
    if %errorlevel% neq 0 (
        echo ❌ Failed to build database container
        pause
        exit /b 1
    )
)

docker-compose up -d
if %errorlevel% neq 0 (
    docker compose up -d
    if %errorlevel% neq 0 (
        echo ❌ Failed to start database container
        pause
        exit /b 1
    )
)

REM Wait for database to be ready
echo Waiting for database to be ready...
set /a maxAttempts=30
set /a attempt=1

:waitLoop
docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "SELECT 1" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Database is ready!
    goto dbReady
)

if %attempt% geq %maxAttempts% (
    echo ❌ Database failed to start after %maxAttempts% attempts
    echo Please check the logs with: docker logs northwind-database
    pause
    exit /b 1
)

echo ⏳ Waiting for database... (attempt %attempt%/%maxAttempts%)
timeout /t 2 /nobreak >nul
set /a attempt+=1
goto waitLoop

:dbReady

REM Build the .NET solution
echo Building .NET solution...
dotnet build
if %errorlevel% neq 0 (
    echo ❌ Failed to build .NET solution
    pause
    exit /b 1
)
echo ✅ .NET solution built successfully

echo.
echo 🎉 Setup complete!
echo ==================
echo.
echo Next steps:
echo 1. To run the MCP client (recommended):
echo    cd Client ^&^& dotnet run
echo.
echo 2. To run server and client separately:
echo    Terminal 1: cd Server ^&^& dotnet run
echo    Terminal 2: cd Client ^&^& dotnet run
echo.
echo 3. To test the database connection:
echo    docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "SELECT COUNT(*) FROM Customers"
echo.
echo 4. To open an interactive SQL shell:
echo    docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C
echo.
echo 5. Optional: Set up Anthropic API key for AI features:
echo    dotnet user-secrets set "ANTHROPIC_API_KEY" "your-api-key" --project Client
echo.
echo 📚 For more information, check the README.md file
echo 🐛 If you encounter issues, run: docker logs northwind-database

pause
