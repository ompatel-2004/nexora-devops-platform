using System.Text.Json.Serialization;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();
app.UseCors("AllowAll");

string GetConnectionString()
{
    var connStr = app.Configuration.GetConnectionString("InventoryDb") 
                  ?? Environment.GetEnvironmentVariable("INVENTORY_DB_CONNECTION");

    if (string.IsNullOrWhiteSpace(connStr))
    {
        var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
        var dbPort = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
        var dbName = Environment.GetEnvironmentVariable("DB_NAME") ?? "inventory_db";
        var dbUser = Environment.GetEnvironmentVariable("DB_USER") ?? "nexora_admin";
        var dbPass = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "";
        connStr = $"Host={dbHost};Port={dbPort};Database={dbName};Username={dbUser};Password={dbPass};";
    }
    return connStr;
}

app.MapGet("/health", () =>
{
    var simulateFail = app.Configuration["SIMULATE_FAILURE"];
    if (simulateFail == "500")
    {
        return Results.Problem("Simulated Internal Server Error for Release Gate Testing", statusCode: 500);
    }

    try
    {
        using var conn = new NpgsqlConnection(GetConnectionString());
        conn.Open();
        return Results.Ok(new { status = "healthy", version = app.Configuration["APP_VERSION"] ?? "1.4.2", database = "connected" });
    }
    catch (Exception ex)
    {
        return Results.Json(new { status = "degraded", version = app.Configuration["APP_VERSION"] ?? "1.4.2", database = ex.Message }, statusCode: 503);
    }
});

app.MapGet("/api/products", () =>
{
    var products = new List<Product>();
    using var conn = new NpgsqlConnection(GetConnectionString());
    conn.Open();
    using var cmd = new NpgsqlCommand("SELECT id, sku, name, category, price, quantity, available FROM products ORDER BY id ASC;", conn);
    using var reader = cmd.ExecuteReader();
    while (reader.Read())
    {
        products.Add(new Product(
            reader.GetInt32(0),
            reader.GetString(1),
            reader.GetString(2),
            reader.IsDBNull(3) ? "General" : reader.GetString(3),
            reader.GetDecimal(4),
            reader.GetInt32(5),
            reader.GetBoolean(6)
        ));
    }
    return Results.Ok(products);
});

app.MapGet("/api/products/{id:int}", (int id) =>
{
    using var conn = new NpgsqlConnection(GetConnectionString());
    conn.Open();
    using var cmd = new NpgsqlCommand("SELECT id, sku, name, category, price, quantity, available FROM products WHERE id = @id;", conn);
    cmd.Parameters.AddWithValue("id", id);
    using var reader = cmd.ExecuteReader();
    if (reader.Read())
    {
        return Results.Ok(new Product(
            reader.GetInt32(0),
            reader.GetString(1),
            reader.GetString(2),
            reader.IsDBNull(3) ? "General" : reader.GetString(3),
            reader.GetDecimal(4),
            reader.GetInt32(5),
            reader.GetBoolean(6)
        ));
    }
    return Results.NotFound(new { error = $"Product with ID {id} not found" });
});

app.Run();

public record Product(int Id, string Sku, string Name, string Category, decimal Price, int Quantity, bool Available);
