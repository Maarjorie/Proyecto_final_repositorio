using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;

namespace RepositorioApi.Controllers;

[ApiController]
[Route("api/catalogos")]
public class CatalogosController : ControllerBase
{
    private readonly RepositorioDbContext _db;

    public CatalogosController(RepositorioDbContext db)
    {
        _db = db;
    }

    [HttpGet("tipos-proyecto")]
    public async Task<IActionResult> GetTiposProyecto()
    {
        var tipos = await _db.TblTipoProyectos
            .AsNoTracking()
            .OrderBy(tipo => tipo.Nombre)
            .Select(tipo => new
            {
                id = tipo.IdTipoProyecto,
                nombre = tipo.Nombre,
                descripcion = tipo.Descripcion
            })
            .ToListAsync();

        return Ok(tipos);
    }

    [HttpGet("departamentos")]
    public async Task<IActionResult> GetDepartamentos()
    {
        var departamentos = await _db.TblDepartamentos
            .AsNoTracking()
            .OrderBy(departamento => departamento.Nombre)
            .Select(departamento => new
            {
                id = departamento.IdDepartamento,
                nombre = departamento.Nombre,
                descripcion = departamento.Descripcion
            })
            .ToListAsync();

        return Ok(departamentos);
    }

    [HttpGet("carreras")]
    public async Task<IActionResult> GetCarreras([FromQuery] int? departamentoId)
    {
        var consulta = _db.TblCarreras.AsNoTracking();

        if (departamentoId.HasValue)
        {
            consulta = consulta.Where(carrera =>
                carrera.IdDepartamento == departamentoId.Value);
        }

        var carreras = await consulta
            .OrderBy(carrera => carrera.Nombre)
            .Select(carrera => new
            {
                id = carrera.IdCarrera,
                codigo = carrera.Codigo,
                nombre = carrera.Nombre,
                departamentoId = carrera.IdDepartamento
            })
            .ToListAsync();

        return Ok(carreras);
    }

    [HttpGet("tematicas")]
    public async Task<IActionResult> GetTematicas()
    {
        var tematicas = await _db.TblTematicas
            .AsNoTracking()
            .OrderBy(tematica => tematica.Nombre)
            .Select(tematica => new
            {
                id = tematica.IdTematica,
                nombre = tematica.Nombre,
                descripcion = tematica.Descripcion
            })
            .ToListAsync();

        return Ok(tematicas);
    }

    [HttpGet("tipos-recurso")]
    public async Task<IActionResult> GetTiposRecurso()
    {
        var tipos = await _db.TblTipoRecursos
            .AsNoTracking()
            .OrderBy(tipo => tipo.Nombre)
            .Select(tipo => new
            {
                id = tipo.IdTipoRecurso,
                nombre = tipo.Nombre,
                descripcion = tipo.Descripcion
            })
            .ToListAsync();

        return Ok(tipos);
    }

    [HttpGet("docentes")]
    public async Task<IActionResult> GetDocentes()
    {
        var docentes = await _db.TblDocentes
            .AsNoTracking()
            .Where(docente => docente.IdUsuarioNavigation.Activo)
            .OrderBy(docente => docente.IdUsuarioNavigation.Apellidos)
            .ThenBy(docente => docente.IdUsuarioNavigation.Nombres)
            .Select(docente => new
            {
                id = docente.IdDocente,
                codigo = docente.CodigoDocente,
                nombres = docente.IdUsuarioNavigation.Nombres,
                apellidos = docente.IdUsuarioNavigation.Apellidos
            })
            .ToListAsync();

        return Ok(docentes);
    }


}
