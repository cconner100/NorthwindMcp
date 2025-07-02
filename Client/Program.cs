using Microsoft.Extensions.AI;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Client;
using Azure.AI.OpenAI;
using Azure;
using System.Text.Json;
using System.Diagnostics;
using System.Threading.Tasks;
using System.IO;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Linq;

class Program
{
static async Task Main(string[] args)
{
    // Create a logger for debugging
    using var loggerFactory = LoggerFactory.Create(builder => builder.AddConsole());
    var logger = loggerFactory.CreateLogger<Program>();

    // Load configuration
    var environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
    var config = new ConfigurationBuilder()
        .SetBasePath(Directory.GetCurrentDirectory())
        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
        .AddJsonFile($"appsettings.{environment}.json", optional: true, reloadOnChange: true)
        .AddEnvironmentVariables()
        .Build();

    Console.WriteLine($"Environment: {environment}");

    Console.WriteLine("MCP Client Prompt Application");
    Console.WriteLine("==============================");
    Console.WriteLine();

    try
    {

        // Initialize Azure OpenAI Client
        logger.LogInformation("Initializing Azure OpenAI client...");
        var azureOpenAiEndpoint = config["OpenAI:Endpoint"] ?? string.Empty;
        var azureOpenAiKey = config["OpenAI:Key"] ?? string.Empty;
        var deploymentName = config["OpenAI:DeploymentName"] ??string.Empty;

        IChatClient? chatClient = null;


        if (!string.IsNullOrEmpty(azureOpenAiKey) && !string.IsNullOrEmpty(azureOpenAiEndpoint) && !string.IsNullOrEmpty(deploymentName))
        {
            try
            {
                var azureOpenAiClient = new AzureOpenAIClient(new Uri(azureOpenAiEndpoint), new AzureKeyCredential(azureOpenAiKey));
                var azureChatClient = azureOpenAiClient.GetChatClient(deploymentName);
                // Use the Microsoft.Extensions.AI extension method to convert to IChatClient
                chatClient = azureChatClient.AsIChatClient();
                Console.WriteLine("✓ Connected to Azure OpenAI");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Failed to connect to Azure OpenAI");
                Console.WriteLine($"✗ Failed to connect to Azure OpenAI: {ex.Message}");
                Console.WriteLine("Continuing in demo mode...");
            }
        }
        else
        {
            Console.WriteLine("⚠ Demo mode: Please update appsettings.json with your Azure OpenAI credentials for full functionality.");
        }

        Console.WriteLine();

        // Connect to MCP servers
        Console.WriteLine("Connecting to MCP servers...");
        List<IMcpClient> mcpClients = new();
        List<McpClientTool> allTools = new();

        // Load MCP server configurations
        var mcpServersSection = config.GetSection("MCPServers");
        var mcpServerConfigs = new Dictionary<string, McpServerConfig>();

        foreach (var serverSection in mcpServersSection.GetChildren())
        {
            var serverConfig = new McpServerConfig();
            serverSection.Bind(serverConfig);

            if (serverConfig.Enabled)
            {
                mcpServerConfigs.Add(serverSection.Key, serverConfig);
            }
        }

        Console.WriteLine($"Found {mcpServerConfigs.Count} enabled MCP server(s) in configuration");

        // Connect to each enabled MCP server
        foreach (var kvp in mcpServerConfigs)
        {
            var serverId = kvp.Key;
            var serverConfig = kvp.Value;

            try
            {
                Console.WriteLine($"Connecting to {serverConfig.Name}...");

                var clientTransport = new StdioClientTransport(new StdioClientTransportOptions
                {
                    Name = serverConfig.Name,
                    Command = serverConfig.Command,
                    Arguments = serverConfig.Arguments,
                    WorkingDirectory = serverConfig.WorkingDirectory,
                    EnvironmentVariables = serverConfig.EnvironmentVariables
                });

                var mcpClient = await McpClientFactory.CreateAsync(clientTransport, loggerFactory: loggerFactory);
                mcpClients.Add(mcpClient);

                var tools = await mcpClient.ListToolsAsync();
                allTools.AddRange(tools);
                Console.WriteLine($"✓ Connected to {serverConfig.Name}: {tools.Count} tools available");
                foreach (var tool in tools)
                {
                    Console.WriteLine($"  - {tool.Name}: {tool.Description}");
                }
            }
            catch (Exception ex)
            {
                logger.LogWarning(ex, "Failed to connect to {ServerName}", serverConfig.Name);
                Console.WriteLine($"✗ Failed to connect to {serverConfig.Name}: {ex.Message}");
            }
        }
        Console.WriteLine();
        Console.WriteLine($"Total tools available: {allTools.Count}");
        Console.WriteLine();

        // Enhanced chat client with tool support
        if (chatClient != null && allTools.Count > 0)
        {
            chatClient = chatClient.AsBuilder()
                .UseFunctionInvocation()
                .Build();
            Console.WriteLine("✓ Azure OpenAI configured with MCP tool integration");
        }
        else if (chatClient != null)
        {
            Console.WriteLine("✓ Azure OpenAI configured (no MCP tools available)");
        }

        Console.WriteLine();
        Console.WriteLine("========================================");
        Console.WriteLine("Chat with AI Assistant + MCP Tools");
        Console.WriteLine("========================================");

        // Main conversation loop
        var messages = new List<ChatMessage>();

        // Add system prompt from configuration
        var systemPrompt = config["SystemPrompt"] ??
                          "You are a helpful AI assistant with access to ZiiDMS-NextGen tools. " +
                          "You can help users with dealership management, financial data, customer information, " +
                          "and vendor management. Always be professional and provide accurate information based " +
                          "on the available tools and data.";
        messages.Add(new ChatMessage(ChatRole.System, systemPrompt));

        // display initial system prompt
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine(systemPrompt);
        Console.WriteLine("To change this prompt, edit the 'appsettings.json' file.");
        Console.ResetColor();
        while (true)
        {
            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write("You: ");
            Console.ResetColor();

            string? input = Console.ReadLine();

            if (string.IsNullOrWhiteSpace(input) || input.Equals("exit", StringComparison.OrdinalIgnoreCase))
            {
                Console.WriteLine("\nGoodbye!");
                break;
            }

            messages.Add(new ChatMessage(ChatRole.User, input));

            Console.WriteLine();
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Write("🤔 Assistant: ");
            Console.ResetColor();

            try
            {
                if (chatClient != null)
                {
                    // Use real Azure OpenAI with tools
                    var options = new ChatOptions();
                    if (allTools.Count > 0)
                    {
                        options.Tools = allTools.Cast<AITool>().ToList();
                    }

                    var response = await chatClient.GetResponseAsync(messages, options, CancellationToken.None);

                    Console.ForegroundColor = ConsoleColor.Green;
                    var responseText = response.ToString() ?? "No response content";
                    Console.WriteLine(responseText);
                    Console.ResetColor();


                    messages.Add(new ChatMessage(ChatRole.Assistant, responseText));

                    // Generate follow-up questions based on the response
                    if (config.GetValue<bool>("FollowUpQuestions:EnableSuggestions", true))
                    {
                        var suggestions = await SuggestFollowUpQuestions(chatClient, responseText, allTools, logger, config);
                        if (!string.IsNullOrEmpty(suggestions))
                        {
                            // Check if user wants to select a suggested question
                            var selection = Console.ReadLine();
                            if (!string.IsNullOrEmpty(selection) && int.TryParse(selection, out int questionNumber))
                            {
                                var questionLines = suggestions.Split('\n', StringSplitOptions.RemoveEmptyEntries);
                                if (questionNumber > 0 && questionNumber <= questionLines.Length)
                                {
                                    var selectedQuestion = questionLines[questionNumber - 1];
                                    // Remove the number prefix (e.g., "1. " or "1) ")
                                    selectedQuestion = System.Text.RegularExpressions.Regex.Replace(selectedQuestion, @"^\d+[\.\)]\s*", "").Trim();

                                    Console.ForegroundColor = ConsoleColor.Cyan;
                                    Console.WriteLine($"Selected question: {selectedQuestion}");
                                    Console.ResetColor();

                                    // Add the selected question as the next user input
                                    messages.Add(new ChatMessage(ChatRole.User, selectedQuestion));

                                    Console.WriteLine();
                                    Console.ForegroundColor = ConsoleColor.Yellow;
                                    Console.Write("🤔 Assistant: ");
                                    Console.ResetColor();

                                    // Get response for the selected question
                                    var followUpResponse = await chatClient.GetResponseAsync(messages, options, CancellationToken.None);
                                    var followUpText = followUpResponse.ToString() ?? "No response content";

                                    Console.ForegroundColor = ConsoleColor.Green;
                                    Console.WriteLine(followUpText);
                                    Console.ResetColor();

                                    messages.Add(new ChatMessage(ChatRole.Assistant, followUpText));
                                }
                            }
                        }
                    }

                    // Note: Tool usage information would be shown here in a complete implementation
                }
                else
                {
                    // Demo mode - simulate responses
                    await Task.Delay(500); // Simulate thinking

                    Console.ForegroundColor = ConsoleColor.Green;
                    if (allTools.Count > 0)
                    {
                        Console.WriteLine($"[Demo Mode] I understand your question: '{input}'.");
                        Console.WriteLine($"In a real deployment with Azure OpenAI, I would process this using {allTools.Count} available MCP tools:");
                        foreach (var tool in allTools.Take(3))
                        {
                            Console.WriteLine($"  • {tool.Name}: {tool.Description}");
                        }
                        if (allTools.Count > 3)
                        {
                            Console.WriteLine($"  • ... and {allTools.Count - 3} more tools");
                        }
                    }
                    else
                    {
                        Console.WriteLine($"[Demo Mode] I understand your question: '{input}', but no MCP tools are currently available.");
                    }
                    Console.ResetColor();

                    messages.Add(new ChatMessage(ChatRole.Assistant, "Demo response generated."));
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Error: {ex.Message}");
                Console.ResetColor();
                logger.LogError(ex, "Error processing chat message");
            }
        }

        // Cleanup
        Console.WriteLine("\nCleaning up connections...");
        foreach (var client in mcpClients)
        {
            try
            {
                await client.DisposeAsync();
            }
            catch (Exception ex)
            {
                logger.LogWarning(ex, "Error disposing MCP client");
            }
        }
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "An error occurred during application startup");
        Console.WriteLine($"Error: {ex.Message}");
    }
}

    static async Task<string?> SuggestFollowUpQuestions(IChatClient chatClient, string responseText, List<McpClientTool> allTools, ILogger logger, IConfiguration config)
    {
        try
        {
            var maxQuestions = config.GetValue<int>("FollowUpQuestions:MaxQuestions", 5);
            
            // Create a prompt to generate follow-up questions
            var followUpPrompt = $@"Based on this response about dealership management data:

""{responseText}""

Available tools: {string.Join(", ", allTools.Select(t => t.Name))}

Generate {maxQuestions} concise follow-up questions that a user might want to ask next. Focus on:
- Related data analysis or deeper insights
- Comparisons or trends
- Additional reporting needs
- Data visualization opportunities

Format as a numbered list. Keep questions short and actionable.";

            var followUpMessages = new List<ChatMessage>
            {
                new ChatMessage(ChatRole.System, "You are a helpful assistant that suggests relevant follow-up questions for dealership management queries."),
                new ChatMessage(ChatRole.User, followUpPrompt)
            };

            var followUpResponse = await chatClient.GetResponseAsync(followUpMessages, new ChatOptions(), CancellationToken.None);
            var suggestions = followUpResponse.ToString();

            if (!string.IsNullOrWhiteSpace(suggestions))
            {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.DarkYellow;
                Console.WriteLine("💡 Suggested follow-up questions:");
                Console.ResetColor();
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine(suggestions);
                Console.ResetColor();
                
                // Ask if user wants to use one of the suggestions
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.DarkGray;
                Console.WriteLine("Would you like to ask one of these questions? (Type the number, or press Enter to continue)");
                Console.ResetColor();
                
                return suggestions; // Return suggestions so they can be used in the main loop
            }
        }
        catch (Exception ex)
        {
            // Silently handle follow-up question generation errors
            logger.LogDebug(ex, "Failed to generate follow-up questions");
            return null;
        }
        
        return null;
    }
}

public class McpServerConfig
{
    public string Name { get; set; } = "";
    public string Command { get; set; } = "";
    public string[] Arguments { get; set; } = Array.Empty<string>();
    public bool Enabled { get; set; } = true;
    public string? WorkingDirectory { get; set; }
    public Dictionary<string, string?>? EnvironmentVariables { get; set; }
}
