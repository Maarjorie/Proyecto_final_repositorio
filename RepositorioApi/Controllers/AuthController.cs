using System.ComponentModel.DataAnnotations;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authorization;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly RepositorioDbContext _db;
    private readonly IConfiguration _configuration;
    private readonly PasswordHasher<TblUsuario> _passwordHasher = new();

    public AuthController(
        RepositorioDbContext db,
        IConfiguration configuration)
    {
        _db = db;
        _configuration = configuration;
    }

    [HttpPost("registro")]
    public async Task<IActionResult> Registrar(RegistroRequest request)
    {
        var correo = request.Correo.Trim().ToLowerInvariant();

        var yaExiste = await _db.TblUsuarios
            .AnyAsync(usuario => usuario.Correo.ToLower() == correo);

        if (yaExiste)
        {
            return Conflict(new { mensaje = "Ya existe una cuenta con ese correo." });
        }

        var usuarioNuevo = new TblUsuario
        {
            Nombres = request.Nombres.Trim(),
            Apellidos = request.Apellidos.Trim(),
            Correo = correo,
            ContrasenaHash = string.Empty,
            Activo = true
        };

        usuarioNuevo.ContrasenaHash = _passwordHasher.HashPassword(
            usuarioNuevo,
            request.Contrasena);

        // Toda cuenta nueva recibe el rol básico "usuario".
        var rolUsuario = await _db.TblRols
            .FirstOrDefaultAsync(rol => rol.NombreRol == "usuario");
        if (rolUsuario is not null)
        {
            usuarioNuevo.IdRols.Add(rolUsuario);
        }

        _db.TblUsuarios.Add(usuarioNuevo);
        await _db.SaveChangesAsync();

        return Ok(CrearRespuestaToken(usuarioNuevo));
    }

    [HttpPost("login")]
    public async Task<IActionResult> IniciarSesion(LoginRequest request)
    {
        var correo = request.Correo.Trim().ToLowerInvariant();

        var usuario = await _db.TblUsuarios
            .Include(u => u.IdRols)
            .FirstOrDefaultAsync(u => u.Correo.ToLower() == correo);

        if (usuario is null || !usuario.Activo)
        {
            return Unauthorized(new { mensaje = "Correo o contraseña incorrectos." });
        }

        var resultado = _passwordHasher.VerifyHashedPassword(
            usuario,
            usuario.ContrasenaHash,
            request.Contrasena);

        if (resultado == PasswordVerificationResult.Failed)
        {
            return Unauthorized(new { mensaje = "Correo o contraseña incorrectos." });
        }

        return Ok(CrearRespuestaToken(usuario));
    }
    [Authorize]
    [HttpGet("perfil")]
    public IActionResult ObtenerPerfil()
    {
        var idTexto = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (!int.TryParse(idTexto, out var idUsuario))
        {
            return Unauthorized();
        }

        return Ok(new
        {
            idUsuario,
            nombre = User.FindFirst(ClaimTypes.Name)?.Value,
            correo = User.FindFirst(ClaimTypes.Email)?.Value
        });
    }


    private object CrearRespuestaToken(TblUsuario usuario)
    {
        var expiracion = DateTime.UtcNow.AddHours(8);

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuario.IdUsuario.ToString()),
            new(ClaimTypes.Name, $"{usuario.Nombres} {usuario.Apellidos}"),
            new(ClaimTypes.Email, usuario.Correo)
        };

        foreach (var rol in usuario.IdRols)
        {
            claims.Add(new Claim(ClaimTypes.Role, rol.NombreRol));
        }

        var clave = _configuration["Jwt:Key"]!;
        var firma = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(clave)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: expiracion,
            signingCredentials: firma);

        return new
        {
            token = new JwtSecurityTokenHandler().WriteToken(token),
            tipo = "Bearer",
            expiraUtc = expiracion,
            usuario = new
            {
                id = usuario.IdUsuario,
                nombres = usuario.Nombres,
                apellidos = usuario.Apellidos,
                correo = usuario.Correo
            }
        };
    }
}

public class RegistroRequest
{
    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Nombres { get; set; } = string.Empty;

    [Required]
    [StringLength(100, MinimumLength = 2)]
    public string Apellidos { get; set; } = string.Empty;

    [Required]
    [EmailAddress]
    [StringLength(254)]
    public string Correo { get; set; } = string.Empty;

    [Required]
    [MinLength(8)]
    public string Contrasena { get; set; } = string.Empty;
}

public class LoginRequest
{
    [Required]
    [EmailAddress]
    public string Correo { get; set; } = string.Empty;

    [Required]
    public string Contrasena { get; set; } = string.Empty;
}
