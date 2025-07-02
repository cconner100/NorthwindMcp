using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Microsoft.Data.SqlClient;
using System.ComponentModel;
using System.Text.Json;
using ModelContextProtocol;
using ModelContextProtocol.Server;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace NorthwindMcpServer;

public partial class Program
{
    public static async Task Main(string[] args)
    {
        // Check if the "--attach-debugger" argument is present
        if (args.Contains("--attach-debugger"))
        {
            Console.WriteLine("Waiting for debugger to attach...");
            while (!System.Diagnostics.Debugger.IsAttached)
            {
                System.Threading.Thread.Sleep(100);
            }
        }


        var builder = Host.CreateApplicationBuilder(args);

        // Configure logging to stderr
        builder.Logging.AddConsole(options =>
        {
            options.LogToStandardErrorThreshold = LogLevel.Debug;
        });

        // Add MCP server with Northwind tools
        builder.Services
            .AddMcpServer()
            .WithStdioServerTransport()
            .WithTools<NorthwindTools>();

        // Add services
        builder.Services.AddSingleton<NorthwindService>();

        await builder.Build().RunAsync();
    }
}


[McpServerToolType]
public class NorthwindTools
{
    [McpServerTool(Name = "get_customers")]
    [Description("Get customers from the Northwind database with optional name filtering.")]
    public static async Task<string> GetCustomers(
        NorthwindService northwindService,
        [Description("Optional customer name filter for partial matching")] string? name = null)
    {
        return await northwindService.GetCustomersAsync(name);
    }
}

public class NorthwindService
{
    private readonly IConfiguration _configuration;
    private readonly string _connectionString;

    public NorthwindService(IConfiguration configuration)
    {
        _configuration = configuration;
        _connectionString = _configuration.GetConnectionString("DefaultConnection") 
            ?? "Server=localhost,1433;Database=Northwind;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;";
    }

    public async Task<string> GetCustomersAsync(string? name = null)
    {
        var customers = new List<Customer>();

        using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        var commandText = "SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax FROM Customers";
        if (!string.IsNullOrWhiteSpace(name))
        {
            commandText += " WHERE CompanyName LIKE @name";
        }

        using var command = new SqlCommand(commandText, connection);
        if (!string.IsNullOrWhiteSpace(name))
        {
            command.Parameters.AddWithValue("@name", $"%{name}%");
        }

        using var reader = await command.ExecuteReaderAsync();
        while (await reader.ReadAsync())
        {
            customers.Add(new Customer
            {
                CustomerID = reader.GetString(0),
                CompanyName = reader.GetString(1),
                ContactName = reader.GetString(2),
                ContactTitle = reader.GetString(3),
                Address = reader.GetString(4),
                City = reader.GetString(5),
                Region = reader.IsDBNull(6) ? null : reader.GetString(6),
                PostalCode = reader.IsDBNull(7) ? null : reader.GetString(7),
                Country = reader.GetString(8),
                Phone = reader.GetString(9),
                Fax = reader.IsDBNull(10) ? null : reader.GetString(10),
            });
        }

        return JsonSerializer.Serialize(customers, new JsonSerializerOptions { WriteIndented = true });
    }
}

public class Customer
{
    public string CustomerID { get; set; } = string.Empty;
    public string CompanyName { get; set; } = string.Empty;
    public string ContactName { get; set; } = string.Empty;
    public string ContactTitle { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string? Region { get; set; }
    public string? PostalCode { get; set; }
    public string Country { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string? Fax { get; set; }
}
