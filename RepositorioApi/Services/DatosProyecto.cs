using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Controllers;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Services;

/// <summary>
/// Datos de un proyecto tal como los envía el solicitante. En un envío normal
/// se aplican al proyecto de inmediato; en la actualización de un trabajo
/// publicado (RF-08) se guardan en la entrega y se aplican al aprobarse.
/// </summary>
public sealed class DatosProyecto
{
    public string Titulo { get; set; } = string.Empty;
    public string Resumen { get; set; } = string.Empty;
    public int Anio { get; set; }
    public int IdTipoProyecto { get; set; }
    public int IdCarrera { get; set; }
    public int IdTematica { get; set; }
    public int? IdMateria { get; set; }
    public List<AutorProyectoRequest> Autores { get; set; } = [];
    public List<string> PalabrasClave { get; set; } = [];
    public List<int> IdDocentesAsesores { get; set; } = [];

    private static readonly JsonSerializerOptions Opciones = new(JsonSerializerDefaults.Web);

    public string Serializar() => JsonSerializer.Serialize(this, Opciones);

    public static DatosProyecto? Leer(string? json) =>
        string.IsNullOrWhiteSpace(json) ? null : JsonSerializer.Deserialize<DatosProyecto>(json, Opciones);

    /// <summary>Copia título, resumen, año, tipo, carrera, temática y asignatura.</summary>
    public void AplicarEscalares(TblProyecto proyecto)
    {
        proyecto.Titulo = Titulo;
        proyecto.Resumen = Resumen;
        proyecto.Anio = Anio;
        proyecto.IdTipoProyecto = IdTipoProyecto;
        proyecto.IdCarrera = IdCarrera;
        proyecto.IdTematica = IdTematica;
        proyecto.IdMateria = IdMateria;
    }

    /// <summary>
    /// Copia los datos al proyecto. Con <paramref name="reemplazar"/> se quitan
    /// antes sus autores y palabras clave; los asesores que se mantienen
    /// conservan el permiso ya registrado (RF-16). Devuelve los autores que
    /// dejaron de figurar, para limpiarlos después de guardar.
    /// El proyecto debe tener ya su id (estar guardado).
    /// </summary>
    public async Task<List<int>> AplicarAsync(
        RepositorioDbContext db,
        TblProyecto proyecto,
        bool reemplazar,
        CancellationToken cancellationToken)
    {
        AplicarEscalares(proyecto);

        var autoresAnteriores = new List<int>();
        if (reemplazar)
        {
            autoresAnteriores = await db.TblProyectoAutors
                .Where(item => item.IdProyecto == proyecto.IdProyecto)
                .Select(item => item.IdAutor)
                .ToListAsync(cancellationToken);
            await db.TblProyectoAutors
                .Where(item => item.IdProyecto == proyecto.IdProyecto)
                .ExecuteDeleteAsync(cancellationToken);
            await db.Entry(proyecto).Collection(item => item.IdEtiqueta).LoadAsync(cancellationToken);
            proyecto.IdEtiqueta.Clear();
        }

        for (var indice = 0; indice < Autores.Count; indice++)
        {
            var datos = Autores[indice];
            var carnet = string.IsNullOrWhiteSpace(datos.Carnet) ? null : datos.Carnet.Trim().ToUpperInvariant();
            var autor = carnet is null
                ? null
                : await db.TblAutors.FirstOrDefaultAsync(item => item.Carnet == carnet, cancellationToken);

            if (autor is null)
            {
                autor = new TblAutor
                {
                    Nombres = datos.Nombres.Trim(),
                    Apellidos = datos.Apellidos.Trim(),
                    Carnet = carnet
                };
                db.TblAutors.Add(autor);
                await db.SaveChangesAsync(cancellationToken);
            }

            db.TblProyectoAutors.Add(new TblProyectoAutor
            {
                IdProyecto = proyecto.IdProyecto,
                IdAutor = autor.IdAutor,
                OrdenAutoria = indice + 1
            });
        }

        foreach (var palabra in PalabrasClave)
        {
            var etiqueta = await db.TblEtiquetas.FirstOrDefaultAsync(item => item.Nombre == palabra, cancellationToken)
                           ?? db.TblEtiquetas.Local.FirstOrDefault(item => item.Nombre == palabra);
            if (etiqueta is null)
            {
                etiqueta = new TblEtiqueta { Nombre = palabra };
                db.TblEtiquetas.Add(etiqueta);
            }

            proyecto.IdEtiqueta.Add(etiqueta);
        }

        var asesoresActuales = reemplazar
            ? await db.TblProyectoDocentes.Where(item => item.IdProyecto == proyecto.IdProyecto).ToListAsync(cancellationToken)
            : [];
        db.TblProyectoDocentes.RemoveRange(asesoresActuales.Where(item => !IdDocentesAsesores.Contains(item.IdDocente)));
        foreach (var idDocente in IdDocentesAsesores.Where(id => asesoresActuales.All(item => item.IdDocente != id)))
        {
            db.TblProyectoDocentes.Add(new TblProyectoDocente
            {
                IdProyecto = proyecto.IdProyecto,
                IdDocente = idDocente,
                NombreAutorizado = false
            });
        }

        return autoresAnteriores;
    }

    /// <summary>Borra los autores sin cuenta que ya no figuran en ningún proyecto.</summary>
    public static Task LimpiarAutoresAsync(RepositorioDbContext db, List<int> idsAutores, CancellationToken cancellationToken) =>
        idsAutores.Count == 0
            ? Task.CompletedTask
            : db.TblAutors
                .Where(autor => idsAutores.Contains(autor.IdAutor) &&
                                autor.IdUsuario == null &&
                                !autor.TblProyectoAutors.Any())
                .ExecuteDeleteAsync(cancellationToken);

    /// <summary>
    /// Los datos propuestos listos para mostrar (nombres en lugar de ids), para
    /// que el supervisor y el solicitante vean la versión que se revisa.
    /// </summary>
    public async Task<VistaDatosProyecto> DescribirAsync(RepositorioDbContext db, CancellationToken cancellationToken)
    {
        var tipo = await db.TblTipoProyectos.AsNoTracking()
            .Where(item => item.IdTipoProyecto == IdTipoProyecto).Select(item => item.Nombre).FirstOrDefaultAsync(cancellationToken);
        var carrera = await db.TblCarreras.AsNoTracking()
            .Where(item => item.IdCarrera == IdCarrera)
            .Select(item => new { item.Nombre, item.IdDepartamento, Departamento = item.IdDepartamentoNavigation.Nombre })
            .FirstOrDefaultAsync(cancellationToken);
        var tematica = await db.TblTematicas.AsNoTracking()
            .Where(item => item.IdTematica == IdTematica).Select(item => item.Nombre).FirstOrDefaultAsync(cancellationToken);
        var materia = IdMateria is null ? null : await db.TblMateria.AsNoTracking()
            .Where(item => item.IdMateria == IdMateria).Select(item => item.Nombre).FirstOrDefaultAsync(cancellationToken);
        var asesores = await db.TblDocentes.AsNoTracking()
            .Where(item => IdDocentesAsesores.Contains(item.IdDocente))
            .Select(item => new AsesorPropuesto(item.IdDocente, item.IdUsuarioNavigation.Nombres + " " + item.IdUsuarioNavigation.Apellidos))
            .ToListAsync(cancellationToken);

        return new VistaDatosProyecto(
            tipo ?? string.Empty,
            carrera?.Nombre ?? string.Empty,
            carrera?.IdDepartamento ?? 0,
            carrera?.Departamento ?? string.Empty,
            tematica ?? string.Empty,
            materia,
            asesores.OrderBy(item => item.Nombre).ToList());
    }
}

public sealed record AsesorPropuesto(int IdDocente, string Nombre);

public sealed record VistaDatosProyecto(
    string TipoTrabajo,
    string Carrera,
    int IdDepartamento,
    string Departamento,
    string Tematica,
    string? Materia,
    List<AsesorPropuesto> Asesores);
