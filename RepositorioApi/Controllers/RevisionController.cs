using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Controllers;

[ApiController]
[Authorize(Roles = "supervisor")]
[Route("api/revision")]
public sealed class RevisionController : ControllerBase
{
    private readonly RepositorioDbContext _db;

    public RevisionController(RepositorioDbContext db)
    {
        _db = db;
    }

    [HttpGet("pendientes")]
    public async Task<IActionResult> ObtenerPendientes(CancellationToken cancellationToken)
    {
        var entregas = await _db.TblEntregas
            .AsNoTracking()
            .Where(entrega => entrega.EstadoEntrega == "pendiente")
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdCarreraNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTematicaNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoAutors)
                    .ThenInclude(autorProyecto => autorProyecto.IdAutorNavigation)
            .Include(entrega => entrega.IdUsuarioEnviaNavigation)
            .Include(entrega => entrega.TblRecursos)
                .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .OrderBy(entrega => entrega.FechaEnvio)
            .ToListAsync(cancellationToken);

        return Ok(entregas.Select(entrega => new
        {
            id = entrega.IdEntrega,
            titulo = entrega.IdProyectoNavigation.Titulo,
            tipoTrabajo = entrega.IdProyectoNavigation.IdTipoProyectoNavigation.Nombre,
            anio = entrega.IdProyectoNavigation.Anio,
            carrera = entrega.IdProyectoNavigation.IdCarreraNavigation.Nombre,
            tematica = entrega.IdProyectoNavigation.IdTematicaNavigation.Nombre,
            resumen = entrega.IdProyectoNavigation.Resumen,
            fechaEnvio = entrega.FechaEnvio,
            solicitante = entrega.IdUsuarioEnviaNavigation.Nombres + " " +
                          entrega.IdUsuarioEnviaNavigation.Apellidos,
            autores = entrega.IdProyectoNavigation.TblProyectoAutors
                .OrderBy(relacion => relacion.OrdenAutoria)
                .Select(relacion =>
                    relacion.IdAutorNavigation.Nombres + " " +
                    relacion.IdAutorNavigation.Apellidos)
                .ToList(),
            recursos = entrega.TblRecursos.Select(recurso => new
            {
                id = recurso.IdRecurso,
                nombre = recurso.Nombre,
                tipo = recurso.IdTipoRecursoNavigation.Nombre,
                url = recurso.IdTipoRecursoNavigation.Nombre == "enlace"
                    ? recurso.Ubicacion
                    : null
            }).ToList()
        }));
    }

    [HttpPost("{idEntrega:int}/decision")]
    public async Task<IActionResult> RegistrarDecision(
        int idEntrega,
        [FromBody] DecisionRevisionRequest request,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idSupervisor))
        {
            return Unauthorized();
        }

        var decision = request.Decision.Trim().ToLowerInvariant() switch
        {
            "aprobada" => "aprobada",
            "con correcciones" or "con_correcciones" => "con_correcciones",
            "rechazada" => "rechazada",
            _ => null
        };

        if (decision is null)
        {
            return BadRequest(new
            {
                mensaje = "La decisión debe ser Aprobada, Con correcciones o Rechazada."
            });
        }

        if (decision != "aprobada" && string.IsNullOrWhiteSpace(request.Observacion))
        {
            return BadRequest(new
            {
                mensaje = "Escribe las observaciones para pedir correcciones o rechazar."
            });
        }

        var entrega = await _db.TblEntregas
            .Include(item => item.IdProyectoNavigation)
            .FirstOrDefaultAsync(item => item.IdEntrega == idEntrega, cancellationToken);

        if (entrega is null)
        {
            return NotFound(new { mensaje = "No se encontró la entrega." });
        }

        if (entrega.EstadoEntrega != "pendiente")
        {
            return Conflict(new { mensaje = "Esta entrega ya tiene una decisión registrada." });
        }

        var estadoVisible = decision switch
        {
            "aprobada" => "Aprobada",
            "con_correcciones" => "Con correcciones",
            _ => "Rechazada"
        };

        entrega.EstadoEntrega = decision;
        entrega.IdUsuarioRevisa = idSupervisor;
        entrega.FechaRevision = DateTime.SpecifyKind(
            DateTime.UtcNow,
            DateTimeKind.Unspecified);
        // tbl_proyecto solo acepta pendiente / autorizado / no_autorizado
        // (ck_proyecto_autorizacion) y solo se publica si está autorizado
        // (ck_proyecto_publicacion_autorizada).
        var publicar = decision == "aprobada" && request.AutorizarDifusion;
        entrega.IdProyectoNavigation.EstadoAutorizacion = decision switch
        {
            "aprobada" when publicar => "autorizado",
            "rechazada" => "no_autorizado",
            _ => "pendiente"
        };
        entrega.IdProyectoNavigation.EstadoPublicacion =
            publicar ? "publicado" : "no_publicado";
        entrega.IdProyectoNavigation.FechaActualizacion = entrega.FechaRevision.Value;

        var detalle = string.IsNullOrWhiteSpace(request.Observacion)
            ? "Decisión del supervisor: " + estadoVisible + "."
            : "Decisión del supervisor: " + estadoVisible + ". " +
              request.Observacion.Trim();

        if (decision == "aprobada")
        {
            detalle += request.AutorizarDifusion
                ? " Se autorizó la difusión."
                : " Aprobado, pendiente de autorización de difusión.";
        }

        _db.TblHistorials.Add(new TblHistorial
        {
            IdUsuario = idSupervisor,
            IdProyecto = entrega.IdProyecto,
            // ck_historial_accion exige la acción en minúsculas.
            Accion = "revisión",
            Detalle = detalle
        });

        _db.TblNotificacions.Add(new TblNotificacion
        {
            IdEntrega = entrega.IdEntrega,
            IdUsuarioDestino = entrega.IdUsuarioEnvia,
            Mensaje = detalle
        });

        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new
        {
            idEntrega = entrega.IdEntrega,
            estado = estadoVisible,
            publicado = entrega.IdProyectoNavigation.EstadoPublicacion == "publicado",
            mensaje = detalle
        });
    }
}

public sealed class DecisionRevisionRequest
{
    [Required]
    public string Decision { get; set; } = string.Empty;

    [StringLength(2000)]
    public string? Observacion { get; set; }

    public bool AutorizarDifusion { get; set; }
}
