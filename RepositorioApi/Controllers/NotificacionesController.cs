using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;

namespace RepositorioApi.Controllers;

/// <summary>Avisos de la cuenta actual (decisiones, retiros y nuevas entregas).</summary>
[ApiController]
[Authorize]
[Route("api/notificaciones")]
public sealed class NotificacionesController : ControllerBase
{
    private readonly RepositorioDbContext _db;

    public NotificacionesController(RepositorioDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<IActionResult> ObtenerMias(CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        var notificaciones = await _db.TblNotificacions
            .AsNoTracking()
            .Where(item => item.IdUsuarioDestino == idUsuario)
            .OrderByDescending(item => item.FechaEnvio)
            .Select(item => new
            {
                id = item.IdNotificacion,
                idEntrega = item.IdEntrega,
                tituloProyecto = item.IdEntregaNavigation.IdProyectoNavigation.Titulo,
                mensaje = item.Mensaje,
                fecha = item.FechaEnvio,
                leida = item.FechaLectura != null
            })
            .ToListAsync(cancellationToken);

        // El supervisor ve las entregas nuevas; el solicitante, las decisiones.
        var esSupervisor = User.IsInRole("supervisor");

        return Ok(notificaciones
            .Select(item => new
            {
                item.id,
                item.idEntrega,
                item.tituloProyecto,
                tipo = ClasificarMensaje(item.mensaje),
                item.mensaje,
                item.fecha,
                item.leida
            })
            .Where(item => (item.tipo == "Nueva entrega") == esSupervisor));
    }

    [HttpPost("{idNotificacion:int}/leida")]
    public async Task<IActionResult> MarcarLeida(
        int idNotificacion,
        CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        var actualizadas = await _db.TblNotificacions
            .Where(item => item.IdNotificacion == idNotificacion &&
                           item.IdUsuarioDestino == idUsuario &&
                           item.FechaLectura == null)
            .ExecuteUpdateAsync(
                cambios => cambios.SetProperty(item => item.FechaLectura, AhoraUtc()),
                cancellationToken);

        return actualizadas == 0 &&
               !await _db.TblNotificacions.AnyAsync(
                   item => item.IdNotificacion == idNotificacion &&
                           item.IdUsuarioDestino == idUsuario,
                   cancellationToken)
            ? NotFound()
            : NoContent();
    }

    [HttpPost("leidas")]
    public async Task<IActionResult> MarcarTodasLeidas(CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idUsuario))
        {
            return Unauthorized();
        }

        await _db.TblNotificacions
            .Where(item => item.IdUsuarioDestino == idUsuario && item.FechaLectura == null)
            .ExecuteUpdateAsync(
                cambios => cambios.SetProperty(item => item.FechaLectura, AhoraUtc()),
                cancellationToken);

        return NoContent();
    }

    // Clasifica el aviso según su texto.
    private static string ClasificarMensaje(string mensaje) => mensaje switch
    {
        _ when mensaje.StartsWith("Nueva entrega", StringComparison.Ordinal) => "Nueva entrega",
        _ when mensaje.Contains("Con correcciones", StringComparison.Ordinal) => "Correcciones solicitadas",
        _ when mensaje.Contains("Rechazada", StringComparison.Ordinal) => "Proyecto rechazado",
        _ when mensaje.Contains("retirada", StringComparison.Ordinal) => "Publicación retirada",
        _ when mensaje.Contains("Aprobada", StringComparison.Ordinal) => "Proyecto aprobado",
        _ => "Aviso"
    };

    private bool TryObtenerUsuario(out int idUsuario) =>
        int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out idUsuario);

    private static DateTime AhoraUtc() =>
        DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
}
