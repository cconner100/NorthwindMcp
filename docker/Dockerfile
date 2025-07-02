# SQL Server 2022 with Northwind Database for ARM64
FROM mcr.microsoft.com/mssql/server:2022-latest

# Set environment variables
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=YourStrong@Passw0rd
ENV MSSQL_PID=Developer

# Switch to root to install dependencies
USER root

# Install curl for downloading scripts
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for initialization scripts
RUN mkdir -p /usr/src/app

# Copy the initialization scripts
COPY init-northwind.sql /usr/src/app/
COPY setup-northwind.sh /usr/src/app/
COPY entrypoint.sh /usr/src/app/

# Make scripts executable
RUN chmod +x /usr/src/app/setup-northwind.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Switch back to mssql user
USER mssql

# Expose SQL Server port
EXPOSE 1433

# Use custom entrypoint
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
