# Northwind Database Docker Management
# ====================================

.PHONY: help build up down logs clean test query rebuild

# Default target
help: ## Show this help message
	@echo "Northwind Database Docker Commands"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Northwind database Docker image
	docker-compose build

up: ## Start the Northwind database container
	docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 10
	@echo "✅ Northwind database is starting up!"
	@echo "📍 Connection: localhost:1433"
	@echo "👤 Username: sa"
	@echo "🔑 Password: YourStrong@Passw0rd"
	@echo "🗄️  Database: Northwind"

down: ## Stop and remove the Northwind database container
	docker-compose down

logs: ## Show container logs
	docker-compose logs -f northwind-db

clean: ## Remove container, images, and volumes (WARNING: This deletes all data!)
	docker-compose down -v --rmi all
	docker system prune -f

test: ## Test database connection and verify Northwind data
	@echo "Testing database connection..."
	@docker exec northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C -Q "SELECT TOP 3 CustomerID, CompanyName FROM Northwind.dbo.Customers" || echo "❌ Connection failed"

query: ## Open an interactive SQL session
	@echo "Opening SQL Server command line..."
	@echo "Type 'exit' to quit"
	@docker exec -it northwind-database /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -C

rebuild: ## Rebuild and restart everything
	$(MAKE) down
	$(MAKE) build
	$(MAKE) up

status: ## Show container status
	docker-compose ps

# Development shortcuts
start: up ## Alias for 'up'
stop: down ## Alias for 'down'
restart: rebuild ## Alias for 'rebuild'
