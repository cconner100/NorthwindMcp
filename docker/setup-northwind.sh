#!/bin/bash

# Wait for SQL Server to be ready
until /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -C -Q "SELECT 1" > /dev/null 2>&1
do
  echo "Waiting for SQL Server to be ready..."
  sleep 5
done

echo "SQL Server is ready. Creating Northwind database..."

# First create the Northwind database
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -C -Q "CREATE DATABASE Northwind;"

# Then execute the Northwind database initialization script in the Northwind database context
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $MSSQL_SA_PASSWORD -C -d Northwind -i /usr/src/app/init-northwind.sql

echo "Northwind database setup completed!"
