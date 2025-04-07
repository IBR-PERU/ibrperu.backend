using backend.services;
using System.Text;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);
// Add services to the container.

// Implementacion JWT
var secretKey = builder.Configuration["JWTConfig:secretKey"];
var keyBytes = Encoding.UTF8.GetBytes(secretKey);

builder.Services.AddAuthorization();
builder.Services.AddAuthentication("Bearer").AddJwtBearer(config => { 
    config.RequireHttpsMetadata = false;
    config.SaveToken = true;
    config.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(keyBytes),
        ValidateIssuer = false,
        ValidateAudience = false,
    };
});

// Agregar acceso de FrontEnd
var CorsConfiguration = "corspolicy";
builder.Services.AddCors(options => {
    options.AddPolicy(
        name: CorsConfiguration,
        builder =>
        {
            builder.WithOrigins(
                "http://localhost:4200"
                , "http://localhost:4201"
                , "http://localhost:5500"
                , "http://127.0.0.1:5500"
                , "http://127.0.0.1:5501"
                , "http://127.0.0.1:8000"
                , "https://127.0.0.1:8000"
                , "http://127.0.0.1"
                , "http://localhost:5173"
                )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
        });
});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Asignacion de Interfaces/Entidades y BD Conexion
var connectionString = builder.Configuration.GetConnectionString("cnDatabase")
    ?? throw new InvalidOperationException("La cadena de conexión no está configurada.");
builder.Services.ConfigureRepositoryManager(connectionString);

//builder.Services.ConfigureRepositoryManager(builder.Configuration["ConnectionStrings:cnPsql"]);
builder.Services.ConfigureServicesManager();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors(CorsConfiguration);

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
