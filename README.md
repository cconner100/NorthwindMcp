# Northwind MCP Server

A Model Context Protocol (MCP) server implementation that provides access to the classic Northwind database through standardized tools and resources. This project includes a complete Docker setup for easy deployment and sharing.

## Before you start recomended reading

- MCP Specifications https://github.com/modelcontextprotocol/servers
- Microsoft MCP C# repository https://github.com/modelcontextprotocol/csharp-sdk

## Installing Prerequisites
These are pre-requisites for running the Northwind MCP server. You can use Warp Terminal for a streamlined installation experience, or follow manual installation steps.
- Docker and Docker Compose
- .NET 8.0 SDK
- Make (optional, but recommended)

### Option A: Using Warp Terminal (Recommended)

[Warp](#warp-point) is a modern terminal with built-in package management that makes installing prerequisites easy:

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

### Option B: Manual Installation

**Docker:**
- **macOS/Windows:** Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/)
- **Linux:** Follow distribution-specific instructions at [docs.docker.com](https://docs.docker.com/engine/install/)

**.NET 8.0 SDK:**
- Download from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet/8.0)

**Make (optional):**
- **macOS:** Install Xcode Command Line Tools: `xcode-select --install`
- **Windows:** Install via Chocolatey: `choco install make` or use Git Bash
- **Linux:** Usually pre-installed, or `sudo apt install make` / `sudo yum install make`

## Clone and Setup Database
### Option A: Automated Setup (Recommended)

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

### Option B: Manual Setup

```bash
git clone https://github.com/cconner100/NorthwindMcp.git
cd NorthwindMcp

# Copy environment template and customize if needed
cp .env.example .env

# Build and start the Northwind database
make up
```


You can verify Database Connection by using the following command:

```bash
# Test database connectivity
make test

# Or open an interactive SQL shell
make query
```

## Set up Configuration
### Set up OpenAI API key
If you do not want to use the AI features, you can skip this step. If you want to use the AI features, you must set your OpenAI API key. 
To set your OpenAI API key, edit the OpenAI configuration properties in the *appsettings.json* file in the *Client** project:

 ```json
 "OpenAI": {
    "Endpoint": "your-azure-openai-endpoint",
    "Key": "your-azure-openai-key",
    "DeploymentName": "your-deployment-name"
  },
 ```
### Set up MCP Server Configuration
Change Arguments in the *appsettings.json* file in the *Client* project to point to the NorthwindMcpServer.csproj file. This is required for the AI features to work properly.
```json
    "ZiiDMSNextGen": {
      "Arguments": [
        "run",
        "--project",
        "{YOUR-FULL-PATH}\\NorthwindMcpServer.csproj"
      ],
 ```

### Set up for debugging purposes
You need to add more arguments to the *appsettings.json* file in the *Client* project to enable debugging. This is useful if you want to debug the MCP server while running it from the client.
```json
    "ZiiDMSNextGen": {
      "Arguments": [
        "run",
        "--project",
        "{YOUR-FULL-PATH}\\NorthwindMcpServer.csproj"
        "--",
        "--attach-debugger"
      ],
 ```

## Let's run the MCP Server
### Build the project
```bash
dotnet build
```

### Run the project
The client will automatically start the server as a subprocess:
After running the command, you can attache the debugger to the server process if you have set up the debugging arguments in the *appsettings.json* file.

```bash
cd Client
dotnet run
```
---

*Happy querying with MCP! 🎯*


## 📇 Appendix:

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

### Project Structure

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

### Key Technologies

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

<a name="warp-point"></a>
### 💻 Recommended Terminal: Warp

This project works great with [Warp Terminal](https://www.warp.dev/), which offers:

- **Smart package management** - Install Docker and .NET with simple commands
- **AI-powered command suggestions** - Get help with Docker and SQL commands
- **Beautiful output formatting** - Enhanced readability for database queries
- **Built-in workflows** - Save and share common command sequences
- **Collaborative features** - Share terminal sessions with your team

Warp makes managing this project's dependencies and daily workflows much easier!

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