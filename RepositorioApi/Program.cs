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

builder.Services.AddControllers()
    .ConfigureApiBehaviorOptions(options =>
    {
        // Mismo formato que el resto de errores ({ mensaje }) para que la
        // pantalla lo muestre. Los mensajes de los atributos están en español;
        // los automáticos de ASP.NET (en inglés) se cambian por uno genérico.
        // Un número vacío o mal escrito no llega a los atributos: se nombra el campo.
        var mensajesPorCampo = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Anio"] = "Escribe el año del trabajo.",
            ["IdTipoProyecto"] = "Selecciona el tipo de trabajo.",
            ["IdCarrera"] = "Selecciona la carrera.",
            ["IdTematica"] = "Selecciona el área temática.",
            ["IdMateria"] = "Selecciona una asignatura válida.",
            ["IdDocentesAsesores"] = "Selecciona docentes asesores válidos."
        };
        options.InvalidModelStateResponseFactory = context =>
        {
            var mensaje = context.ModelState
                .Where(campo => campo.Value?.Errors.Count > 0)
                .Select(campo =>
                    campo.Value!.Errors
                        .Select(error => error.ErrorMessage)
                        .FirstOrDefault(texto => !string.IsNullOrWhiteSpace(texto) && !texto.StartsWith("The ", StringComparison.Ordinal))
                    ?? mensajesPorCampo.GetValueOrDefault(campo.Key.Split('[')[0]))
                .FirstOrDefault(texto => texto is not null);
            return new Microsoft.AspNetCore.Mvc.BadRequestObjectResult(new
            {
                mensaje = mensaje ?? "Revisa los datos del formulario."
            });
        };
    });
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