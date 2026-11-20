using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Controllers;

[ApiController]
[Authorize]
[Route("api/proyectos")]
public sealed class ProyectosController : ControllerBase
{
    private const long MaximoArchivoBytes = 25 * 1024 * 1024;
    private const long MaximoSolicitudBytes = 80 * 1024 * 1024;

    private readonly RepositorioDbContext _db;
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<ProyectosController> _logger;

    public ProyectosController(
        RepositorioDbContext db,
        IWebHostEnvironment environment,
        ILogger<ProyectosController> logger)
    {
        _db = db;
        _environment = environment;
        _logger = logger;
    }

    [HttpPost]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public async Task<IActionResult> Crear(
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized(new { mensaje = "No se identificó la cuenta que envía." });
        }

        List<AutorProyectoRequest>? autores;
        try
        {
            autores = JsonSerializer.Deserialize<List<AutorProyectoRequest>>(
                request.AutoresJson,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
        catch (JsonException)
        {
            return BadRequest(new { mensaje = "No se pudieron leer los autores." });
        }

        if (autores is null || autores.Count == 0 || autores.Count > 20)
        {
            return BadRequest(new { mensaje = "Agrega entre 1 y 20 autores." });
        }

        if (autores.Any(autor =>
                string.IsNullOrWhiteSpace(autor.Nombres) ||
                string.IsNullOrWhiteSpace(autor.Apellidos) ||
                autor.Nombres.Trim().Length > 100 ||
                autor.Apellidos.Trim().Length > 100 ||
                (autor.Carnet?.Trim().Length ?? 0) > 20))
        {
            return BadRequest(new { mensaje = "Revisa los nombres, apellidos y carnets de los autores." });
        }

        var carnets = autores
            .Where(autor => !string.IsNullOrWhiteSpace(autor.Carnet))
            .Select(autor => autor.Carnet!.Trim().ToUpperInvariant())
            .ToList();

        if (carnets.Distinct(StringComparer.Ordinal).Count() != carnets.Count)
        {
            return BadRequest(new { mensaje = "No repitas el carnet de un autor." });
        }

        var palabrasClave = (request.PalabrasClave ?? [])
            // tbl_etiquetas exige nombres en minúsculas (ck_etiqueta_nombre).
            .Select(palabra => palabra.Trim().ToLowerInvariant())
            .Where(palabra => palabra.Length > 0)
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (palabrasClave.Any(palabra => palabra.Length > 60))
        {
            return BadRequest(new { mensaje = "Cada palabra clave admite hasta 60 caracteres." });
        }

        var enlaces = (request.Enlaces ?? [])
            .Select(enlace => enlace.Trim())
            .Where(enlace => enlace.Length > 0)
            .ToList();

        if (enlaces.Any(enlace =>
                !Uri.TryCreate(enlace, UriKind.Absolute, out var uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps)))
        {
            return BadRequest(new { mensaje = "Los enlaces deben comenzar con http:// o https://." });
        }

        var archivos = (request.Pdfs ?? [])
            .Select(archivo => (Archivo: archivo, TipoNombre: "PDF", Extension: ".pdf"))
            .Concat((request.ArchivosZip ?? [])
                .Select(archivo => (Archivo: archivo, TipoNombre: "ZIP", Extension: ".zip")))
            .ToList();

        if (archivos.Count == 0 && enlaces.Count == 0)
        {
            return BadRequest(new { mensaje = "Agrega al menos un PDF, un ZIP o un enlace." });
        }

        if (archivos.Count > 10 ||
            archivos.Any(item =>
                item.Archivo.Length == 0 ||
                item.Archivo.Length > MaximoArchivoBytes ||
                !string.Equals(
                    Path.GetExtension(item.Archivo.FileName),
                    item.Extension,
                    StringComparison.OrdinalIgnoreCase)) ||
            archivos.Sum(item => item.Archivo.Length) > MaximoSolicitudBytes)
        {
            return BadRequest(new
            {
                mensaje = "Adjunta hasta 10 archivos PDF o ZIP, de máximo 25 MB cada uno."
            });
        }

        var tipo = await _db.TblTipoProyectos
            .AsNoTracking()
            .FirstOrDefaultAsync(
                item => item.IdTipoProyecto == request.IdTipoProyecto,
                cancellationToken);

        var carreraExiste = await _db.TblCarreras
            .AnyAsync(item => item.IdCarrera == request.IdCarrera, cancellationToken);
        var tematicaExiste = await _db.TblTematicas
            .AnyAsync(item => item.IdTematica == request.IdTematica, cancellationToken);
        var materiaExiste = request.IdMateria is null ||
            await _db.TblMateria.AnyAsync(
                item => item.IdMateria == request.IdMateria,
                cancellationToken);

        if (tipo is null || !carreraExiste || !tematicaExiste || !materiaExiste)
        {
            return BadRequest(new { mensaje = "Selecciona un tipo, carrera, temática y asignatura válidos." });
        }

        var requierePdf = tipo.Nombre.Contains("tesis", StringComparison.OrdinalIgnoreCase) ||
                          tipo.Nombre.Contains("graduación", StringComparison.OrdinalIgnoreCase);

        if (requierePdf && !(request.Pdfs?.Any(archivo => archivo.Length > 0) ?? false))
        {
            return BadRequest(new { mensaje = "Para tesis y trabajos de graduación debes adjuntar el PDF completo." });
        }

        var tiposRecurso = await _db.TblTipoRecursos
            .AsNoTracking()
            .ToListAsync(cancellationToken);
        var idsTipoRecurso = tiposRecurso.ToDictionary(
            item => item.Nombre,
            item => item.IdTipoRecurso,
            StringComparer.OrdinalIgnoreCase);

        if (archivos.Any(item => !idsTipoRecurso.ContainsKey(item.TipoNombre)) ||
            (enlaces.Count > 0 && !idsTipoRecurso.ContainsKey("Enlace")))
        {
            return StatusCode(
                StatusCodes.Status503ServiceUnavailable,
                new { mensaje = "Faltan tipos de recurso en el catálogo de la API." });
        }

        var proyecto = new TblProyecto
        {
            Titulo = request.Titulo.Trim(),
            Resumen = request.Resumen.Trim(),
            Anio = request.Anio,
            IdTipoProyecto = request.IdTipoProyecto,
            IdCarrera = request.IdCarrera,
            IdTematica = request.IdTematica,
            IdMateria = request.IdMateria,
            EstadoPublicacion = "no_publicado",
            EstadoAutorizacion = "pendiente",
            EsDestacado = false
        };

        var entrega = new TblEntrega
        {
            IdProyectoNavigation = proyecto,
            IdUsuarioEnvia = idUsuario,
            EstadoEntrega = "pendiente"
        };

        var archivosGuardados = new List<string>();

        await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            _db.TblProyectos.Add(proyecto);
            _db.TblEntregas.Add(entrega);
            await _db.SaveChangesAsync(cancellationToken);

            for (var indice = 0; indice < autores.Count; indice++)
            {
                var autorRequest = autores[indice];
                var carnet = string.IsNullOrWhiteSpace(autorRequest.Carnet)
                    ? null
                    : autorRequest.Carnet.Trim().ToUpperInvariant();

                var autor = carnet is null
                    ? null
                    : await _db.TblAutors.FirstOrDefaultAsync(
                        item => item.Carnet == carnet,
                        cancellationToken);

                if (autor is null)
                {
                    autor = new TblAutor
                    {
                        Nombres = autorRequest.Nombres.Trim(),
                        Apellidos = autorRequest.Apellidos.Trim(),
                        Carnet = carnet
                    };
                    _db.TblAutors.Add(autor);
                    await _db.SaveChangesAsync(cancellationToken);
                }

                _db.TblProyectoAutors.Add(new TblProyectoAutor
                {
                    IdProyecto = proyecto.IdProyecto,
                    IdAutor = autor.IdAutor,
                    OrdenAutoria = indice + 1
                });
            }

            foreach (var palabra in palabrasClave)
            {
                var etiqueta = await _db.TblEtiquetas.FirstOrDefaultAsync(
                    item => item.Nombre == palabra,
                    cancellationToken);

                if (etiqueta is null)
                {
                    etiqueta = new TblEtiqueta { Nombre = palabra };
                    _db.TblEtiquetas.Add(etiqueta);
                }

                proyecto.IdEtiqueta.Add(etiqueta);
            }

            var carpetaEntrega = Path.Combine(
                _environment.ContentRootPath,
                "App_Data",
                "entregas",
                entrega.IdEntrega.ToString());

            if (archivos.Count > 0)
            {
                Directory.CreateDirectory(carpetaEntrega);
            }

            foreach (var item in archivos)
            {
                var nombreOriginal = Path.GetFileName(item.Archivo.FileName).Trim();
                if (nombreOriginal.Length > 200)
                {
                    nombreOriginal = nombreOriginal[^200..];
                }

                var nombreGuardado = Guid.NewGuid().ToString("N") + item.Extension;
                var rutaCompleta = Path.Combine(carpetaEntrega, nombreGuardado);
                await using (var stream = System.IO.File.Create(rutaCompleta))
                {
                    await item.Archivo.CopyToAsync(stream, cancellationToken);
                }
                archivosGuardados.Add(rutaCompleta);

                var ubicacionRelativa = Path
                    .GetRelativePath(_environment.ContentRootPath, rutaCompleta)
                    .Replace(Path.DirectorySeparatorChar, '/');

                _db.TblRecursos.Add(new TblRecurso
                {
                    IdEntrega = entrega.IdEntrega,
                    IdTipoRecurso = idsTipoRecurso[item.TipoNombre],
                    Nombre = nombreOriginal,
                    Ubicacion = ubicacionRelativa
                });
            }

            foreach (var enlace in enlaces)
            {
                var uri = new Uri(enlace);
                _db.TblRecursos.Add(new TblRecurso
                {
                    IdEntrega = entrega.IdEntrega,
                    IdTipoRecurso = idsTipoRecurso["Enlace"],
                    Nombre = "Enlace: " + uri.Host,
                    Ubicacion = enlace
                });
            }

            _db.TblHistorials.Add(new TblHistorial
            {
                IdUsuario = idUsuario,
                IdProyecto = proyecto.IdProyecto,
                // ck_historial_accion exige la acción en minúsculas.
                Accion = "envío",
                Detalle = "Solicitud registrada y pendiente de revisión del supervisor."
            });

            await _db.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            return StatusCode(StatusCodes.Status201Created, new
            {
                idProyecto = proyecto.IdProyecto,
                idEntrega = entrega.IdEntrega,
                estado = "Pendiente",
                publicado = false,
                mensaje = "El proyecto se envió y quedó pendiente de revisión del supervisor."
            });
        }
        catch (Exception exception)
        {
            await transaction.RollbackAsync(cancellationToken);

            foreach (var ruta in archivosGuardados)
            {
                try
                {
                    System.IO.File.Delete(ruta);
                }
                catch (IOException)
                {
                    _logger.LogWarning("No se pudo limpiar el archivo temporal {Ruta}", ruta);
                }
            }

            _logger.LogError(exception, "No se pudo guardar el proyecto enviado por el usuario {IdUsuario}", idUsuario);
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new { mensaje = "No se pudo guardar el envío. Revisa los datos y vuelve a intentarlo." });
        }
    }

    [HttpGet("mis-proyectos")]
    public async Task<IActionResult> ObtenerMisProyectos(CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized();
        }

        var entregas = await _db.TblEntregas
            .AsNoTracking()
            .Where(item => item.IdUsuarioEnvia == idUsuario)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(item => item.TblNotificacions)
            .OrderByDescending(item => item.FechaEnvio)
            .ToListAsync(cancellationToken);

        var versiones = entregas
            .GroupBy(item => item.IdProyecto)
            .SelectMany(grupo => grupo
                .OrderBy(item => item.FechaEnvio)
                .Select((entrega, indice) => new { entrega.IdEntrega, Version = indice + 1 }))
            .ToDictionary(item => item.IdEntrega, item => item.Version);

        return Ok(entregas.Select(entrega => new
        {
            id = entrega.IdEntrega,
            titulo = entrega.IdProyectoNavigation.Titulo,
            tipoTrabajo = entrega.IdProyectoNavigation.IdTipoProyectoNavigation.Nombre,
            fechaEnvio = entrega.FechaEnvio,
            // RF-19: última actualización = fecha de la decisión, o la recepción si sigue pendiente.
            ultimaActualizacion = entrega.FechaRevision ?? entrega.FechaEnvio,
            version = versiones[entrega.IdEntrega],
            estado = TraducirEstado(entrega.EstadoEntrega),
            puedeEliminar = entrega.EstadoEntrega == "pendiente",
            observacion = entrega.TblNotificacions
                .OrderByDescending(notificacion => notificacion.FechaEnvio)
                .Select(notificacion => notificacion.Mensaje)
                .FirstOrDefault()
        }));
    }

    /// <summary>
    /// Detalle de solo lectura de una solicitud enviada por la cuenta actual.
    /// </summary>
    [HttpGet("mis-proyectos/{idEntrega:int}")]
    public async Task<IActionResult> ObtenerDetalle(
        int idEntrega,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized();
        }

        var entrega = await _db.TblEntregas
            .AsNoTracking()
            .AsSplitQuery()
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdCarreraNavigation)
                    .ThenInclude(carrera => carrera.IdDepartamentoNavigation)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdTematicaNavigation)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdMateriaNavigation)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoAutors)
                    .ThenInclude(relacion => relacion.IdAutorNavigation)
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.IdEtiqueta)
            .Include(item => item.TblRecursos)
                .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .Include(item => item.TblNotificacions)
            .Include(item => item.IdUsuarioRevisaNavigation)
            .FirstOrDefaultAsync(
                item => item.IdEntrega == idEntrega && item.IdUsuarioEnvia == idUsuario,
                cancellationToken);

        // Se responde 404 también cuando la entrega es de otra cuenta,
        // para no revelar qué solicitudes existen.
        if (entrega is null)
        {
            return NotFound(new { mensaje = "No se encontró la solicitud." });
        }

        var proyecto = entrega.IdProyectoNavigation;
        var version = await _db.TblEntregas
            .CountAsync(
                item => item.IdProyecto == entrega.IdProyecto &&
                        item.FechaEnvio <= entrega.FechaEnvio,
                cancellationToken);

        return Ok(new
        {
            id = entrega.IdEntrega,
            titulo = proyecto.Titulo,
            resumen = proyecto.Resumen,
            anio = proyecto.Anio,
            tipoTrabajo = proyecto.IdTipoProyectoNavigation.Nombre,
            departamento = proyecto.IdCarreraNavigation.IdDepartamentoNavigation.Nombre,
            carrera = proyecto.IdCarreraNavigation.Nombre,
            tematica = proyecto.IdTematicaNavigation.Nombre,
            materia = proyecto.IdMateriaNavigation?.Nombre,
            fechaEnvio = entrega.FechaEnvio,
            fechaRevision = entrega.FechaRevision,
            // RF-19: recepción y última actualización; RF-18: revisor visible.
            ultimaActualizacion = entrega.FechaRevision ?? entrega.FechaEnvio,
            revisor = entrega.IdUsuarioRevisaNavigation == null
                ? null
                : entrega.IdUsuarioRevisaNavigation.Nombres + " " +
                  entrega.IdUsuarioRevisaNavigation.Apellidos,
            version,
            estado = TraducirEstado(entrega.EstadoEntrega),
            puedeEliminar = entrega.EstadoEntrega == "pendiente",
            autores = proyecto.TblProyectoAutors
                .OrderBy(relacion => relacion.OrdenAutoria)
                .Select(relacion => new
                {
                    nombres = relacion.IdAutorNavigation.Nombres,
                    apellidos = relacion.IdAutorNavigation.Apellidos,
                    carnet = relacion.IdAutorNavigation.Carnet
                }),
            palabrasClave = proyecto.IdEtiqueta
                .Select(etiqueta => etiqueta.Nombre)
                .OrderBy(nombre => nombre),
            recursos = entrega.TblRecursos
                .OrderBy(recurso => recurso.IdRecurso)
                .Select(recurso => new
                {
                    id = recurso.IdRecurso,
                    nombre = recurso.Nombre,
                    tipo = recurso.IdTipoRecursoNavigation.Nombre,
                    url = recurso.IdTipoRecursoNavigation.Nombre == "enlace"
                        ? recurso.Ubicacion
                        : null
                }),
            observaciones = entrega.TblNotificacions
                .OrderByDescending(notificacion => notificacion.FechaEnvio)
                .Select(notificacion => new
                {
                    fecha = notificacion.FechaEnvio,
                    mensaje = notificacion.Mensaje
                })
        });
    }

    /// <summary>
    /// Elimina una solicitud propia mientras siga pendiente de revisión.
    /// Una vez que el supervisor decide, la entrega queda en el historial
    /// y solo el supervisor puede retirar la publicación (RF-10).
    /// </summary>
    [HttpDelete("mis-proyectos/{idEntrega:int}")]
    public async Task<IActionResult> EliminarSolicitud(
        int idEntrega,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized();
        }

        var entrega = await _db.TblEntregas
            .Include(item => item.TblRecursos)
            .FirstOrDefaultAsync(
                item => item.IdEntrega == idEntrega && item.IdUsuarioEnvia == idUsuario,
                cancellationToken);

        if (entrega is null)
        {
            return NotFound(new { mensaje = "No se encontró la solicitud." });
        }

        if (entrega.EstadoEntrega != "pendiente")
        {
            return Conflict(new
            {
                mensaje = "Solo puedes eliminar solicitudes que aún no han sido revisadas."
            });
        }

        var idProyecto = entrega.IdProyecto;
        var archivos = entrega.TblRecursos
            .Where(recurso => !Uri.TryCreate(recurso.Ubicacion, UriKind.Absolute, out _))
            .Select(recurso => Path.GetFullPath(
                Path.Combine(_environment.ContentRootPath, recurso.Ubicacion)))
            .ToList();

        await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            await _db.TblRecursos
                .Where(item => item.IdEntrega == idEntrega)
                .ExecuteDeleteAsync(cancellationToken);
            await _db.TblNotificacions
                .Where(item => item.IdEntrega == idEntrega)
                .ExecuteDeleteAsync(cancellationToken);
            await _db.TblEntregas
                .Where(item => item.IdEntrega == idEntrega)
                .ExecuteDeleteAsync(cancellationToken);

            var quedanEntregas = await _db.TblEntregas
                .AnyAsync(item => item.IdProyecto == idProyecto, cancellationToken);

            if (quedanEntregas)
            {
                // El proyecto conserva otras versiones: solo se registra el retiro.
                _db.TblHistorials.Add(new TblHistorial
                {
                    IdUsuario = idUsuario,
                    IdProyecto = idProyecto,
                    Accion = "eliminación",
                    Detalle = "El solicitante eliminó una versión pendiente de revisión."
                });
                await _db.SaveChangesAsync(cancellationToken);
            }
            else
            {
                // Era la única entrega: el proyecto nunca llegó a revisarse
                // y se elimina con sus relaciones.
                var idsAutores = await _db.TblProyectoAutors
                    .Where(item => item.IdProyecto == idProyecto)
                    .Select(item => item.IdAutor)
                    .ToListAsync(cancellationToken);

                var proyecto = await _db.TblProyectos
                    .Include(item => item.IdEtiqueta)
                    .Include(item => item.IdDocentes)
                    .FirstAsync(item => item.IdProyecto == idProyecto, cancellationToken);
                proyecto.IdEtiqueta.Clear();
                proyecto.IdDocentes.Clear();
                await _db.SaveChangesAsync(cancellationToken);

                await _db.TblProyectoAutors
                    .Where(item => item.IdProyecto == idProyecto)
                    .ExecuteDeleteAsync(cancellationToken);
                await _db.TblHistorials
                    .Where(item => item.IdProyecto == idProyecto)
                    .ExecuteDeleteAsync(cancellationToken);
                await _db.TblFavoritos
                    .Where(item => item.IdProyecto == idProyecto)
                    .ExecuteDeleteAsync(cancellationToken);
                await _db.TblProyectos
                    .Where(item => item.IdProyecto == idProyecto)
                    .ExecuteDeleteAsync(cancellationToken);

                // Autores que solo pertenecían a este proyecto y no tienen cuenta.
                await _db.TblAutors
                    .Where(autor => idsAutores.Contains(autor.IdAutor) &&
                                    autor.IdUsuario == null &&
                                    !autor.TblProyectoAutors.Any())
                    .ExecuteDeleteAsync(cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);
        }
        catch (Exception exception)
        {
            await transaction.RollbackAsync(cancellationToken);
            _logger.LogError(exception, "No se pudo eliminar la entrega {IdEntrega}", idEntrega);
            return StatusCode(
                StatusCodes.Status500InternalServerError,
                new { mensaje = "No se pudo eliminar la solicitud. Inténtalo de nuevo." });
        }

        // Los archivos se borran solo después de confirmar la transacción.
        var carpetaSegura = Path.GetFullPath(Path.Combine(
            _environment.ContentRootPath, "App_Data", "entregas")) + Path.DirectorySeparatorChar;
        foreach (var ruta in archivos.Where(ruta =>
                     ruta.StartsWith(carpetaSegura, StringComparison.OrdinalIgnoreCase)))
        {
            try
            {
                System.IO.File.Delete(ruta);
            }
            catch (IOException)
            {
                _logger.LogWarning("No se pudo borrar el archivo {Ruta}", ruta);
            }
        }

        var carpetaEntrega = Path.Combine(carpetaSegura, idEntrega.ToString());
        try
        {
            if (Directory.Exists(carpetaEntrega) &&
                !Directory.EnumerateFileSystemEntries(carpetaEntrega).Any())
            {
                Directory.Delete(carpetaEntrega);
            }
        }
        catch (IOException)
        {
            _logger.LogWarning("No se pudo borrar la carpeta {Ruta}", carpetaEntrega);
        }

        return Ok(new { mensaje = "La solicitud se eliminó." });
    }

    [HttpGet("recursos/{idRecurso:int}")]
    public async Task<IActionResult> DescargarRecurso(
        int idRecurso,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized();
        }

        var recurso = await _db.TblRecursos
            .AsNoTracking()
            .Include(item => item.IdEntregaNavigation)
            .FirstOrDefaultAsync(item => item.IdRecurso == idRecurso, cancellationToken);

        if (recurso is null)
        {
            return NotFound();
        }

        var esPropietario = recurso.IdEntregaNavigation.IdUsuarioEnvia == idUsuario;
        if (!esPropietario && !User.IsInRole("supervisor"))
        {
            return Forbid();
        }

        if (Uri.TryCreate(recurso.Ubicacion, UriKind.Absolute, out _))
        {
            return BadRequest(new { mensaje = "Este recurso es un enlace externo; usa el enlace mostrado en la revisión." });
        }

        var carpetaSegura = Path.GetFullPath(Path.Combine(
            _environment.ContentRootPath,
            "App_Data",
            "entregas")) + Path.DirectorySeparatorChar;
        var ruta = Path.GetFullPath(Path.Combine(
            _environment.ContentRootPath,
            recurso.Ubicacion));

        if (!ruta.StartsWith(carpetaSegura, StringComparison.OrdinalIgnoreCase) ||
            !System.IO.File.Exists(ruta))
        {
            return NotFound(new { mensaje = "No se encontró el archivo adjunto." });
        }

        var tipoContenido = Path.GetExtension(ruta).ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".zip" => "application/zip",
            _ => "application/octet-stream"
        };

        return PhysicalFile(ruta, tipoContenido, Path.GetFileName(recurso.Nombre));
    }
    private static string TraducirEstado(string estado) =>
        estado.ToLowerInvariant() switch
        {
            "pendiente" => "Pendiente",
            "correcciones" or "con_correcciones" => "Con correcciones",
            "aprobada" or "aprobado" => "Aprobada",
            "rechazada" or "rechazado" => "Rechazada",
            _ => estado
        };
}

public sealed class CrearProyectoRequest
{
    [Required]
    [StringLength(300, MinimumLength = 3)]
    public string Titulo { get; set; } = string.Empty;

    [Required]
    public string Resumen { get; set; } = string.Empty;

    [Range(1900, 2100)]
    public int Anio { get; set; }

    [Range(1, int.MaxValue)]
    public int IdTipoProyecto { get; set; }

    [Range(1, int.MaxValue)]
    public int IdCarrera { get; set; }

    [Range(1, int.MaxValue)]
    public int IdTematica { get; set; }

    public int? IdMateria { get; set; }

    [Required]
    public string AutoresJson { get; set; } = "[]";

    public List<string>? PalabrasClave { get; set; } = [];

    public List<string>? Enlaces { get; set; } = [];

    public List<IFormFile>? Pdfs { get; set; } = [];

    public List<IFormFile>? ArchivosZip { get; set; } = [];
}

public sealed class AutorProyectoRequest
{
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Carnet { get; set; }
}
