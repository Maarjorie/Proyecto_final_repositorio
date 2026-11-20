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

    /// <summary>RF-17: primer envío de un trabajo para revisión.</summary>
    [HttpPost]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public Task<IActionResult> Crear(
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken) =>
        RegistrarEntregaAsync(request, idEntregaCorregida: null, cancellationToken);

    /// <summary>
    /// RF-20: reenviar una versión corregida de una entrega observada. Se
    /// registra como otra entrega del mismo proyecto; la anterior conserva sus
    /// materiales y su decisión. Solo el solicitante de la entrega observada
    /// puede corregirla (RNF-03).
    /// </summary>
    [HttpPost("mis-proyectos/{idEntrega:int}/reenvio")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public Task<IActionResult> Reenviar(
        int idEntrega,
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken) =>
        RegistrarEntregaAsync(request, idEntrega, cancellationToken);

    /// <summary>
    /// Valida y guarda una entrega. Con <paramref name="idEntregaCorregida"/>
    /// es un reenvío: actualiza los datos del proyecto y crea otra versión.
    /// Las reglas de materiales son las mismas para el envío y el reenvío.
    /// </summary>
    private async Task<IActionResult> RegistrarEntregaAsync(
        CrearProyectoRequest request,
        int? idEntregaCorregida,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized(new { mensaje = "No se identificó la cuenta que envía." });
        }

        // RNF-03: el solicitante envía y el supervisor decide. Una cuenta de
        // supervisor no envía proyectos, para no revisar sus propias entregas.
        if (User.IsInRole("supervisor"))
        {
            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { mensaje = "Las cuentas de supervisor revisan entregas; no envían proyectos." });
        }

        // En un reenvío, la entrega a corregir debe ser propia, estar observada
        // y ser la última versión del proyecto.
        TblEntrega? entregaCorregida = null;
        if (idEntregaCorregida is not null)
        {
            entregaCorregida = await _db.TblEntregas
                .Include(item => item.IdProyectoNavigation)
                .Include(item => item.TblRecursos)
                    .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
                .FirstOrDefaultAsync(
                    item => item.IdEntrega == idEntregaCorregida && item.IdUsuarioEnvia == idUsuario,
                    cancellationToken);

            if (entregaCorregida is null)
            {
                return NotFound(new { mensaje = "No se encontró la solicitud." });
            }

            if (entregaCorregida.EstadoEntrega != "con_correcciones")
            {
                return Conflict(new { mensaje = "Solo puedes reenviar una solicitud a la que el supervisor pidió correcciones." });
            }

            var hayVersionPosterior = await _db.TblEntregas.AnyAsync(
                item => item.IdProyecto == entregaCorregida.IdProyecto &&
                        item.FechaEnvio > entregaCorregida.FechaEnvio,
                cancellationToken);

            if (hayVersionPosterior)
            {
                return Conflict(new { mensaje = "Este proyecto ya tiene una versión más reciente." });
            }

            // RF-08: actualizar un trabajo ya publicado sin alterar lo visible
            // requiere guardar los datos por versión, que el esquema aún no tiene.
            if (entregaCorregida.IdProyectoNavigation.EstadoPublicacion == "publicado")
            {
                return Conflict(new { mensaje = "Este trabajo ya está publicado; su actualización todavía no está disponible." });
            }
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

        // En un reenvío se pueden conservar materiales de la versión observada.
        var idsConservar = (request.ConservarRecursos ?? []).Distinct().ToList();
        var conservados = new List<TblRecurso>();
        if (idsConservar.Count > 0)
        {
            if (entregaCorregida is null)
            {
                return BadRequest(new { mensaje = "Solo un reenvío puede conservar materiales anteriores." });
            }

            conservados = entregaCorregida.TblRecursos
                .Where(recurso => idsConservar.Contains(recurso.IdRecurso))
                .ToList();

            if (conservados.Count != idsConservar.Count)
            {
                return BadRequest(new { mensaje = "Los materiales que conservas deben ser de la versión observada." });
            }
        }

        if (archivos.Count == 0 && enlaces.Count == 0 && conservados.Count == 0)
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
        var tienePdf = (request.Pdfs?.Any(archivo => archivo.Length > 0) ?? false) ||
                       conservados.Any(recurso => recurso.IdTipoRecursoNavigation.Nombre == "pdf");

        if (requierePdf && !tienePdf)
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

        var esReenvio = entregaCorregida is not null;
        var proyecto = entregaCorregida?.IdProyectoNavigation ?? new TblProyecto
        {
            EstadoPublicacion = "no_publicado",
            EstadoAutorizacion = "pendiente",
            EsDestacado = false
        };

        proyecto.Titulo = request.Titulo.Trim();
        proyecto.Resumen = request.Resumen.Trim();
        proyecto.Anio = request.Anio;
        proyecto.IdTipoProyecto = request.IdTipoProyecto;
        proyecto.IdCarrera = request.IdCarrera;
        proyecto.IdTematica = request.IdTematica;
        proyecto.IdMateria = request.IdMateria;

        var entrega = new TblEntrega
        {
            IdProyectoNavigation = proyecto,
            IdUsuarioEnvia = idUsuario,
            EstadoEntrega = "pendiente"
        };

        var archivosGuardados = new List<string>();
        var idsAutoresAnteriores = new List<int>();

        await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            if (esReenvio)
            {
                proyecto.FechaActualizacion = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);

                // Los autores y las palabras clave se reemplazan por los corregidos.
                idsAutoresAnteriores = await _db.TblProyectoAutors
                    .Where(item => item.IdProyecto == proyecto.IdProyecto)
                    .Select(item => item.IdAutor)
                    .ToListAsync(cancellationToken);
                await _db.TblProyectoAutors
                    .Where(item => item.IdProyecto == proyecto.IdProyecto)
                    .ExecuteDeleteAsync(cancellationToken);
                await _db.Entry(proyecto).Collection(item => item.IdEtiqueta).LoadAsync(cancellationToken);
                proyecto.IdEtiqueta.Clear();
            }
            else
            {
                _db.TblProyectos.Add(proyecto);
            }

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

            // Los materiales conservados apuntan al mismo archivo; la versión
            // anterior mantiene su propio registro (RF-20, RNF-07).
            foreach (var recurso in conservados)
            {
                _db.TblRecursos.Add(new TblRecurso
                {
                    IdEntrega = entrega.IdEntrega,
                    IdTipoRecurso = recurso.IdTipoRecurso,
                    Nombre = recurso.Nombre,
                    Ubicacion = recurso.Ubicacion
                });
            }

            _db.TblHistorials.Add(new TblHistorial
            {
                IdUsuario = idUsuario,
                IdProyecto = proyecto.IdProyecto,
                // ck_historial_accion exige la acción en minúsculas.
                Accion = esReenvio ? "reenvío" : "envío",
                Detalle = esReenvio
                    ? "Versión corregida registrada y pendiente de revisión del supervisor."
                    : "Solicitud registrada y pendiente de revisión del supervisor."
            });

            // RF-17 / proceso: el sistema avisa al supervisor al recibir una entrega.
            var idsSupervisores = await _db.TblUsuarios
                .Where(usuario => usuario.Activo &&
                                  usuario.IdRols.Any(rol => rol.NombreRol == "supervisor"))
                .Select(usuario => usuario.IdUsuario)
                .ToListAsync(cancellationToken);

            foreach (var idSupervisor in idsSupervisores)
            {
                _db.TblNotificacions.Add(new TblNotificacion
                {
                    IdEntrega = entrega.IdEntrega,
                    IdUsuarioDestino = idSupervisor,
                    Mensaje = (esReenvio
                        ? "Nueva entrega recibida (versión corregida) para revisión: "
                        : "Nueva entrega recibida para revisión: ") + proyecto.Titulo + "."
                });
            }

            await _db.SaveChangesAsync(cancellationToken);

            // Autores que dejaron de figurar en el proyecto y no tienen cuenta ni otros proyectos.
            if (idsAutoresAnteriores.Count > 0)
            {
                await _db.TblAutors
                    .Where(autor => idsAutoresAnteriores.Contains(autor.IdAutor) &&
                                    autor.IdUsuario == null &&
                                    !autor.TblProyectoAutors.Any())
                    .ExecuteDeleteAsync(cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);

            return StatusCode(StatusCodes.Status201Created, new
            {
                idProyecto = proyecto.IdProyecto,
                idEntrega = entrega.IdEntrega,
                estado = "Pendiente",
                publicado = false,
                mensaje = esReenvio
                    ? "La versión corregida se envió y quedó pendiente de revisión del supervisor."
                    : "El proyecto se envió y quedó pendiente de revisión del supervisor."
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

            _logger.LogError(exception, "No se pudo guardar la entrega enviada por el usuario {IdUsuario}", idUsuario);
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
            .Include(item => item.TblNotificacions.Where(notificacion => notificacion.IdUsuarioDestino == idUsuario))
            .OrderByDescending(item => item.FechaEnvio)
            .ToListAsync(cancellationToken);

        var versiones = entregas
            .GroupBy(item => item.IdProyecto)
            .SelectMany(grupo => grupo
                .OrderBy(item => item.FechaEnvio)
                .Select((entrega, indice) => new { entrega.IdEntrega, Version = indice + 1 }))
            .ToDictionary(item => item.IdEntrega, item => item.Version);

        var ultimasPorProyecto = entregas
            .GroupBy(item => item.IdProyecto)
            .Select(grupo => grupo.OrderByDescending(item => item.FechaEnvio).First().IdEntrega)
            .ToHashSet();

        return Ok(entregas.Select(entrega => new
        {
            id = entrega.IdEntrega,
            idProyecto = entrega.IdProyecto,
            titulo = entrega.IdProyectoNavigation.Titulo,
            tipoTrabajo = entrega.IdProyectoNavigation.IdTipoProyectoNavigation.Nombre,
            fechaEnvio = entrega.FechaEnvio,
            // RF-19: última actualización = fecha de la decisión, o la recepción si sigue pendiente.
            ultimaActualizacion = entrega.FechaRevision ?? entrega.FechaEnvio,
            version = versiones[entrega.IdEntrega],
            estado = TraducirEstado(entrega.EstadoEntrega),
            puedeEliminar = entrega.EstadoEntrega == "pendiente",
            // RF-20: pedir correcciones habilita reenviar la última versión.
            puedeReenviar = PuedeReenviar(entrega, ultimasPorProyecto.Contains(entrega.IdEntrega)),
            esUltimaVersion = ultimasPorProyecto.Contains(entrega.IdEntrega),
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
            .Include(item => item.TblNotificacions.Where(notificacion => notificacion.IdUsuarioDestino == idUsuario))
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
        var esUltimaVersion = !await _db.TblEntregas
            .AnyAsync(
                item => item.IdProyecto == entrega.IdProyecto &&
                        item.FechaEnvio > entrega.FechaEnvio,
                cancellationToken);

        return Ok(new
        {
            id = entrega.IdEntrega,
            idProyecto = entrega.IdProyecto,
            // Identificadores para precargar el formulario de corrección (RF-20).
            idTipoProyecto = proyecto.IdTipoProyecto,
            idDepartamento = proyecto.IdCarreraNavigation.IdDepartamento,
            idCarrera = proyecto.IdCarrera,
            idTematica = proyecto.IdTematica,
            idMateria = proyecto.IdMateria,
            esUltimaVersion,
            puedeReenviar = PuedeReenviar(entrega, esUltimaVersion),
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

        // Los archivos se borran solo después de confirmar la transacción, y solo
        // si ninguna otra versión los conserva (un reenvío puede compartirlos).
        var ubicacionesEnUso = (await _db.TblRecursos
                .AsNoTracking()
                .Select(recurso => recurso.Ubicacion)
                .Where(ubicacion => ubicacion.StartsWith("App_Data/"))
                .ToListAsync(cancellationToken))
            .Select(ubicacion => Path.GetFullPath(Path.Combine(_environment.ContentRootPath, ubicacion)))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var carpetaSegura = Path.GetFullPath(Path.Combine(
            _environment.ContentRootPath, "App_Data", "entregas")) + Path.DirectorySeparatorChar;
        foreach (var ruta in archivos.Where(ruta =>
                     ruta.StartsWith(carpetaSegura, StringComparison.OrdinalIgnoreCase) &&
                     !ubicacionesEnUso.Contains(ruta)))
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
    private static bool PuedeReenviar(TblEntrega entrega, bool esUltimaVersion) =>
        esUltimaVersion &&
        entrega.EstadoEntrega == "con_correcciones" &&
        entrega.IdProyectoNavigation.EstadoPublicacion != "publicado";

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

    /// <summary>Solo en un reenvío: materiales de la versión observada que se conservan.</summary>
    public List<int>? ConservarRecursos { get; set; } = [];
}

public sealed class AutorProyectoRequest
{
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Carnet { get; set; }
}
