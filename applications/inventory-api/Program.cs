using System.Data;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Enable CORS for all environments
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAllOrigins", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Configuration.AddEnvironmentVariables();

var connectionString = builder.Configuration.GetConnectionString("InventoryDb") 
    ?? "Host=localhost;Port=5432;Database=inventory_db;Username=nexora_admin;Password=devops_secure_password_123;";

builder.Services.AddScoped<IDbConnection>(_ => new NpgsqlConnection(connectionString));

var app = builder.Build();

app.UseCors("AllowAllOrigins");

// Health Check
app.MapGet("/health", async (IConfiguration config) =>
{
    var simulateFailure = config.GetValue<string>("SIMULATE_FAILURE");
    if (!string.IsNullOrEmpty(simulateFailure) && simulateFailure.Equals("500", StringComparison.OrdinalIgnoreCase))
    {
        return Results.Problem(statusCode: 500, title: "Simulated Deployment Failure");
    }

    try
    {
        await using var conn = new NpgsqlConnection(connectionString);
        await conn.OpenAsync();
        await using var cmd = new NpgsqlCommand("SELECT 1", conn);
        await cmd.ExecuteScalarAsync();

        return Results.Ok(new
        {
            status = "healthy",
            version = config.GetValue<string>("APP_VERSION") ?? "1.4.1",
            database = "connected",
            timestamp = DateTime.UtcNow
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(statusCode: 503, title: "Database Unreachable", detail: ex.Message);
    }
});

// GET /api/products
app.MapGet("/api/products", async (IDbConnection db) =>
{
    var products = new List<object>();
    if (db.State != ConnectionState.Open) db.Open();

    using var cmd = db.CreateCommand();
    cmd.CommandText = "SELECT id, sku, name, category, price, quantity, updated_at FROM products ORDER BY id ASC LIMIT 100";
    using var reader = cmd.ExecuteReader();

    while (reader.Read())
    {
        var price = Convert.ToDecimal(reader["price"]);
        var qty = Convert.ToInt32(reader["quantity"]);
        products.Add(new
        {
            id = reader.GetInt32(0),
            sku = reader.GetString(1),
            name = reader.GetString(2),
            category = reader.GetString(3),
            price = price,
            quantity = qty,
            available = qty > 0,
            updated_at = reader.GetDateTime(6)
        });
    }

    return Results.Ok(products);
});

// GET /api/products/{id}
app.MapGet("/api/products/{id:int}", async (int id, IDbConnection db) =>
{
    if (db.State != ConnectionState.Open) db.Open();

    using var cmd = db.CreateCommand();
    cmd.CommandText = "SELECT id, sku, name, category, price, quantity, updated_at FROM products WHERE id = @id";
    var param = cmd.CreateParameter();
    param.ParameterName = "@id";
    param.Value = id;
    cmd.Parameters.Add(param);

    using var reader = cmd.ExecuteReader();
    if (!reader.Read()) return Results.NotFound();

    var qty = Convert.ToInt32(reader["quantity"]);
    return Results.Ok(new
    {
        id = reader.GetInt32(0),
        sku = reader.GetString(1),
        name = reader.GetString(2),
        category = reader.GetString(3),
        price = Convert.ToDecimal(reader["price"]),
        quantity = qty,
        available = qty > 0,
        updated_at = reader.GetDateTime(6)
    });
});

app.Run();
