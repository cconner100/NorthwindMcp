#!/bin/bash

cd Server

# Test the server by running it with a simple command
echo "Testing Northwind Server..."
echo "get_customers" | dotnet run --no-build

echo -e "\n\nTesting with name filter..."
echo "get_customers Alfreds" | dotnet run --no-build
