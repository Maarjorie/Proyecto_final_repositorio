using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Controllers;

/// <summary>RF-14: favoritos de cada cuenta (solo trabajos publicados).</summary>
[ApiController]
[Authorize]
[Route("api/favoritos")]
public sealed class FavoritosController : ControllerBase
{
    private readonly RepositorioDbContext _db;

    public FavoritosController(RepositorioDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> ObtenerMios(CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        var ids = await _db.TblFavoritos
            .AsNoTracking()
            .Where(item => item.IdUsuario == idUsuario &&
                           item.IdProyectoNavigation.EstadoPublicacion == "publicado" &&
                           item.IdProyectoNavigation.EstadoAutorizacion == "autorizado")
            .OrderBy(item => item.FechaRegistro)
            .Select(item => item.IdProyecto)
            .ToListAsync(cancellationToken);

        return Ok(ids);
    }

    [HttpPut("{idProyecto:int}")]
    public async Task<IActionResult> Guardar(int idProyecto, CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        var publicado = await _db.TblProyectos.AnyAsync(
            item => item.IdProyecto == idProyecto &&
                    item.EstadoPublicacion == "publicado" &&
                    item.EstadoAutorizacion == "autorizado",
            cancellationToken);
        if (!publicado)
        {
            return NotFound(new { mensaje = "La ficha ya no está disponible en el catálogo." });
        }

        var existe = await _db.TblFavoritos.AnyAsync(
            item => item.IdUsuario == idUsuario && item.IdProyecto == idProyecto,
            cancellationToken);
        if (!existe)
        {
            _db.TblFavoritos.Add(new TblFavorito { IdUsuario = idUsuario, IdProyecto = idProyecto });
            await _db.SaveChangesAsync(cancellationToken);
        }

        return Ok(new { mensaje = "Guardado en favoritos." });
    }

    [HttpDelete("{idProyecto:int}")]
    public async Task<IActionResult> Quitar(int idProyecto, CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        await _db.TblFavoritos
            .Where(item => item.IdUsuario == idUsuario && item.IdProyecto == idProyecto)
            .ExecuteDeleteAsync(cancellationToken);

        return Ok(new { mensaje = "Quitado de favoritos." });
    }

    private bool TryObtenerUsuario(out int idUsuario) =>
        int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out idUsuario);
}
