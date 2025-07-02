using Microsoft.Data.SqlClient;
using System;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        var connectionString = "Server=localhost,1433;Database=Northwind;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;";
        
        try
        {
            using var connection = new SqlConnection(connectionString);
            await connection.OpenAsync();
            
            using var command = new SqlCommand("SELECT TOP 3 CustomerID, CompanyName FROM Customers", connection);
            using var reader = await command.ExecuteReaderAsync();
            
            Console.WriteLine("Successfully connected to Northwind database!");
            Console.WriteLine("First 3 customers:");
            Console.WriteLine("CustomerID | CompanyName");
            Console.WriteLine("-----------|------------");
            
            while (await reader.ReadAsync())
            {
                Console.WriteLine($"{reader.GetString(0),-10} | {reader.GetString(1)}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error connecting to database: {ex.Message}");
        }
    }
}
