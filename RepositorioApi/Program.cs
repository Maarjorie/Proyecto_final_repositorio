using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RepositorioApi.Data;

var builder = WebApplication.CreateBuilder(args);

var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("Falta configurar Jwt:Key en Secretos de usuario.");
var jwtIssuer = builder.Configuration["Jwt:Issuer"]
    ?? throw new InvalidOperationException("Falta configurar Jwt:Issuer.");
var jwtAudience = builder.Configuration["Jwt:Audience"]
    ?? throw new InvalidOperationException("Falta configurar Jwt:Audience.");

builder.Services.AddControllers();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AngularLocal", policy =>
        policy.WithOrigins("http://localhost:4200")
            .AllowAnyHeader()
            .AllowAnyMethod());
});
builder.Services.AddOpenApi();

builder.Services.AddDbContext<RepositorioDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("RepositorioDb")));

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey)),
            
            ClockSkew = TimeSpan.FromMinutes(1)
        };
        options.Events = new JwtBearerEvents
        {
            OnAuthenticationFailed = contexto =>
            {
                System.Diagnostics.Debug.WriteLine(
                    $"JWT rechazado: {contexto.Exception}");
                return Task.CompletedTask;
            },
            OnTokenValidated = contexto =>
            {
                var tieneId = contexto.Principal?.HasClaim(
                    reclamo => reclamo.Type ==
                        System.Security.Claims.ClaimTypes.NameIdentifier) == true;

                System.Diagnostics.Debug.WriteLine(
                    $"JWT aceptado; NameIdentifier presente: {tieneId}");
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseCors("AngularLocal");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();