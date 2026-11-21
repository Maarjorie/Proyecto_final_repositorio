using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Data;
using RepositorioApi.Models;

namespace RepositorioApi.Controllers;

/// <summary>
/// Panel del administrador: gestiona cuentas, roles y catálogos académicos
/// (RNF-03: "el administrador gestiona cuentas y roles"). Los cambios de
/// permisos y las eliminaciones exigen la contraseña del administrador.
/// </summary>
[ApiController]
[Authorize(Roles = "administrador")]
[Route("api/admin")]
public sealed class AdminController : ControllerBase
{
    private static readonly string[] RolesValidos = ["usuario", "supervisor", "administrador"];

    private readonly RepositorioDbContext _db;
    private readonly PasswordHasher<TblUsuario> _passwordHasher = new();

    public AdminController(RepositorioDbContext db)
    {
        _db = db;
    }

    // ------------------------------------------------------------------
    // Cuentas y roles
    // ------------------------------------------------------------------

    [HttpGet("usuarios")]
    public async Task<IActionResult> ObtenerUsuarios(CancellationToken cancellationToken)
    {
        var usuarios = await _db.TblUsuarios
            .AsNoTracking()
            .OrderBy(usuario => usuario.Apellidos)
            .ThenBy(usuario => usuario.Nombres)
            .Select(usuario => new
            {
                id = usuario.IdUsuario,
                correo = usuario.Correo,
                nombres = usuario.Nombres,
                apellidos = usuario.Apellidos,
                activo = usuario.Activo,
                fechaRegistro = usuario.FechaRegistro,
                roles = usuario.IdRols.Select(rol => rol.NombreRol).ToList(),
                codigoDocente = usuario.TblDocente == null ? null : usuario.TblDocente.CodigoDocente
            })
            .ToListAsync(cancellationToken);

        return Ok(usuarios);
    }

    /// <summary>Asigna o quita un rol. Pide la contraseña del administrador.</summary>
    [HttpPut("usuarios/{idUsuario:int}/roles")]
    public async Task<IActionResult> CambiarRol(
        int idUsuario,
        [FromBody] CambioRolRequest request,
        CancellationToken cancellationToken)
    {
        var rolNombre = request.Rol.Trim().ToLowerInvariant();
        if (!RolesValidos.Contains(rolNombre))
        {
            return BadRequest(new { mensaje = "El rol debe ser usuario, supervisor o administrador." });
        }

        var (admin, error) = await VerificarAdministradorAsync(request.Contrasena, cancellationToken);
        if (error is not null)
        {
            return error;
        }

        var usuario = await _db.TblUsuarios
            .Include(item => item.IdRols)
            .FirstOrDefaultAsync(item => item.IdUsuario == idUsuario, cancellationToken);
        if (usuario is null)
        {
            return NotFound(new { mensaje = "No se encontró la cuenta." });
        }

        // Evita que el administrador se quede sin acceso al panel.
        if (rolNombre == "administrador" && !request.Asignar && usuario.IdUsuario == admin!.IdUsuario)
        {
            return Conflict(new { mensaje = "No puedes quitarte tu propio rol de administrador." });
        }

        var rol = await _db.TblRols.FirstAsync(item => item.NombreRol == rolNombre, cancellationToken);
        var loTiene = usuario.IdRols.Any(item => item.IdRol == rol.IdRol);

        if (request.Asignar && !loTiene)
        {
            usuario.IdRols.Add(rol);
        }
        else if (!request.Asignar && loTiene)
        {
            usuario.IdRols.Remove(rol);
        }

        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new
        {
            roles = usuario.IdRols.Select(item => item.NombreRol).ToList(),
            mensaje = (request.Asignar ? "Se asignó" : "Se quitó") + " el rol " + rolNombre +
                      (request.Asignar ? " a " : " de ") + usuario.Correo +
                      ". El cambio aplica cuando vuelva a iniciar sesión."
        });
    }

    /// <summary>Habilita o deshabilita una cuenta. Una cuenta inactiva no puede iniciar sesión.</summary>
    [HttpPut("usuarios/{idUsuario:int}/activo")]
    public async Task<IActionResult> CambiarActivo(
        int idUsuario,
        [FromBody] CambioActivoRequest request,
        CancellationToken cancellationToken)
    {
        var (admin, error) = await VerificarAdministradorAsync(request.Contrasena, cancellationToken);
        if (error is not null)
        {
            return error;
        }

        if (idUsuario == admin!.IdUsuario && !request.Activo)
        {
            return Conflict(new { mensaje = "No puedes deshabilitar tu propia cuenta." });
        }

        var usuario = await _db.TblUsuarios
            .FirstOrDefaultAsync(item => item.IdUsuario == idUsuario, cancellationToken);
        if (usuario is null)
        {
            return NotFound(new { mensaje = "No se encontró la cuenta." });
        }

        usuario.Activo = request.Activo;
        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new
        {
            activo = usuario.Activo,
            mensaje = "La cuenta " + usuario.Correo + (usuario.Activo ? " se habilitó." : " se deshabilitó.")
        });
    }

    /// <summary>
    /// Registra una cuenta como docente, requisito para asignarle materias.
    /// Cada docente pertenece a un departamento académico.
    /// </summary>
    [HttpPost("docentes")]
    public async Task<IActionResult> RegistrarDocente(
        [FromBody] DocenteRequest request,
        CancellationToken cancellationToken)
    {
        var codigo = request.Codigo.Trim().ToUpperInvariant();
        if (codigo.Length == 0 || codigo.Length > 20)
        {
            return BadRequest(new { mensaje = "El código docente es obligatorio (máximo 20 caracteres)." });
        }

        if (request.IdDepartamento is null ||
            !await _db.TblDepartamentos.AnyAsync(item => item.IdDepartamento == request.IdDepartamento, cancellationToken))
        {
            return BadRequest(new { mensaje = "Selecciona el departamento del docente." });
        }

        var usuario = await _db.TblUsuarios
            .Include(item => item.TblDocente)
            .FirstOrDefaultAsync(item => item.IdUsuario == request.IdUsuario, cancellationToken);
        if (usuario is null)
        {
            return NotFound(new { mensaje = "No se encontró la cuenta." });
        }

        if (usuario.TblDocente is not null)
        {
            return Conflict(new { mensaje = "Esa cuenta ya está registrada como docente." });
        }

        if (await _db.TblDocentes.AnyAsync(item => item.CodigoDocente == codigo, cancellationToken))
        {
            return Conflict(new { mensaje = "Ya existe un docente con ese código." });
        }

        _db.TblDocentes.Add(new TblDocente
        {
            IdUsuario = usuario.IdUsuario,
            CodigoDocente = codigo,
            IdDepartamento = request.IdDepartamento.Value
        });
        await _db.SaveChangesAsync(cancellationToken);

        return Ok(new { mensaje = usuario.Nombres + " " + usuario.Apellidos + " quedó registrado como docente (" + codigo + ")." });
    }

    // ------------------------------------------------------------------
    // Catálogos académicos
    // ------------------------------------------------------------------

    [HttpGet("catalogos/{tipo}")]
    public async Task<IActionResult> ObtenerCatalogo(string tipo, CancellationToken cancellationToken)
    {
        object? datos = tipo switch
        {
            "departamentos" => await _db.TblDepartamentos.AsNoTracking()
                .OrderBy(item => item.Nombre)
                .Select(item => new { id = item.IdDepartamento, nombre = item.Nombre, descripcion = item.Descripcion })
                .ToListAsync(cancellationToken),
            "carreras" => await _db.TblCarreras.AsNoTracking()
                .OrderBy(item => item.Nombre)
                .Select(item => new
                {
                    id = item.IdCarrera,
                    codigo = item.Codigo,
                    nombre = item.Nombre,
                    idDepartamento = item.IdDepartamento,
                    departamento = item.IdDepartamentoNavigation.Nombre
                })
                .ToListAsync(cancellationToken),
            "tematicas" => await _db.TblTematicas.AsNoTracking()
                .OrderBy(item => item.Nombre)
                .Select(item => new { id = item.IdTematica, nombre = item.Nombre, descripcion = item.Descripcion })
                .ToListAsync(cancellationToken),
            "materias" => (await _db.TblMateria.AsNoTracking()
                .OrderBy(item => item.Nombre)
                .Select(item => new
                {
                    item.IdMateria,
                    item.Codigo,
                    item.Nombre,
                    item.Descripcion,
                    Carreras = item.TblCarreraMateria
                        .OrderBy(plan => plan.IdCarreraNavigation.Nombre)
                        .Select(plan => new { plan.IdCarrera, plan.IdCarreraNavigation.Nombre, plan.Ciclo })
                        .ToList(),
                    Docentes = item.IdDocentes
                        .OrderBy(docente => docente.IdUsuarioNavigation.Apellidos)
                        .Select(docente => new
                        {
                            docente.IdDocente,
                            Nombre = docente.IdUsuarioNavigation.Nombres + " " + docente.IdUsuarioNavigation.Apellidos
                        })
                        .ToList()
                })
                .ToListAsync(cancellationToken))
                .Select(item => new
                {
                    id = item.IdMateria,
                    codigo = item.Codigo,
                    nombre = item.Nombre,
                    // Texto para la tabla y detalle para editar los vínculos.
                    carreras = string.Join("; ", item.Carreras.Select(plan => plan.Nombre + " (ciclo " + plan.Ciclo + ")")),
                    docentes = string.Join("; ", item.Docentes.Select(docente => docente.Nombre)),
                    descripcion = item.Descripcion,
                    plan = item.Carreras.Select(plan => new { idCarrera = plan.IdCarrera, carrera = plan.Nombre, ciclo = plan.Ciclo }),
                    imparten = item.Docentes.Select(docente => new { idDocente = docente.IdDocente, nombre = docente.Nombre })
                })
                .ToList(),
            "docentes" => await _db.TblDocentes.AsNoTracking()
                .OrderBy(item => item.IdUsuarioNavigation.Apellidos)
                .Select(item => new
                {
                    id = item.IdDocente,
                    codigo = item.CodigoDocente,
                    nombre = item.IdUsuarioNavigation.Nombres + " " + item.IdUsuarioNavigation.Apellidos,
                    idDepartamento = item.IdDepartamento,
                    departamento = item.IdDepartamentoNavigation.Nombre
                })
                .ToListAsync(cancellationToken),
            _ => null
        };

        return datos is null
            ? NotFound(new { mensaje = "Catálogo no reconocido." })
            : Ok(datos);
    }

    [HttpPost("catalogos/{tipo}")]
    public async Task<IActionResult> AgregarAlCatalogo(
        string tipo,
        [FromBody] CatalogoRequest request,
        CancellationToken cancellationToken)
    {
        var nombre = request.Nombre?.Trim() ?? string.Empty;
        var codigo = request.Codigo?.Trim().ToUpperInvariant() ?? string.Empty;
        var descripcion = string.IsNullOrWhiteSpace(request.Descripcion) ? null : request.Descripcion.Trim();

        if (nombre.Length == 0)
        {
            return BadRequest(new { mensaje = "El nombre es obligatorio." });
        }

        switch (tipo)
        {
            case "departamentos":
                if (nombre.Length > 150)
                {
                    return BadRequest(new { mensaje = "El nombre admite hasta 150 caracteres." });
                }
                if (await _db.TblDepartamentos.AnyAsync(item => item.Nombre.ToLower() == nombre.ToLower(), cancellationToken))
                {
                    return Conflict(new { mensaje = "Ya existe un departamento con ese nombre." });
                }
                _db.TblDepartamentos.Add(new TblDepartamento { Nombre = nombre, Descripcion = descripcion });
                break;

            case "carreras":
                if (codigo.Length == 0 || codigo.Length > 20 || nombre.Length > 150)
                {
                    return BadRequest(new { mensaje = "El código (máx. 20) y el nombre (máx. 150) son obligatorios." });
                }
                if (request.IdDepartamento is null ||
                    !await _db.TblDepartamentos.AnyAsync(item => item.IdDepartamento == request.IdDepartamento, cancellationToken))
                {
                    return BadRequest(new { mensaje = "Selecciona un departamento válido." });
                }
                if (await _db.TblCarreras.AnyAsync(item => item.Codigo == codigo, cancellationToken))
                {
                    return Conflict(new { mensaje = "Ya existe una carrera con ese código." });
                }
                _db.TblCarreras.Add(new TblCarrera
                {
                    Codigo = codigo,
                    Nombre = nombre,
                    IdDepartamento = request.IdDepartamento.Value
                });
                break;

            case "tematicas":
                // tbl_tematica exige el nombre en minúsculas (ck_tematica_nombre).
                nombre = nombre.ToLowerInvariant();
                if (nombre.Length > 100)
                {
                    return BadRequest(new { mensaje = "El nombre admite hasta 100 caracteres." });
                }
                if (await _db.TblTematicas.AnyAsync(item => item.Nombre == nombre, cancellationToken))
                {
                    return Conflict(new { mensaje = "Ya existe una temática con ese nombre." });
                }
                _db.TblTematicas.Add(new TblTematica { Nombre = nombre, Descripcion = descripcion });
                break;

            case "materias":
                if (codigo.Length == 0 || codigo.Length > 20 || nombre.Length > 150)
                {
                    return BadRequest(new { mensaje = "El código (máx. 20) y el nombre (máx. 150) son obligatorios." });
                }
                if (request.IdCarrera is null ||
                    !await _db.TblCarreras.AnyAsync(item => item.IdCarrera == request.IdCarrera, cancellationToken))
                {
                    return BadRequest(new { mensaje = "Selecciona la carrera a la que pertenece la materia." });
                }
                if (request.Ciclo is null or < 1 or > 12)
                {
                    return BadRequest(new { mensaje = "Indica el ciclo de la materia en esa carrera (1 a 12)." });
                }
                var docente = request.IdDocente is null
                    ? null
                    : await _db.TblDocentes.FirstOrDefaultAsync(item => item.IdDocente == request.IdDocente, cancellationToken);
                if (docente is null)
                {
                    return BadRequest(new { mensaje = "Selecciona el docente que imparte la materia." });
                }
                if (await _db.TblMateria.AnyAsync(item => item.Codigo == codigo, cancellationToken))
                {
                    return Conflict(new { mensaje = "Ya existe una materia con ese código. Para usarla en otra carrera, agrégala desde «Carreras y docentes»." });
                }
                var materia = new TblMaterium
                {
                    Codigo = codigo,
                    Nombre = nombre,
                    Descripcion = descripcion
                };
                materia.TblCarreraMateria.Add(new TblCarreraMaterium
                {
                    IdCarrera = request.IdCarrera.Value,
                    Ciclo = (short)request.Ciclo.Value
                });
                materia.IdDocentes.Add(docente);
                _db.TblMateria.Add(materia);
                break;

            default:
                return NotFound(new { mensaje = "Catálogo no reconocido." });
        }

        await _db.SaveChangesAsync(cancellationToken);
        return Ok(new { mensaje = "Registro agregado." });
    }

    /// <summary>
    /// Elimina un registro de catálogo si nada lo usa. Pide la contraseña del
    /// administrador. Las llaves foráneas son RESTRICT, así que se revisa antes.
    /// </summary>
    [HttpPost("catalogos/{tipo}/{id:int}/eliminar")]
    public async Task<IActionResult> EliminarDelCatalogo(
        string tipo,
        int id,
        [FromBody] ConfirmacionRequest request,
        CancellationToken cancellationToken)
    {
        var (_, error) = await VerificarAdministradorAsync(request.Contrasena, cancellationToken);
        if (error is not null)
        {
            return error;
        }

        string? enUso = tipo switch
        {
            "departamentos" => await _db.TblCarreras.AnyAsync(item => item.IdDepartamento == id, cancellationToken)
                ? "Tiene carreras asignadas; elimínalas o cámbialas primero."
                : await _db.TblDocentes.AnyAsync(item => item.IdDepartamento == id, cancellationToken)
                    ? "Tiene docentes adscritos." : null,
            "carreras" => await _db.TblProyectos.AnyAsync(item => item.IdCarrera == id, cancellationToken)
                ? "Hay proyectos registrados en esta carrera."
                : await _db.TblCarreraMateria.AnyAsync(item => item.IdCarrera == id, cancellationToken)
                    ? "Tiene materias en su plan de estudios; quítalas primero." : null,
            "tematicas" => await _db.TblProyectos.AnyAsync(item => item.IdTematica == id, cancellationToken)
                ? "Hay proyectos clasificados con esta temática." : null,
            "materias" => await _db.TblProyectos.AnyAsync(item => item.IdMateria == id, cancellationToken)
                ? "Hay proyectos de curso de esta materia." : null,
            _ => null
        };

        if (enUso is not null)
        {
            return Conflict(new { mensaje = "No se puede eliminar: " + enUso });
        }

        var eliminados = tipo switch
        {
            "departamentos" => await _db.TblDepartamentos.Where(item => item.IdDepartamento == id).ExecuteDeleteAsync(cancellationToken),
            "carreras" => await _db.TblCarreras.Where(item => item.IdCarrera == id).ExecuteDeleteAsync(cancellationToken),
            "tematicas" => await _db.TblTematicas.Where(item => item.IdTematica == id).ExecuteDeleteAsync(cancellationToken),
            "materias" => await EliminarMateriaAsync(id, cancellationToken),
            _ => -1
        };

        return eliminados switch
        {
            -1 => NotFound(new { mensaje = "Catálogo no reconocido." }),
            0 => NotFound(new { mensaje = "No se encontró el registro." }),
            _ => Ok(new { mensaje = "Registro eliminado." })
        };
    }

    /// <summary>Quita los vínculos de la materia (plan y docentes) y luego la materia.</summary>
    private async Task<int> EliminarMateriaAsync(int id, CancellationToken cancellationToken)
    {
        await using var transaccion = await _db.Database.BeginTransactionAsync(cancellationToken);
        await _db.TblCarreraMateria.Where(item => item.IdMateria == id).ExecuteDeleteAsync(cancellationToken);
        await _db.Database.ExecuteSqlInterpolatedAsync(
            $"DELETE FROM tbl_materia_docente WHERE id_materia = {id}", cancellationToken);
        var eliminadas = await _db.TblMateria.Where(item => item.IdMateria == id).ExecuteDeleteAsync(cancellationToken);
        await transaccion.CommitAsync(cancellationToken);
        return eliminadas;
    }

    /// <summary>Agrega la materia al plan de otra carrera, en un ciclo.</summary>
    [HttpPost("materias/{idMateria:int}/carreras")]
    public async Task<IActionResult> AgregarCarreraAMateria(
        int idMateria,
        [FromBody] PlanRequest request,
        CancellationToken cancellationToken)
    {
        if (request.Ciclo is < 1 or > 12)
        {
            return BadRequest(new { mensaje = "El ciclo debe estar entre 1 y 12." });
        }
        if (!await _db.TblMateria.AnyAsync(item => item.IdMateria == idMateria, cancellationToken) ||
            !await _db.TblCarreras.AnyAsync(item => item.IdCarrera == request.IdCarrera, cancellationToken))
        {
            return NotFound(new { mensaje = "No se encontró la materia o la carrera." });
        }
        if (await _db.TblCarreraMateria.AnyAsync(
                item => item.IdMateria == idMateria && item.IdCarrera == request.IdCarrera, cancellationToken))
        {
            return Conflict(new { mensaje = "La materia ya está en el plan de esa carrera." });
        }

        _db.TblCarreraMateria.Add(new TblCarreraMaterium
        {
            IdMateria = idMateria,
            IdCarrera = request.IdCarrera,
            Ciclo = (short)request.Ciclo
        });
        await _db.SaveChangesAsync(cancellationToken);
        return Ok(new { mensaje = "Materia agregada al plan de la carrera." });
    }

    /// <summary>Quita la materia del plan de una carrera. Debe quedar en al menos una.</summary>
    [HttpDelete("materias/{idMateria:int}/carreras/{idCarrera:int}")]
    public async Task<IActionResult> QuitarCarreraDeMateria(int idMateria, int idCarrera, CancellationToken cancellationToken)
    {
        var plan = await _db.TblCarreraMateria
            .FirstOrDefaultAsync(item => item.IdMateria == idMateria && item.IdCarrera == idCarrera, cancellationToken);
        if (plan is null)
        {
            return NotFound(new { mensaje = "La materia no está en el plan de esa carrera." });
        }
        if (await _db.TblCarreraMateria.CountAsync(item => item.IdMateria == idMateria, cancellationToken) == 1)
        {
            return Conflict(new { mensaje = "La materia debe pertenecer al menos a una carrera." });
        }
        if (await _db.TblProyectos.AnyAsync(item => item.IdMateria == idMateria && item.IdCarrera == idCarrera, cancellationToken))
        {
            return Conflict(new { mensaje = "Hay proyectos de esa carrera registrados con esta materia." });
        }

        _db.TblCarreraMateria.Remove(plan);
        await _db.SaveChangesAsync(cancellationToken);
        return Ok(new { mensaje = "Materia quitada del plan de la carrera." });
    }

    /// <summary>Agrega otro docente que imparte la materia.</summary>
    [HttpPost("materias/{idMateria:int}/docentes")]
    public async Task<IActionResult> AgregarDocenteAMateria(
        int idMateria,
        [FromBody] MateriaDocenteRequest request,
        CancellationToken cancellationToken)
    {
        var materia = await _db.TblMateria
            .Include(item => item.IdDocentes)
            .FirstOrDefaultAsync(item => item.IdMateria == idMateria, cancellationToken);
        var docente = await _db.TblDocentes.FirstOrDefaultAsync(item => item.IdDocente == request.IdDocente, cancellationToken);
        if (materia is null || docente is null)
        {
            return NotFound(new { mensaje = "No se encontró la materia o el docente." });
        }
        if (materia.IdDocentes.Any(item => item.IdDocente == docente.IdDocente))
        {
            return Conflict(new { mensaje = "Ese docente ya imparte la materia." });
        }

        materia.IdDocentes.Add(docente);
        await _db.SaveChangesAsync(cancellationToken);
        return Ok(new { mensaje = "Docente agregado a la materia." });
    }

    /// <summary>Quita un docente de la materia. Debe quedar al menos uno.</summary>
    [HttpDelete("materias/{idMateria:int}/docentes/{idDocente:int}")]
    public async Task<IActionResult> QuitarDocenteDeMateria(int idMateria, int idDocente, CancellationToken cancellationToken)
    {
        var materia = await _db.TblMateria
            .Include(item => item.IdDocentes)
            .FirstOrDefaultAsync(item => item.IdMateria == idMateria, cancellationToken);
        var docente = materia?.IdDocentes.FirstOrDefault(item => item.IdDocente == idDocente);
        if (materia is null || docente is null)
        {
            return NotFound(new { mensaje = "Ese docente no imparte la materia." });
        }
        if (materia.IdDocentes.Count == 1)
        {
            return Conflict(new { mensaje = "La materia debe tener al menos un docente." });
        }

        materia.IdDocentes.Remove(docente);
        await _db.SaveChangesAsync(cancellationToken);
        return Ok(new { mensaje = "Docente quitado de la materia." });
    }

    /// <summary>Comprueba la contraseña de la cuenta de administrador que hace la petición.</summary>
    private async Task<(TblUsuario? Admin, IActionResult? Error)> VerificarAdministradorAsync(
        string? contrasena,
        CancellationToken cancellationToken)
    {
        if (!int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var idAdmin))
        {
            return (null, Unauthorized());
        }

        if (string.IsNullOrEmpty(contrasena))
        {
            return (null, BadRequest(new { mensaje = "Escribe tu contraseña para confirmar." }));
        }

        var admin = await _db.TblUsuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.IdUsuario == idAdmin && item.Activo, cancellationToken);

        if (admin is null ||
            _passwordHasher.VerifyHashedPassword(admin, admin.ContrasenaHash, contrasena) ==
            PasswordVerificationResult.Failed)
        {
            return (null, StatusCode(StatusCodes.Status403Forbidden, new { mensaje = "Contraseña incorrecta." }));
        }

        return (admin, null);
    }
}

public sealed class CambioRolRequest
{
    public string Rol { get; set; } = string.Empty;
    public bool Asignar { get; set; }
    public string? Contrasena { get; set; }
}

public sealed class CambioActivoRequest
{
    public bool Activo { get; set; }
    public string? Contrasena { get; set; }
}

public sealed class ConfirmacionRequest
{
    public string? Contrasena { get; set; }
}

public sealed class DocenteRequest
{
    public int IdUsuario { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public int? IdDepartamento { get; set; }
}

public sealed class PlanRequest
{
    public int IdCarrera { get; set; }
    public int Ciclo { get; set; }
}

public sealed class MateriaDocenteRequest
{
    public int IdDocente { get; set; }
}

public sealed class CatalogoRequest
{
    public string? Codigo { get; set; }
    public string? Nombre { get; set; }
    public string? Descripcion { get; set; }
    public int? IdDepartamento { get; set; }
    public int? IdDocente { get; set; }
    public int? IdCarrera { get; set; }
    public int? Ciclo { get; set; }
}
