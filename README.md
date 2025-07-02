# Northwind MCP Server

A Model Context Protocol (MCP) server implementation that provides access to the classic Northwind database through standardized tools and resources. This project includes a complete Docker setup for easy deployment and sharing.

## Before you start recomended reading
MCP Specifications https://github.com/modelcontextprotocol/servers
Microsoft MCP C# repository https://github.com/modelcontextprotocol/csharp-sdk

## 💻 Recommended Terminal: Warp

This project works great with [Warp Terminal](https://www.warp.dev/), which offers:

- **Smart package management** - Install Docker and .NET with simple commands
- **AI-powered command suggestions** - Get help with Docker and SQL commands
- **Beautiful output formatting** - Enhanced readability for database queries
- **Built-in workflows** - Save and share common command sequences
- **Collaborative features** - Share terminal sessions with your team

Warp makes managing this project's dependencies and daily workflows much easier!

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Make (optional, but recommended)
- .NET 8.0 SDK

### Installing Prerequisites

#### Option A: Using Warp Terminal (Recommended)

[Warp](https://www.warp.dev/) is a modern terminal with built-in package management that makes installing prerequisites easy:

1. **Install Warp Terminal:**
   - **All platforms:** Download from [warp.dev](https://www.warp.dev/)
   - **macOS via Homebrew:** `brew install --cask warp`
   - **Windows via Chocolatey:** `choco install warp`

2. **Install Docker using Warp:**
   
   **macOS:**
   ```bash
   # In Warp terminal, type:
   warp install docker
   
   # Or use Homebrew within Warp:
   brew install --cask docker
   ```
   
   **Windows:**
   ```powershell
   # Install Chocolatey first (if not installed):
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   
   # Then install Docker:
   choco install docker-desktop -y
   ```

3. **Install .NET SDK using Warp:**
   
   **macOS:**
   ```bash
   # In Warp terminal:
   warp install dotnet
   
   # Or via Homebrew:
   brew install dotnet
   ```
   
   **Windows:**
   ```powershell
   # Via Chocolatey:
   choco install dotnet-sdk -y
   ```

4. **Install Make (optional):**
   
   **macOS:**
   ```bash
   # via Xcode Command Line Tools:
   xcode-select --install
   
   # Or via Homebrew:
   brew install make
   ```
   
   **Windows:**
   ```powershell
   # Via Chocolatey:
   choco install make -y
   ```

#### Option B: Manual Installation

**Docker:**
- **macOS/Windows:** Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/)
- **Linux:** Follow distribution-specific instructions at [docs.docker.com](https://docs.docker.com/engine/install/)

**.NET 8.0 SDK:**
- Download from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet/8.0)

**Make (optional):**
- **macOS:** Install Xcode Command Line Tools: `xcode-select --install`
- **Windows:** Install via Chocolatey: `choco install make` or use Git Bash
- **Linux:** Usually pre-installed, or `sudo apt install make` / `sudo yum install make`

### 1. Clone and Setup Database

#### Option A: Automated Setup (Recommended)

**macOS/Linux:**
```bash
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Run the setup script - it handles everything!
./setup.sh
```

**macOS with Warp Terminal (Enhanced Experience):**
```bash
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Run the Warp-optimized setup script
./warp-setup.sh
```

**Windows with Warp Terminal (Enhanced Experience):**
```powershell
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Run the Warp-optimized setup script
.\warp-setup.ps1
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Run the setup script - it handles everything!
.\setup.ps1
```

**Windows (Command Prompt):**
```cmd
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Run the setup script - it handles everything!
setup.bat
```

#### Option B: Manual Setup

```bash
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Copy environment template and customize if needed
cp .env.example .env

# Build and start the Northwind database
make up
```

### 2. Verify Database Connection

```bash
# Test database connectivity
make test

# Or open an interactive SQL shell
make query
```

## Note before you run you must edit the appsettings.json file in the client to set your OpenAI API key if you want to use the AI features. If you do not want to use the AI features, you can skip this step.
 please edit the following line in the appsettings.json file in the Client project:
 ```json
 "OpenAI": {
    "Endpoint": "your-azure-openai-endpoint",
    "Key": "your-azure-openai-key",
    "DeploymentName": "your-deployment-name"
  },
    "MCPServers": {
    "ZiiDMSNextGen": {
      "Name": "Northwind Server",
      "Command": "dotnet",
      "Arguments": [
        "run",
        "--project",
        "C:\\Users\\Admin\\source\\repos\\cconner100\\NorthwindMcp\\Server\\NorthwindMcpServer.csproj"
       
      ],
      "Enabled": true,
      "WorkingDirectory": null,
      "EnvironmentVariables": null
    }
  }
  ```
  Enter your keys and the complete path to the NorthwindMcpServer.csproj file in the Arguments section. This is required for the AI features to work properly.
### 3. Run the MCP Server

```bash
# Build the solution
dotnet build

# Run the client (recommended - starts server automatically)
cd Client
dotnet run
```

## 📦 What's Included

### Docker Environment

- **SQL Server 2022** running the Northwind database
- **Persistent storage** with Docker volumes
- **Health checks** for reliable startup
- **Environment-based configuration**
- **Easy deployment** with Docker Compose and Makefile

### MCP Implementation

- **Server**: Console application that connects to Northwind database and provides customer query functionality
- **Client**: Test client with AI integration (Anthropic Claude) for natural language queries
- **Database**: SQL Server 2022 running in Docker with fully populated Northwind sample database

## Features

### Server Tools
- `GetCustomers`: Query the Customers table with optional name filtering
  - Parameters:
    - `name` (optional): Filter customers by company name (partial match)
  - Returns: List of Customer objects with all fields

### Client Modes
1. **AI Mode**: Uses Anthropic Claude to interpret natural language queries
2. **Direct Tool Mode**: Direct interaction with MCP tools (fallback when no API key)

## Prerequisites

1. **SQL Server with Northwind Database**: 
   - Ensure your Docker container is running: `docker ps` should show `northwind-db`
   - Connection: `localhost:1433` with credentials `sa/YourStrong@Passw0rd`

2. **.NET 8.0 SDK**

3. **Anthropic API Key** (optional, for AI features):
   ```bash
   dotnet user-secrets set "ANTHROPIC_API_KEY" "your-api-key-here" --project Client
   ```

## Building

From the `NorthwindMcp` directory:

```bash
dotnet build
```

## Running

### Option 1: Run Client (Recommended)
The client will automatically start the server as a subprocess:

```bash
cd Client
dotnet run
```

### Option 2: Run Server and Client Separately

Terminal 1 (Server):
```bash
cd Server
dotnet run
```

Terminal 2 (Client):
```bash
cd Client
dotnet run
```

## Usage Examples

### With AI (if ANTHROPIC_API_KEY is configured):
```
> Show me all customers
> Find customers with 'Alfreds' in their name
> How many customers are in Germany?
> List customers from London
```

### Direct Tool Mode (no API key):
```
> all                    # Get all customers
> search Alfreds         # Search for customers containing "Alfreds"
> exit                   # Exit application
```

## Project Structure

```
NorthwindMcp/
├── Directory.Packages.props  # Centralized package management
├── NorthwindMcp.sln         # Solution file
├── Server/
│   ├── NorthwindMcpServer.csproj
│   └── Program.cs           # MCP server implementation
├── Client/
│   ├── NorthwindMcpClient.csproj
│   └── Program.cs           # MCP client implementation
└── README.md
```

## Key Technologies

- **Model Context Protocol (MCP)**: For server-client communication
- **Microsoft.Data.SqlClient**: SQL Server database connectivity
- **Anthropic SDK**: AI integration for natural language processing
- **Microsoft.Extensions.AI**: AI abstraction layer
- **Microsoft.Extensions.Hosting**: Application hosting and dependency injection

## Database Connection

The server connects to SQL Server using:
- **Server**: `localhost,1433`
- **Database**: `Northwind` 
- **Authentication**: SQL Server (`sa` user)
- **Password**: `YourStrong@Passw0rd`
- **Trust Server Certificate**: `true` (for development)

## Troubleshooting

1. **Database Connection Issues**: 
   - Ensure the Docker container is running: `docker ps`
   - Test connection: `docker exec northwind-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT 1"`

2. **MCP Communication Issues**:
   - Check that both client and server are using compatible MCP versions
   - Review console logs for error messages

3. **AI Integration Issues**:
   - Verify ANTHROPIC_API_KEY is set correctly
   - Check API key permissions and rate limits

## 🛠️ Docker Commands

### macOS/Linux (with Make)

| Command | Description |
|---------|-------------|
| `make up` | Start the Northwind database container |
| `make down` | Stop and remove the container |
| `make build` | Build the Docker image |
| `make logs` | View container logs |
| `make test` | Test database connectivity |
| `make query` | Open interactive SQL shell |
| `make clean` | Remove all containers, images, and volumes |
| `make rebuild` | Clean, build, and restart everything |
| `make status` | Show container status |

### Windows/Cross-platform (Docker Compose)

| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start the Northwind database container |
| `docker-compose down` | Stop and remove the container |
| `docker-compose build` | Build the Docker image |
| `docker-compose logs northwind-db` | View container logs |
| `docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT COUNT(*) FROM Customers"` | Test database connectivity |
| `docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C` | Open interactive SQL shell |
| `docker-compose down -v && docker system prune -f` | Remove all containers, images, and volumes |
| `docker-compose down && docker-compose build && docker-compose up -d` | Clean, build, and restart everything |
| `docker-compose ps` | Show container status |

## ⚙️ Configuration

### Environment Variables

Copy `.env.example` to `.env` and customize:

```bash
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
```

### Database Connection String

```
Server=localhost,1433;Database=Northwind;User Id=sa;Password=<SA_PASSWORD>;TrustServerCertificate=true;
```

## 📊 Database Schema

The Northwind database includes these main tables:
- **Customers** - Customer information
- **Orders** - Order records
- **Products** - Product catalog
- **Categories** - Product categories
- **Suppliers** - Supplier information
- **Employees** - Employee records
- **Order Details** - Line items for orders

## 🔧 Development

### Project Structure

```
NorthwindMcp/
├── docker/                 # Docker configuration
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── init-northwind.sql
│   └── setup-northwind.sh
├── Server/                 # MCP Server implementation
│   ├── Program.cs
│   └── NorthwindMcpServer.csproj
├── Client/                 # MCP Client implementation
│   ├── Program.cs
│   └── NorthwindMcpClient.csproj
├── docker-compose.yml      # Container orchestration
├── Makefile               # Development commands (macOS/Linux)
├── setup.sh               # Setup script (macOS/Linux)
├── warp-setup.sh          # Setup script (Warp Terminal optimized - macOS/Linux)
├── warp-setup.ps1         # Setup script (Warp Terminal optimized - Windows)
├── setup.ps1              # Setup script (Windows PowerShell)
├── setup.bat              # Setup script (Windows Command Prompt)
├── .env.example           # Environment template
├── .gitignore             # Git ignore file
├── .dockerignore          # Docker ignore file
├── Directory.Packages.props # Package management
├── NorthwindMcp.sln       # Solution file
└── README.md              # This file
```

### Adding New MCP Tools

1. Add a new method to the server in `Server/Program.cs`
2. Follow the existing pattern for database queries
3. Return JSON-serialized data
4. Test with the client

### Database Customization

- Modify `docker/init-northwind.sql` to add custom tables or data
- Update `docker/setup-northwind.sh` for additional initialization
- Rebuild with `make rebuild`

## 📝 Sample Queries

### Via SQL Shell (`make query`)

```sql
-- List all customers
SELECT CustomerID, CompanyName, Country FROM Customers;

-- Orders by customer
SELECT c.CompanyName, COUNT(o.OrderID) as OrderCount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
ORDER BY OrderCount DESC;

-- Top products by sales
SELECT TOP 10 p.ProductName, SUM(od.Quantity * od.UnitPrice) as Revenue
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY p.ProductName
ORDER BY Revenue DESC;
```

### Via MCP Client

```bash
# Natural language queries (with AI)
> Show me all customers from Germany
> Find customers with 'Alfreds' in their name
> How many customers do we have?

# Direct tool queries
> all
> search London
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make test` and `dotnet test`
5. Submit a pull request

## 📜 License

This project is open source. The Northwind database is a Microsoft sample database.

## 🆘 Support

- Check the [Issues](../../issues) for common problems
- Review container logs: `make logs`
- Test database connectivity: `make test`
- Verify environment configuration: `cat .env`

### Warp Terminal Tips

If you're using Warp, try these helpful commands:

```bash
# Ask Warp AI for Docker help
# Type in terminal: "How do I check if Docker is running?"

# Use Warp's command palette (Cmd+P on macOS)
# Search for "docker" to see available commands

# Create a Warp workflow for this project
# Save common commands like "make up", "make test", "dotnet run"

# Share your terminal session
# Use Warp's sharing feature to collaborate on debugging
```

### Common Issues

**Docker not starting:**
```bash
# In Warp, check Docker status
docker info

# If Docker Desktop isn't running, start it
open -a Docker  # macOS
```

**Permission issues (Linux):**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Port conflicts:**
```bash
# Check what's using port 1433
lsof -i :1433  # macOS/Linux
netstat -ano | findstr :1433  # Windows
```

---

*Happy querying with MCP! 🎯*
