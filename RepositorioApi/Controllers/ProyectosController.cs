using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

using RepositorioApi.Services;

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

    /// <summary>RF-17: envía un trabajo a revisión.</summary>
    [HttpPost]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public Task<IActionResult> Crear(
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken) =>
        RegistrarEntregaAsync(request, idEntregaBase: null, esActualizacion: false, cancellationToken);

    /// <summary>RF-20: reenvía una entrega a la que se pidieron correcciones.</summary>
    [HttpPost("mis-proyectos/{idEntrega:int}/reenvio")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public Task<IActionResult> Reenviar(
        int idEntrega,
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken) =>
        RegistrarEntregaAsync(request, idEntrega, esActualizacion: false, cancellationToken);

    /// <summary>RF-08: envía cambios a un trabajo publicado; se aplican al aprobarse.</summary>
    [HttpPost("mis-proyectos/{idEntrega:int}/actualizacion")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaximoSolicitudBytes)]
    public Task<IActionResult> Actualizar(
        int idEntrega,
        [FromForm] CrearProyectoRequest request,
        CancellationToken cancellationToken) =>
        RegistrarEntregaAsync(request, idEntrega, esActualizacion: true, cancellationToken);

    /// <summary>Valida y guarda una entrega nueva, un reenvío o una actualización.</summary>
    private async Task<IActionResult> RegistrarEntregaAsync(
        CrearProyectoRequest request,
        int? idEntregaBase,
        bool esActualizacion,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(
                User.FindFirstValue(ClaimTypes.NameIdentifier),
                out var idUsuario))
        {
            return Unauthorized(new { mensaje = "No se identificó la cuenta que envía." });
        }

        // Supervisores y administradores no envían proyectos.
        if (User.IsInRole("supervisor"))
        {
            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { mensaje = "Las cuentas de supervisor revisan entregas; no envían proyectos." });
        }

        if (User.IsInRole("administrador"))
        {
            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { mensaje = "Las cuentas de administrador gestionan el sistema; no envían proyectos." });
        }

        // La entrega base debe ser propia y la última del proyecto.
        TblEntrega? entregaCorregida = null;
        if (idEntregaBase is not null)
        {
            entregaCorregida = await _db.TblEntregas
                .Include(item => item.IdProyectoNavigation)
                .Include(item => item.TblRecursos)
                    .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
                .FirstOrDefaultAsync(
                    item => item.IdEntrega == idEntregaBase && item.IdUsuarioEnvia == idUsuario,
                    cancellationToken);

            if (entregaCorregida is null)
            {
                return NotFound(new { mensaje = "No se encontró la solicitud." });
            }

            if (esActualizacion)
            {
                if (entregaCorregida.EstadoEntrega != "aprobada" ||
                    entregaCorregida.IdProyectoNavigation.EstadoPublicacion != "publicado")
                {
                    return Conflict(new { mensaje = "Solo puedes actualizar un trabajo publicado." });
                }
            }
            else if (entregaCorregida.EstadoEntrega != "con_correcciones")
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
        }

        var titulo = request.Titulo.Trim();
        var resumen = request.Resumen.Trim();
        if (titulo.Length is < Validacion.TituloMinimo or > Validacion.TituloMaximo)
        {
            return BadRequest(new { mensaje = $"El título debe tener entre {Validacion.TituloMinimo} y {Validacion.TituloMaximo} caracteres." });
        }

        if (resumen.Length is < Validacion.ResumenMinimo or > Validacion.ResumenMaximo)
        {
            return BadRequest(new { mensaje = $"El resumen debe tener entre {Validacion.ResumenMinimo} y {Validacion.ResumenMaximo} caracteres." });
        }

        if (Validacion.TienePalabraDemasiadoLarga(titulo) || Validacion.TienePalabraDemasiadoLarga(resumen))
        {
            return BadRequest(new { mensaje = "El título o el resumen tienen texto sin espacios demasiado largo. Revisa que estén bien escritos." });
        }

        if (request.Anio < Validacion.AnioMinimo || request.Anio > DateTime.Now.Year)
        {
            return BadRequest(new { mensaje = $"El año debe estar entre {Validacion.AnioMinimo} y {DateTime.Now.Year}." });
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
                !Validacion.EsNombrePersona(autor.Nombres) ||
                !Validacion.EsNombrePersona(autor.Apellidos)))
        {
            return BadRequest(new { mensaje = "Los nombres y apellidos de los autores solo llevan letras y al menos 2 caracteres." });
        }

        if (autores.Any(autor => !string.IsNullOrWhiteSpace(autor.Carnet) && !Validacion.EsCarnet(autor.Carnet)))
        {
            return BadRequest(new { mensaje = "El carnet lleva dos letras y cinco números, por ejemplo AB12345." });
        }

        var nombresAutores = autores
            .Select(autor => (autor.Nombres.Trim() + " " + autor.Apellidos.Trim()).ToLowerInvariant())
            .ToList();
        if (nombresAutores.Distinct(StringComparer.Ordinal).Count() != nombresAutores.Count)
        {
            return BadRequest(new { mensaje = "Hay un autor repetido." });
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
            // ck_etiqueta_nombre exige minúsculas.
            .Select(palabra => palabra.Trim().ToLowerInvariant())
            .Where(palabra => palabra.Length > 0)
            .Distinct(StringComparer.Ordinal)
            .ToList();

        // RF-17: las palabras clave son opcionales, hasta 10.
        if (palabrasClave.Count > Validacion.MaximoPalabrasClave)
        {
            return BadRequest(new { mensaje = $"Agrega hasta {Validacion.MaximoPalabrasClave} palabras clave." });
        }

        if (palabrasClave.Any(palabra => palabra.Length is < 2 or > 60 || Validacion.TienePalabraDemasiadoLarga(palabra)))
        {
            return BadRequest(new { mensaje = "Cada palabra clave debe tener entre 2 y 60 caracteres." });
        }

        var enlaces = (request.Enlaces ?? [])
            .Select(enlace => enlace.Trim())
            .Where(enlace => enlace.Length > 0)
            .ToList();

        if (enlaces.Count > Validacion.MaximoEnlaces || enlaces.Any(enlace => enlace.Length > 500))
        {
            return BadRequest(new { mensaje = $"Agrega hasta {Validacion.MaximoEnlaces} enlaces de máximo 500 caracteres." });
        }

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
                return BadRequest(new { mensaje = "Los materiales que conservas deben ser de la versión anterior." });
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

        // Revisa la firma del archivo, no solo la extensión.
        foreach (var item in archivos)
        {
            if (!await Validacion.ContenidoCoincideAsync(item.Archivo, item.Extension, cancellationToken))
            {
                return BadRequest(new { mensaje = $"El archivo «{Path.GetFileName(item.Archivo.FileName)}» no es un {item.TipoNombre} válido." });
            }
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
        // La asignatura debe estar en el plan de la carrera.
        var materiaExiste = request.IdMateria is null ||
            await _db.TblCarreraMateria.AnyAsync(
                item => item.IdMateria == request.IdMateria && item.IdCarrera == request.IdCarrera,
                cancellationToken);

        if (tipo is null || !carreraExiste || !tematicaExiste)
        {
            return BadRequest(new { mensaje = "Selecciona un tipo, carrera y temática válidos." });
        }

        // Solo el proyecto de curso lleva asignatura.
        if (request.IdMateria is not null &&
            !tipo.Nombre.Contains("curso", StringComparison.OrdinalIgnoreCase))
        {
            return BadRequest(new { mensaje = "Solo los proyectos de curso llevan asignatura." });
        }

        // Y si es de curso, es obligatoria cuando la carrera tiene plan.
        if (request.IdMateria is null &&
            tipo.Nombre.Contains("curso", StringComparison.OrdinalIgnoreCase) &&
            await _db.TblCarreraMateria.AnyAsync(item => item.IdCarrera == request.IdCarrera, cancellationToken))
        {
            return BadRequest(new { mensaje = "Selecciona la asignatura del proyecto de curso." });
        }

        if (!materiaExiste)
        {
            return BadRequest(new { mensaje = "La asignatura elegida no pertenece al plan de la carrera seleccionada." });
        }

        var requierePdf = tipo.Nombre.Contains("tesis", StringComparison.OrdinalIgnoreCase) ||
                          tipo.Nombre.Contains("graduación", StringComparison.OrdinalIgnoreCase);
        var tienePdf = (request.Pdfs?.Any(archivo => archivo.Length > 0) ?? false) ||
                       conservados.Any(recurso => recurso.IdTipoRecursoNavigation.Nombre == "pdf");

        if (requierePdf && !tienePdf)
        {
            return BadRequest(new { mensaje = "Para tesis y trabajos de graduación debes adjuntar el PDF completo." });
        }

        // RF-16: asesores opcionales, hasta 3.
        var idsAsesores = (request.IdDocentesAsesores ?? []).Where(id => id > 0).Distinct().ToList();
        if (idsAsesores.Count > 3)
        {
            return BadRequest(new { mensaje = "Registra hasta 3 docentes asesores." });
        }

        if (idsAsesores.Count > 0)
        {
            var asesoresValidos = await _db.TblDocentes
                .CountAsync(
                    docente => idsAsesores.Contains(docente.IdDocente) && docente.IdUsuarioNavigation.Activo,
                    cancellationToken);
            if (asesoresValidos != idsAsesores.Count)
            {
                return BadRequest(new { mensaje = "Selecciona docentes asesores válidos." });
            }
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

        var datos = new DatosProyecto
        {
            Titulo = titulo,
            Resumen = resumen,
            Anio = request.Anio,
            IdTipoProyecto = request.IdTipoProyecto,
            IdCarrera = request.IdCarrera,
            IdTematica = request.IdTematica,
            IdMateria = request.IdMateria,
            Autores = autores,
            PalabrasClave = palabrasClave,
            IdDocentesAsesores = idsAsesores
        };

        // Si ya está publicado, los cambios esperan en la entrega hasta aprobarse.
        var esPropuesta = esReenvio && proyecto.EstadoPublicacion == "publicado";

        var entrega = new TblEntrega
        {
            IdProyectoNavigation = proyecto,
            IdUsuarioEnvia = idUsuario,
            EstadoEntrega = "pendiente",
            DatosPropuestos = esPropuesta ? datos.Serializar() : null
        };

        var archivosGuardados = new List<string>();
        var idsAutoresAnteriores = new List<int>();

        await using var transaction = await _db.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            if (!esReenvio)
            {
                // El proyecto nuevo necesita su id antes de ligarle autores.
                datos.AplicarEscalares(proyecto);
                _db.TblProyectos.Add(proyecto);
            }

            _db.TblEntregas.Add(entrega);
            await _db.SaveChangesAsync(cancellationToken);

            if (!esPropuesta)
            {
                if (esReenvio)
                {
                    proyecto.FechaActualizacion = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);
                }

                idsAutoresAnteriores = await datos.AplicarAsync(_db, proyecto, reemplazar: esReenvio, cancellationToken);
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

            // Los materiales conservados pasan a la nueva entrega (mismo archivo).
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
                // ck_historial_accion exige minúsculas.
                Accion = esActualizacion ? "actualización" : esReenvio ? "reenvío" : "envío",
                Detalle = esActualizacion
                    ? "Actualización del trabajo publicado pendiente de revisión del supervisor."
                    : esReenvio
                        ? "Versión corregida registrada y pendiente de revisión del supervisor."
                        : "Solicitud registrada y pendiente de revisión del supervisor."
            });

            // Aviso a los supervisores.
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
                    Mensaje = (esActualizacion
                        ? "Nueva entrega recibida (actualización de un trabajo publicado) para revisión: "
                        : esReenvio
                            ? "Nueva entrega recibida (versión corregida) para revisión: "
                            : "Nueva entrega recibida para revisión: ") + datos.Titulo + "."
                });
            }

            await _db.SaveChangesAsync(cancellationToken);

            // Borra los autores que quedaron sin proyecto.
            await DatosProyecto.LimpiarAutoresAsync(_db, idsAutoresAnteriores, cancellationToken);

            await transaction.CommitAsync(cancellationToken);

            return StatusCode(StatusCodes.Status201Created, new
            {
                idProyecto = proyecto.IdProyecto,
                idEntrega = entrega.IdEntrega,
                estado = "Pendiente",
                publicado = false,
                mensaje = esActualizacion
                    ? "La actualización se envió. Mientras el supervisor la revisa, el catálogo muestra la versión publicada."
                    : esReenvio
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
            titulo = DatosProyecto.Leer(entrega.DatosPropuestos)?.Titulo ?? entrega.IdProyectoNavigation.Titulo,
            tipoTrabajo = entrega.IdProyectoNavigation.IdTipoProyectoNavigation.Nombre,
            esActualizacion = entrega.DatosPropuestos != null,
            fechaEnvio = entrega.FechaEnvio,
            ultimaActualizacion = entrega.FechaRevision ?? entrega.FechaEnvio,
            version = versiones[entrega.IdEntrega],
            estado = TraducirEstado(entrega.EstadoEntrega),
            puedeEliminar = entrega.EstadoEntrega == "pendiente",
            puedeReenviar = PuedeReenviar(entrega, ultimasPorProyecto.Contains(entrega.IdEntrega)),
            puedeActualizar = PuedeActualizar(entrega, ultimasPorProyecto.Contains(entrega.IdEntrega)),
            esUltimaVersion = ultimasPorProyecto.Contains(entrega.IdEntrega),
            observacion = entrega.TblNotificacions
                .OrderByDescending(notificacion => notificacion.FechaEnvio)
                .Select(notificacion => notificacion.Mensaje)
                .FirstOrDefault()
        }));
    }

    /// <summary>Detalle de una solicitud propia.</summary>
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
            .Include(item => item.IdProyectoNavigation)
                .ThenInclude(proyecto => proyecto.TblProyectoDocentes)
                    .ThenInclude(asesor => asesor.IdDocenteNavigation)
                        .ThenInclude(docente => docente.IdUsuarioNavigation)
            .Include(item => item.TblRecursos)
                .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .Include(item => item.TblNotificacions.Where(notificacion => notificacion.IdUsuarioDestino == idUsuario))
            .Include(item => item.IdUsuarioRevisaNavigation)
            .FirstOrDefaultAsync(
                item => item.IdEntrega == idEntrega && item.IdUsuarioEnvia == idUsuario,
                cancellationToken);

        // 404 también si es de otra cuenta, para no revelar que existe.
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

        // Una actualización muestra los datos propuestos.
        var propuesta = DatosProyecto.Leer(entrega.DatosPropuestos);
        var vista = propuesta is null ? null : await propuesta.DescribirAsync(_db, cancellationToken);

        return Ok(new
        {
            id = entrega.IdEntrega,
            idProyecto = entrega.IdProyecto,
            // Ids para precargar el formulario de corrección.
            idTipoProyecto = propuesta?.IdTipoProyecto ?? proyecto.IdTipoProyecto,
            idDepartamento = vista?.IdDepartamento ?? proyecto.IdCarreraNavigation.IdDepartamento,
            idCarrera = propuesta?.IdCarrera ?? proyecto.IdCarrera,
            idTematica = propuesta?.IdTematica ?? proyecto.IdTematica,
            idMateria = propuesta is null ? proyecto.IdMateria : propuesta.IdMateria,
            esUltimaVersion,
            esActualizacion = propuesta is not null,
            puedeReenviar = PuedeReenviar(entrega, esUltimaVersion),
            puedeActualizar = PuedeActualizar(entrega, esUltimaVersion),
            titulo = propuesta?.Titulo ?? proyecto.Titulo,
            resumen = propuesta?.Resumen ?? proyecto.Resumen,
            anio = propuesta?.Anio ?? proyecto.Anio,
            tipoTrabajo = vista?.TipoTrabajo ?? proyecto.IdTipoProyectoNavigation.Nombre,
            departamento = vista?.Departamento ?? proyecto.IdCarreraNavigation.IdDepartamentoNavigation.Nombre,
            carrera = vista?.Carrera ?? proyecto.IdCarreraNavigation.Nombre,
            tematica = vista?.Tematica ?? proyecto.IdTematicaNavigation.Nombre,
            materia = vista is null ? proyecto.IdMateriaNavigation?.Nombre : vista.Materia,
            fechaEnvio = entrega.FechaEnvio,
            fechaRevision = entrega.FechaRevision,
            ultimaActualizacion = entrega.FechaRevision ?? entrega.FechaEnvio,
            revisor = entrega.IdUsuarioRevisaNavigation == null
                ? null
                : entrega.IdUsuarioRevisaNavigation.Nombres + " " +
                  entrega.IdUsuarioRevisaNavigation.Apellidos,
            version,
            estado = TraducirEstado(entrega.EstadoEntrega),
            puedeEliminar = entrega.EstadoEntrega == "pendiente",
            autores = propuesta is not null
                ? propuesta.Autores.Select(autor => new
                {
                    nombres = autor.Nombres.Trim(),
                    apellidos = autor.Apellidos.Trim(),
                    carnet = string.IsNullOrWhiteSpace(autor.Carnet) ? null : autor.Carnet.Trim().ToUpperInvariant()
                }).ToList()
                : proyecto.TblProyectoAutors
                    .OrderBy(relacion => relacion.OrdenAutoria)
                    .Select(relacion => new
                    {
                        nombres = relacion.IdAutorNavigation.Nombres,
                        apellidos = relacion.IdAutorNavigation.Apellidos,
                        carnet = relacion.IdAutorNavigation.Carnet
                    }).ToList(),
            asesores = vista is not null
                ? vista.Asesores.Select(asesor => new
                {
                    idDocente = asesor.IdDocente,
                    nombre = asesor.Nombre,
                    autorizado = false
                }).ToList()
                : proyecto.TblProyectoDocentes
                    .Select(asesor => new
                    {
                        idDocente = asesor.IdDocente,
                        nombre = asesor.IdDocenteNavigation.IdUsuarioNavigation.Nombres + " " +
                                 asesor.IdDocenteNavigation.IdUsuarioNavigation.Apellidos,
                        autorizado = asesor.NombreAutorizado
                    })
                    .OrderBy(asesor => asesor.nombre)
                    .ToList(),
            palabrasClave = propuesta is not null
                ? propuesta.PalabrasClave.OrderBy(nombre => nombre).ToList()
                : proyecto.IdEtiqueta
                    .Select(etiqueta => etiqueta.Nombre)
                    .OrderBy(nombre => nombre)
                    .ToList(),
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

    /// <summary>Elimina una solicitud propia que sigue pendiente.</summary>
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
                // Quedan otras versiones: solo se registra en el historial.
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
                // Era la única entrega: se borra el proyecto completo.
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

                // Autores sin cuenta que ya no tienen proyectos.
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

        // Los archivos se borran después del commit y solo si otra versión no los usa.
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
        esUltimaVersion && entrega.EstadoEntrega == "con_correcciones";

    /// <summary>Solo la versión aprobada vigente de un trabajo publicado se puede actualizar.</summary>
    private static bool PuedeActualizar(TblEntrega entrega, bool esUltimaVersion) =>
        esUltimaVersion &&
        entrega.EstadoEntrega == "aprobada" &&
        entrega.IdProyectoNavigation.EstadoPublicacion == "publicado";

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
    [Required(ErrorMessage = "Escribe el título del proyecto.")]
    public string Titulo { get; set; } = string.Empty;

    [Required(ErrorMessage = "Escribe el resumen del proyecto.")]
    public string Resumen { get; set; } = string.Empty;

    [Range(1, 9999, ErrorMessage = "Escribe el año del trabajo.")]
    public int Anio { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Selecciona el tipo de trabajo.")]
    public int IdTipoProyecto { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Selecciona la carrera.")]
    public int IdCarrera { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Selecciona el área temática.")]
    public int IdTematica { get; set; }

    public int? IdMateria { get; set; }

    [Required]
    public string AutoresJson { get; set; } = "[]";

    public List<string>? PalabrasClave { get; set; } = [];

    public List<string>? Enlaces { get; set; } = [];

    public List<IFormFile>? Pdfs { get; set; } = [];

    public List<IFormFile>? ArchivosZip { get; set; } = [];

    /// <summary>Materiales de la versión anterior que se conservan (solo en reenvío).</summary>
    public List<int>? ConservarRecursos { get; set; } = [];

    /// <summary>Docentes asesores, hasta 3.</summary>
    public List<int>? IdDocentesAsesores { get; set; } = [];
}

public sealed class AutorProyectoRequest
{
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string? Carnet { get; set; }
}
