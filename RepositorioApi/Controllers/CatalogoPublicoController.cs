using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;

namespace RepositorioApi.Controllers;

/// <summary>
/// Catálogo público: solo fichas publicadas y autorizadas (RF-07), y solo los
/// materiales que los autores permitieron difundir (RF-10, RF-11).
/// </summary>
[ApiController]
[Route("api/catalogo")]
public sealed class CatalogoPublicoController : ControllerBase
{
    private readonly RepositorioDbContext _db;
    private readonly IWebHostEnvironment _environment;

    public CatalogoPublicoController(RepositorioDbContext db, IWebHostEnvironment environment)
    {
        _db = db;
        _environment = environment;
    }

    [HttpGet]
    public async Task<IActionResult> ObtenerPublicados(CancellationToken cancellationToken)
    {
        var proyectos = await _db.TblProyectos
            .AsNoTracking()
            .AsSplitQuery()
            .Where(proyecto => proyecto.EstadoPublicacion == "publicado" &&
                               proyecto.EstadoAutorizacion == "autorizado")
            .Include(proyecto => proyecto.IdTipoProyectoNavigation)
            .Include(proyecto => proyecto.IdCarreraNavigation)
                .ThenInclude(carrera => carrera.IdDepartamentoNavigation)
            .Include(proyecto => proyecto.IdTematicaNavigation)
            .Include(proyecto => proyecto.IdMateriaNavigation)
            .Include(proyecto => proyecto.IdEtiqueta)
            .Include(proyecto => proyecto.TblProyectoDocentes.Where(asesor => asesor.NombreAutorizado))
                .ThenInclude(asesor => asesor.IdDocenteNavigation)
                    .ThenInclude(docente => docente.IdUsuarioNavigation)
            .Include(proyecto => proyecto.TblProyectoAutors)
                .ThenInclude(relacion => relacion.IdAutorNavigation)
            .Include(proyecto => proyecto.TblEntregas.Where(entrega => entrega.EstadoEntrega == "aprobada"))
                .ThenInclude(entrega => entrega.TblRecursos)
                    .ThenInclude(recurso => recurso.IdTipoRecursoNavigation)
            .OrderByDescending(proyecto => proyecto.Anio)
            .ThenBy(proyecto => proyecto.Titulo)
            .ToListAsync(cancellationToken);

        return Ok(proyectos.Select(proyecto =>
        {
            // La versión visible es la última entrega aprobada (RF-08).
            var vigente = proyecto.TblEntregas
                .OrderByDescending(entrega => entrega.FechaRevision)
                .FirstOrDefault();
            var recursos = (vigente?.TblRecursos ?? [])
                .Where(recurso => recurso.DifusionAutorizada)
                .OrderBy(recurso => recurso.IdRecurso)
                .Select(recurso => new
                {
                    id = recurso.IdRecurso,
                    nombre = recurso.Nombre,
                    tipo = recurso.IdTipoRecursoNavigation.Nombre,
                    url = recurso.IdTipoRecursoNavigation.Nombre == "enlace" ? recurso.Ubicacion : null
                })
                .ToList();

            return new
            {
                id = proyecto.IdProyecto,
                titulo = proyecto.Titulo,
                autores = proyecto.TblProyectoAutors
                    .OrderBy(relacion => relacion.OrdenAutoria)
                    .Select(relacion =>
                        relacion.IdAutorNavigation.Nombres + " " +
                        relacion.IdAutorNavigation.Apellidos)
                    .ToList(),
                anio = proyecto.Anio,
                carrera = proyecto.IdCarreraNavigation.Nombre,
                departamento = proyecto.IdCarreraNavigation.IdDepartamentoNavigation.Nombre,
                tematica = proyecto.IdTematicaNavigation.Nombre,
                tipoTrabajo = proyecto.IdTipoProyectoNavigation.Nombre,
                materia = proyecto.IdMateriaNavigation?.Nombre,
                resumen = proyecto.Resumen,
                palabrasClave = proyecto.IdEtiqueta.Select(etiqueta => etiqueta.Nombre).OrderBy(nombre => nombre).ToList(),
                destacado = proyecto.EsDestacado,
                // RF-16: solo los asesores que autorizaron mostrar su nombre.
                asesores = proyecto.TblProyectoDocentes
                    .Select(asesor =>
                        asesor.IdDocenteNavigation.IdUsuarioNavigation.Nombres + " " +
                        asesor.IdDocenteNavigation.IdUsuarioNavigation.Apellidos)
                    .OrderBy(nombre => nombre)
                    .ToList(),
                permiso = recursos.Count > 0 ? "ficha_y_materiales" : "solo_ficha",
                recursos
            };
        }));
    }

    /// <summary>
    /// Descarga pública de un material. Un material reservado o de una ficha
    /// retirada no se entrega aunque se conozca su dirección (RF-11).
    /// </summary>
    [HttpGet("recursos/{idRecurso:int}")]
    public async Task<IActionResult> DescargarRecurso(int idRecurso, CancellationToken cancellationToken)
    {
        var recurso = await _db.TblRecursos
            .AsNoTracking()
            .Include(item => item.IdEntregaNavigation)
                .ThenInclude(entrega => entrega.IdProyectoNavigation)
            .FirstOrDefaultAsync(item => item.IdRecurso == idRecurso, cancellationToken);

        var entrega = recurso?.IdEntregaNavigation;
        var proyecto = entrega?.IdProyectoNavigation;

        if (recurso is null || entrega is null || proyecto is null ||
            !recurso.DifusionAutorizada ||
            entrega.EstadoEntrega != "aprobada" ||
            proyecto.EstadoPublicacion != "publicado" ||
            proyecto.EstadoAutorizacion != "autorizado")
        {
            return NotFound(new { mensaje = "El material no está disponible." });
        }

        // Debe ser la versión publicada, no una aprobada anterior.
        var idVigente = await _db.TblEntregas
            .Where(item => item.IdProyecto == proyecto.IdProyecto && item.EstadoEntrega == "aprobada")
            .OrderByDescending(item => item.FechaRevision)
            .Select(item => item.IdEntrega)
            .FirstAsync(cancellationToken);

        if (idVigente != entrega.IdEntrega)
        {
            return NotFound(new { mensaje = "El material no está disponible." });
        }

        if (Uri.TryCreate(recurso.Ubicacion, UriKind.Absolute, out var enlace) &&
            (enlace.Scheme == Uri.UriSchemeHttp || enlace.Scheme == Uri.UriSchemeHttps))
        {
            return Redirect(enlace.ToString());
        }

        var carpetaSegura = Path.GetFullPath(Path.Combine(
            _environment.ContentRootPath, "App_Data", "entregas")) + Path.DirectorySeparatorChar;
        var ruta = Path.GetFullPath(Path.Combine(_environment.ContentRootPath, recurso.Ubicacion));

        if (!ruta.StartsWith(carpetaSegura, StringComparison.OrdinalIgnoreCase) ||
            !System.IO.File.Exists(ruta))
        {
            return NotFound(new { mensaje = "No se encontró el archivo." });
        }

        var tipoContenido = Path.GetExtension(ruta).ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".zip" => "application/zip",
            _ => "application/octet-stream"
        };

        // Los PDF se abren en el navegador; los ZIP se descargan.
        return tipoContenido == "application/pdf"
            ? PhysicalFile(ruta, tipoContenido, enableRangeProcessing: true)
            : PhysicalFile(ruta, tipoContenido, Path.GetFileName(recurso.Nombre));
    }
}
