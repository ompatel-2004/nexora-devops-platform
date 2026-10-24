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

string GetConnectionString() =>
    app.Configuration.GetConnectionString("InventoryDb") 
    ?? Environment.GetEnvironmentVariable("INVENTORY_DB_CONNECTION") 
    ?? "Host=localhost;Port=5432;Database=inventory_db;Username=nexora_admin;Password=devops_secure_password_123;";

// GET /health
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

// GET /api/products
app.MapGet("/api/products", () =>
{
    var products = new List<Product>();
    try
    {
        using var conn = new NpgsqlConnection(GetConnectionString());
        conn.Open();
        using var cmd = new NpgsqlCommand("SELECT id, sku, name, category, price, quantity, available FROM products ORDER BY id ASC LIMIT 100;", conn);
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
    }
    catch
    {
        // Fallback deterministic sample if DB is seeding
        for (int i = 1; i <= 10; i++)
        {
            products.Add(new Product(100 + i, $"LAP-{i:D3}", $"Enterprise Workstation {i}", "Hardware", 74999m + (i * 1000), 10, true));
        }
    }
    return Results.Ok(products);
});

// GET /api/products/{id}
app.MapGet("/api/products/{id:int}", (int id) =>
{
    try
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
    }
    catch { }
    return Results.NotFound(new { error = $"Product with ID {id} not found" });
});

app.Run();

public record Product(int Id, string Sku, string Name, string Category, decimal Price, int Quantity, bool Available);
