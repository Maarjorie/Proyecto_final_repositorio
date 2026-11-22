using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

using RepositorioApi.Services;

namespace RepositorioApi.Controllers;

/// <summary>Acciones del supervisor: revisar, permisos, retiros y destacados.</summary>
[ApiController]
[Authorize(Roles = "supervisor")]
[Route("api/revision")]
public sealed class RevisionController : ControllerBase
{
    // Permisos de difusión (RF-10).
    private const string PermisoPendiente = "pendiente";
    private const string PermisoSoloFicha = "solo_ficha";
    private const string PermisoFichaYMateriales = "ficha_y_materiales";
    private const string PermisoNoAutorizado = "no_autorizado";

    private readonly RepositorioDbContext _db;

    public RevisionController(RepositorioDbContext db)
    {
        _db = db;
    }

    /// <summary>RF-21: entregas pendientes por orden de llegada.</summary>
    [HttpGet("pendientes")]
    public async Task<IActionResult> ObtenerPendientes(CancellationToken cancellationToken)
    {
        var entregas = await _db.TblEntregas
            .AsNoTracking()
            .AsSplitQuery()
            .Where(entrega => entrega.EstadoEntrega == "pendiente")
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdCarreraNavigation)
                    .ThenInclude(carrera => carrera.IdDepartamentoNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTematicaNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoAutors)
                    .ThenInclude(autorProyecto => autorProyecto.IdAutorNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdEtiqueta)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoDocentes)
                    .ThenInclude(asesor => asesor.IdDocenteNavigation)
                        .ThenInclude(docente => docente.IdUsuarioNavigation)
            .Include(entrega => entrega.IdUsuarioEnviaNavigation)
            .Include(entrega => entrega.TblRecursos)
                .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .OrderBy(entrega => entrega.FechaEnvio)
            .ToListAsync(cancellationToken);

        var idsProyecto = entregas.Select(entrega => entrega.IdProyecto).Distinct().ToList();
        var entregasPorProyecto = await _db.TblEntregas
            .AsNoTracking()
            .Where(entrega => idsProyecto.Contains(entrega.IdProyecto))
            .Select(entrega => new { entrega.IdProyecto, entrega.IdEntrega, entrega.FechaEnvio })
            .ToListAsync(cancellationToken);

        var resultado = new List<object>();
        foreach (var entrega in entregas)
        {
            var proyecto = entrega.IdProyectoNavigation;
            // Una actualización se revisa con los datos propuestos.
            var propuesta = DatosProyecto.Leer(entrega.DatosPropuestos);
            var vista = propuesta is null ? null : await propuesta.DescribirAsync(_db, cancellationToken);

            resultado.Add(new
            {
                id = entrega.IdEntrega,
                idProyecto = entrega.IdProyecto,
                esActualizacion = propuesta is not null,
                titulo = propuesta?.Titulo ?? proyecto.Titulo,
                tipoTrabajo = vista?.TipoTrabajo ?? proyecto.IdTipoProyectoNavigation.Nombre,
                anio = propuesta?.Anio ?? proyecto.Anio,
                departamento = vista?.Departamento ?? proyecto.IdCarreraNavigation.IdDepartamentoNavigation.Nombre,
                carrera = vista?.Carrera ?? proyecto.IdCarreraNavigation.Nombre,
                tematica = vista?.Tematica ?? proyecto.IdTematicaNavigation.Nombre,
                resumen = propuesta?.Resumen ?? proyecto.Resumen,
                palabrasClave = propuesta?.PalabrasClave.OrderBy(nombre => nombre).ToList()
                    ?? proyecto.IdEtiqueta.Select(etiqueta => etiqueta.Nombre).OrderBy(nombre => nombre).ToList(),
                fechaEnvio = entrega.FechaEnvio,
                version = entregasPorProyecto.Count(item =>
                    item.IdProyecto == entrega.IdProyecto && item.FechaEnvio <= entrega.FechaEnvio),
                solicitante = entrega.IdUsuarioEnviaNavigation.Nombres + " " +
                              entrega.IdUsuarioEnviaNavigation.Apellidos,
                autores = propuesta?.Autores.Select(autor => autor.Nombres.Trim() + " " + autor.Apellidos.Trim()).ToList()
                    ?? proyecto.TblProyectoAutors
                        .OrderBy(relacion => relacion.OrdenAutoria)
                        .Select(relacion => relacion.IdAutorNavigation.Nombres + " " + relacion.IdAutorNavigation.Apellidos)
                        .ToList(),
                // Los asesores que siguen mantienen su permiso actual.
                asesores = vista is null
                    ? MapearAsesores(proyecto)
                    : vista.Asesores.Select(asesor => new
                    {
                        idDocente = asesor.IdDocente,
                        nombre = asesor.Nombre,
                        autorizado = proyecto.TblProyectoDocentes.Any(item => item.IdDocente == asesor.IdDocente && item.NombreAutorizado)
                    }).ToList(),
                recursos = entrega.TblRecursos
                    .OrderBy(recurso => recurso.IdRecurso)
                    .Select(recurso => MapearRecurso(recurso))
                    .ToList()
            });
        }

        return Ok(resultado);
    }

    /// <summary>RF-18: aprueba, pide correcciones o rechaza una entrega.</summary>
    [HttpPost("{idEntrega:int}/decision")]
    public async Task<IActionResult> RegistrarDecision(
        int idEntrega,
        [FromBody] DecisionRevisionRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idSupervisor))
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

        var observacion = request.Observacion?.Trim() ?? string.Empty;

        // Rechazar y pedir correcciones exigen una observación que se entienda.
        if (decision == "rechazada" && observacion.Length == 0)
        {
            return BadRequest(new { mensaje = "Escribe el motivo del rechazo." });
        }

        if (decision != "aprobada" &&
            (observacion.Length < Validacion.ObservacionMinima || Validacion.TienePalabraDemasiadoLarga(observacion)))
        {
            return BadRequest(new { mensaje = $"Explica la decisión con al menos {Validacion.ObservacionMinima} caracteres." });
        }

        if (decision == "con_correcciones" && observacion.Length == 0)
        {
            return BadRequest(new { mensaje = "Describe las correcciones que debe hacer el solicitante." });
        }

        string? permiso = null;
        if (decision == "aprobada")
        {
            permiso = NormalizarPermiso(request.Permiso);
            if (permiso is null)
            {
                return BadRequest(new { mensaje = "Indica el permiso de los autores." });
            }
        }

        var entrega = await _db.TblEntregas
            .Include(item => item.IdProyectoNavigation)
            .Include(item => item.TblRecursos)
            .FirstOrDefaultAsync(item => item.IdEntrega == idEntrega, cancellationToken);

        if (entrega is null)
        {
            return NotFound(new { mensaje = "No se encontró la entrega." });
        }

        if (entrega.EstadoEntrega != "pendiente")
        {
            return Conflict(new { mensaje = "Esta entrega ya tiene una decisión registrada." });
        }

        // Nadie revisa su propia entrega.
        if (entrega.IdUsuarioEnvia == idSupervisor)
        {
            return Conflict(new { mensaje = "No puedes revisar una entrega que enviaste tú; debe decidirla otro supervisor." });
        }

        var ahora = AhoraUtc();
        var proyecto = entrega.IdProyectoNavigation;
        entrega.EstadoEntrega = decision;
        entrega.IdUsuarioRevisa = idSupervisor;
        entrega.FechaRevision = ahora;

        var estadoVisible = decision switch
        {
            "aprobada" => "Aprobada",
            "con_correcciones" => "Con correcciones",
            _ => "Rechazada"
        };

        var detalle = "Decisión del supervisor: " + estadoVisible + ".";
        if (observacion.Length > 0)
        {
            detalle += " " + observacion;
        }

        var propuesta = DatosProyecto.Leer(entrega.DatosPropuestos);
        var autoresAnteriores = new List<int>();

        if (decision == "aprobada")
        {
            // Una actualización solo se aprueba con permiso de difusión.
            if (propuesta is not null && permiso is not (PermisoSoloFicha or PermisoFichaYMateriales))
            {
                return BadRequest(new
                {
                    mensaje = "Esta entrega actualiza un trabajo publicado: para aprobarla registra el permiso de difusión (solo la ficha o ficha y materiales)."
                });
            }

            // Una versión nueva aprobada puede volver a publicarse aunque se hubiera retirado.
            if (proyecto.EstadoPublicacion == "retirado")
            {
                proyecto.EstadoPublicacion = "no_publicado";
            }

            var error = AplicarPermiso(proyecto, entrega, permiso!, request.RecursosAutorizados);
            if (error is not null)
            {
                return BadRequest(new { mensaje = error });
            }

            if (propuesta is not null)
            {
                autoresAnteriores = await propuesta.AplicarAsync(_db, proyecto, reemplazar: true, cancellationToken);
                await _db.SaveChangesAsync(cancellationToken);
            }

            await AplicarPermisoAsesoresAsync(proyecto.IdProyecto, request.AsesoresAutorizados, cancellationToken);
            detalle += " " + DescribirPublicacion(proyecto);
        }

        proyecto.FechaActualizacion = ahora;

        _db.TblHistorials.Add(new TblHistorial
        {
            IdUsuario = idSupervisor,
            IdProyecto = entrega.IdProyecto,
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
        await DatosProyecto.LimpiarAutoresAsync(_db, autoresAnteriores, cancellationToken);

        return Ok(new
        {
            idEntrega = entrega.IdEntrega,
            estado = estadoVisible,
            publicado = proyecto.EstadoPublicacion == "publicado",
            mensaje = detalle
        });
    }

    /// <summary>
    /// RF-12: datos para contar proyectos por año, área, departamento, carrera y tipo.
    /// Cada proyecto aparece una vez; la pantalla los agrupa según los filtros.
    /// </summary>
    [HttpGet("estadisticas")]
    public async Task<IActionResult> ObtenerEstadisticas(CancellationToken cancellationToken)
    {
        var areas = await _db.TblTematicas
            .AsNoTracking()
            .OrderBy(tematica => tematica.Nombre)
            .Select(tematica => new { id = tematica.IdTematica, nombre = tematica.Nombre })
            .ToListAsync(cancellationToken);
        var proyectos = await _db.TblProyectos
            .AsNoTracking()
            .Select(proyecto => new
            {
                id = proyecto.IdProyecto,
                anio = proyecto.Anio,
                idTematica = proyecto.IdTematica,
                tipo = proyecto.IdTipoProyectoNavigation.Nombre,
                departamento = proyecto.IdCarreraNavigation.IdDepartamentoNavigation.Nombre,
                carrera = proyecto.IdCarreraNavigation.Nombre,
                publicacion = proyecto.EstadoPublicacion
            })
            .ToListAsync(cancellationToken);
        var entregas = await _db.TblEntregas
            .AsNoTracking()
            .Select(entrega => new { idProyecto = entrega.IdProyecto, estado = entrega.EstadoEntrega })
            .ToListAsync(cancellationToken);

        return Ok(new
        {
            anios = proyectos.Select(proyecto => proyecto.anio).Distinct().OrderByDescending(anio => anio).ToList(),
            total = proyectos.Count,
            areas,
            proyectos,
            entregas
        });
    }

    /// <summary>Proyectos aprobados con su permiso, publicación, destacado y retiro.</summary>
    [HttpGet("publicaciones")]
    public async Task<IActionResult> ObtenerPublicaciones(CancellationToken cancellationToken)
    {
        var aprobadas = await _db.TblEntregas
            .AsNoTracking()
            .AsSplitQuery()
            .Where(entrega => entrega.EstadoEntrega == "aprobada")
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdCarreraNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoAutors)
                    .ThenInclude(relacion => relacion.IdAutorNavigation)
            .Include(entrega => entrega.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoDocentes)
                    .ThenInclude(asesor => asesor.IdDocenteNavigation)
                        .ThenInclude(docente => docente.IdUsuarioNavigation)
            .Include(entrega => entrega.IdUsuarioRevisaNavigation)
            .Include(entrega => entrega.TblRecursos)
                .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .ToListAsync(cancellationToken);

        // De cada proyecto se toma la última versión aprobada.
        var vigentes = aprobadas
            .GroupBy(entrega => entrega.IdProyecto)
            .Select(grupo => grupo.OrderByDescending(entrega => entrega.FechaRevision).First())
            .OrderByDescending(entrega => entrega.FechaRevision)
            .ToList();

        var idsProyecto = vigentes.Select(entrega => entrega.IdProyecto).ToList();
        var retiros = await _db.TblHistorials
            .AsNoTracking()
            .Where(item => idsProyecto.Contains(item.IdProyecto) && item.Accion == "retiro")
            .OrderByDescending(item => item.FechaAccion)
            .Select(item => new { item.IdProyecto, item.Detalle, item.FechaAccion })
            .ToListAsync(cancellationToken);

        return Ok(vigentes.Select(entrega =>
        {
            var proyecto = entrega.IdProyectoNavigation;
            var retiro = retiros.FirstOrDefault(item => item.IdProyecto == proyecto.IdProyecto);
            return new
            {
                idProyecto = proyecto.IdProyecto,
                idEntrega = entrega.IdEntrega,
                titulo = proyecto.Titulo,
                tipoTrabajo = proyecto.IdTipoProyectoNavigation.Nombre,
                anio = proyecto.Anio,
                carrera = proyecto.IdCarreraNavigation.Nombre,
                autores = proyecto.TblProyectoAutors
                    .OrderBy(relacion => relacion.OrdenAutoria)
                    .Select(relacion =>
                        relacion.IdAutorNavigation.Nombres + " " +
                        relacion.IdAutorNavigation.Apellidos)
                    .ToList(),
                fechaAprobacion = entrega.FechaRevision,
                revisor = entrega.IdUsuarioRevisaNavigation == null
                    ? null
                    : entrega.IdUsuarioRevisaNavigation.Nombres + " " +
                      entrega.IdUsuarioRevisaNavigation.Apellidos,
                permiso = PermisoActual(proyecto, entrega),
                estadoPublicacion = proyecto.EstadoPublicacion,
                destacado = proyecto.EsDestacado,
                motivoRetiro = proyecto.EstadoPublicacion == "retirado" ? retiro?.Detalle : null,
                fechaRetiro = proyecto.EstadoPublicacion == "retirado" ? retiro?.FechaAccion : null,
                asesores = MapearAsesores(proyecto),
                recursos = entrega.TblRecursos
                    .OrderBy(recurso => recurso.IdRecurso)
                    .Select(recurso => MapearRecurso(recurso))
                    .ToList()
            };
        }));
    }

    /// <summary>RF-10: registra o cambia el permiso de los autores; si lo autorizan, se publica.</summary>
    [HttpPut("proyectos/{idProyecto:int}/permiso")]
    public async Task<IActionResult> RegistrarPermiso(
        int idProyecto,
        [FromBody] PermisoRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idSupervisor))
        {
            return Unauthorized();
        }

        var permiso = NormalizarPermiso(request.Permiso);
        if (permiso is null)
        {
            return BadRequest(new { mensaje = "Indica el permiso de los autores." });
        }

        var entrega = await _db.TblEntregas
            .Include(item => item.IdProyectoNavigation)
            .Include(item => item.TblRecursos)
            .Where(item => item.IdProyecto == idProyecto && item.EstadoEntrega == "aprobada")
            .OrderByDescending(item => item.FechaRevision)
            .FirstOrDefaultAsync(cancellationToken);

        if (entrega is null)
        {
            return NotFound(new { mensaje = "El proyecto no tiene una entrega aprobada." });
        }

        var proyecto = entrega.IdProyectoNavigation;
        var error = AplicarPermiso(proyecto, entrega, permiso, request.RecursosAutorizados);
        if (error is not null)
        {
            return BadRequest(new { mensaje = error });
        }

        await AplicarPermisoAsesoresAsync(idProyecto, request.AsesoresAutorizados, cancellationToken);
        proyecto.FechaActualizacion = AhoraUtc();
        var detalle = "Permiso de los autores: " + DescribirPermiso(permiso) + ". " +
                      DescribirPublicacion(proyecto);

        _db.TblHistorials.Add(new TblHistorial
        {
            IdUsuario = idSupervisor,
            IdProyecto = idProyecto,
            Accion = "permiso",
            Detalle = detalle
        });

        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new
        {
            estadoPublicacion = proyecto.EstadoPublicacion,
            mensaje = detalle
        });
    }

    /// <summary>RF-09: retira una publicación con su motivo.</summary>
    [HttpPost("proyectos/{idProyecto:int}/retirar")]
    public async Task<IActionResult> Retirar(
        int idProyecto,
        [FromBody] RetiroRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idSupervisor))
        {
            return Unauthorized();
        }

        var motivo = request.Motivo?.Trim() ?? string.Empty;
        if (motivo.Length == 0)
        {
            return BadRequest(new { mensaje = "Escribe el motivo del retiro." });
        }

        if (motivo.Length < Validacion.ObservacionMinima || Validacion.TienePalabraDemasiadoLarga(motivo))
        {
            return BadRequest(new { mensaje = $"Explica el motivo del retiro con al menos {Validacion.ObservacionMinima} caracteres." });
        }

        var proyecto = await _db.TblProyectos
            .FirstOrDefaultAsync(item => item.IdProyecto == idProyecto, cancellationToken);

        if (proyecto is null)
        {
            return NotFound(new { mensaje = "No se encontró el proyecto." });
        }

        if (proyecto.EstadoPublicacion != "publicado")
        {
            return Conflict(new { mensaje = "Solo se puede retirar una publicación vigente." });
        }

        proyecto.EstadoPublicacion = "retirado";
        proyecto.EsDestacado = false;
        proyecto.FechaActualizacion = AhoraUtc();

        _db.TblHistorials.Add(new TblHistorial
        {
            IdUsuario = idSupervisor,
            IdProyecto = idProyecto,
            Accion = "retiro",
            Detalle = motivo
        });

        // Avisa al solicitante.
        var entrega = await _db.TblEntregas
            .Where(item => item.IdProyecto == idProyecto && item.EstadoEntrega == "aprobada")
            .OrderByDescending(item => item.FechaRevision)
            .FirstOrDefaultAsync(cancellationToken);

        if (entrega is not null)
        {
            _db.TblNotificacions.Add(new TblNotificacion
            {
                IdEntrega = entrega.IdEntrega,
                IdUsuarioDestino = entrega.IdUsuarioEnvia,
                Mensaje = "Tu publicación fue retirada del catálogo. Motivo: " + motivo
            });
        }

        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new { mensaje = "La publicación se retiró del catálogo." });
    }

    /// <summary>RF-12: marcar o desmarcar un trabajo publicado como destacado.</summary>
    [HttpPut("proyectos/{idProyecto:int}/destacado")]
    public async Task<IActionResult> MarcarDestacado(
        int idProyecto,
        [FromBody] DestacadoRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryObtenerUsuario(out var idSupervisor))
        {
            return Unauthorized();
        }

        var proyecto = await _db.TblProyectos
            .FirstOrDefaultAsync(item => item.IdProyecto == idProyecto, cancellationToken);

        if (proyecto is null)
        {
            return NotFound(new { mensaje = "No se encontró el proyecto." });
        }

        if (request.Destacado && proyecto.EstadoPublicacion != "publicado")
        {
            return Conflict(new { mensaje = "Solo un trabajo publicado puede marcarse como destacado." });
        }

        if (proyecto.EsDestacado != request.Destacado)
        {
            proyecto.EsDestacado = request.Destacado;
            proyecto.FechaActualizacion = AhoraUtc();
            _db.TblHistorials.Add(new TblHistorial
            {
                IdUsuario = idSupervisor,
                IdProyecto = idProyecto,
                Accion = "destacado",
                Detalle = request.Destacado
                    ? "Se marcó como trabajo destacado."
                    : "Se quitó la marca de destacado."
            });
            await _db.SaveChangesAsync(cancellationToken);
        }

        return Ok(new
        {
            destacado = proyecto.EsDestacado,
            mensaje = proyecto.EsDestacado
                ? "El trabajo se marcó como destacado."
                : "El trabajo ya no está marcado como destacado."
        });
    }

    /// <summary>Aplica el permiso al proyecto y a sus materiales; publica si corresponde.</summary>
    private static string? AplicarPermiso(
        TblProyecto proyecto,
        TblEntrega entrega,
        string permiso,
        List<int>? recursosAutorizados)
    {
        var autorizados = (recursosAutorizados ?? []).ToHashSet();
        var idsEntrega = entrega.TblRecursos.Select(recurso => recurso.IdRecurso).ToHashSet();

        if (!autorizados.IsSubsetOf(idsEntrega))
        {
            return "Los materiales autorizados deben pertenecer a esta entrega.";
        }

        if (permiso == PermisoFichaYMateriales && autorizados.Count == 0)
        {
            return "Selecciona al menos un material autorizado o elige «Solo la ficha».";
        }

        foreach (var recurso in entrega.TblRecursos)
        {
            recurso.DifusionAutorizada =
                permiso == PermisoFichaYMateriales && autorizados.Contains(recurso.IdRecurso);
        }

        proyecto.EstadoAutorizacion = permiso switch
        {
            PermisoSoloFicha or PermisoFichaYMateriales => "autorizado",
            PermisoNoAutorizado => "no_autorizado",
            _ => "pendiente"
        };

        // Un trabajo retirado no se vuelve a publicar solo por cambiar el permiso.
        if (proyecto.EstadoPublicacion != "retirado")
        {
            proyecto.EstadoPublicacion = proyecto.EstadoAutorizacion == "autorizado"
                ? "publicado"
                : "no_publicado";
        }

        if (proyecto.EstadoPublicacion != "publicado")
        {
            proyecto.EsDestacado = false;
        }

        return null;
    }

    /// <summary>RF-16: marca qué asesores autorizaron mostrar su nombre.</summary>
    private async Task AplicarPermisoAsesoresAsync(
        int idProyecto,
        List<int>? asesoresAutorizados,
        CancellationToken cancellationToken)
    {
        var autorizados = (asesoresAutorizados ?? []).ToHashSet();
        var asesores = await _db.TblProyectoDocentes
            .Where(item => item.IdProyecto == idProyecto)
            .ToListAsync(cancellationToken);

        foreach (var asesor in asesores)
        {
            asesor.NombreAutorizado = autorizados.Contains(asesor.IdDocente);
        }
    }

    private static object MapearAsesores(TblProyecto proyecto) =>
        proyecto.TblProyectoDocentes
            .Select(asesor => new
            {
                idDocente = asesor.IdDocente,
                nombre = asesor.IdDocenteNavigation.IdUsuarioNavigation.Nombres + " " +
                         asesor.IdDocenteNavigation.IdUsuarioNavigation.Apellidos,
                autorizado = asesor.NombreAutorizado
            })
            .OrderBy(asesor => asesor.nombre)
            .ToList();

    private static string PermisoActual(TblProyecto proyecto, TblEntrega entrega) =>
        proyecto.EstadoAutorizacion switch
        {
            "autorizado" when entrega.TblRecursos.Any(recurso => recurso.DifusionAutorizada)
                => PermisoFichaYMateriales,
            "autorizado" => PermisoSoloFicha,
            "no_autorizado" => PermisoNoAutorizado,
            _ => PermisoPendiente
        };

    private static string? NormalizarPermiso(string? permiso) =>
        permiso?.Trim().ToLowerInvariant() switch
        {
            PermisoPendiente => PermisoPendiente,
            PermisoSoloFicha => PermisoSoloFicha,
            PermisoFichaYMateriales => PermisoFichaYMateriales,
            PermisoNoAutorizado => PermisoNoAutorizado,
            _ => null
        };

    private static string DescribirPermiso(string permiso) => permiso switch
    {
        PermisoSoloFicha => "solo la ficha",
        PermisoFichaYMateriales => "la ficha y los materiales seleccionados",
        PermisoNoAutorizado => "no autorizan la difusión",
        _ => "pendiente"
    };

    private static string DescribirPublicacion(TblProyecto proyecto) =>
        proyecto.EstadoPublicacion switch
        {
            "publicado" => "Se publicó en el catálogo.",
            "retirado" => "La publicación sigue retirada.",
            _ when proyecto.EstadoAutorizacion == "no_autorizado"
                => "No se publicará porque los autores no autorizaron la difusión.",
            _ => "La publicación espera el permiso de los autores."
        };

    private static object MapearRecurso(TblRecurso recurso) => new
    {
        id = recurso.IdRecurso,
        nombre = recurso.Nombre,
        tipo = recurso.IdTipoRecursoNavigation.Nombre,
        url = recurso.IdTipoRecursoNavigation.Nombre == "enlace" ? recurso.Ubicacion : null,
        autorizado = recurso.DifusionAutorizada
    };

    private bool TryObtenerUsuario(out int idUsuario) =>
        int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out idUsuario);

    // La base guarda fechas UTC sin zona.
    private static DateTime AhoraUtc() =>
        DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
}

public sealed class DecisionRevisionRequest
{
    [Required]
    public string Decision { get; set; } = string.Empty;

    [StringLength(2000)]
    public string? Observacion { get; set; }

    /// <summary>pendiente, solo_ficha, ficha_y_materiales o no_autorizado (solo al aprobar).</summary>
    public string? Permiso { get; set; }

    public List<int>? RecursosAutorizados { get; set; }

    /// <summary>Asesores que autorizaron mostrar su nombre.</summary>
    public List<int>? AsesoresAutorizados { get; set; }
}

public sealed class PermisoRequest
{
    [Required]
    public string Permiso { get; set; } = string.Empty;

    public List<int>? RecursosAutorizados { get; set; }

    /// <summary>Asesores que autorizaron mostrar su nombre.</summary>
    public List<int>? AsesoresAutorizados { get; set; }
}

public sealed class RetiroRequest
{
    [StringLength(2000)]
    public string? Motivo { get; set; }
}

public sealed class DestacadoRequest
{
    public bool Destacado { get; set; }
}
