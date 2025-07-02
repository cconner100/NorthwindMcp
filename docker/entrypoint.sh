#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start
echo "Waiting for SQL Server to start..."
sleep 30

# Run the setup script to create Northwind database
echo "Setting up Northwind database..."
/usr/src/app/setup-northwind.sh

# Keep the container running
wait
