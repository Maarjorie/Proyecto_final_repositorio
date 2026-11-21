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

    /// <summary>Registra una cuenta como docente, requisito para asignarle materias.</summary>
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

        _db.TblDocentes.Add(new TblDocente { IdUsuario = usuario.IdUsuario, CodigoDocente = codigo });
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
            "materias" => await _db.TblMateria.AsNoTracking()
                .OrderBy(item => item.Nombre)
                .Select(item => new
                {
                    id = item.IdMateria,
                    codigo = item.Codigo,
                    nombre = item.Nombre,
                    idDocente = item.IdDocente,
                    docente = item.IdDocenteNavigation.IdUsuarioNavigation.Nombres + " " +
                              item.IdDocenteNavigation.IdUsuarioNavigation.Apellidos,
                    descripcion = item.Descripcion
                })
                .ToListAsync(cancellationToken),
            "docentes" => await _db.TblDocentes.AsNoTracking()
                .OrderBy(item => item.IdUsuarioNavigation.Apellidos)
                .Select(item => new
                {
                    id = item.IdDocente,
                    codigo = item.CodigoDocente,
                    nombre = item.IdUsuarioNavigation.Nombres + " " + item.IdUsuarioNavigation.Apellidos
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
                if (request.IdDocente is null ||
                    !await _db.TblDocentes.AnyAsync(item => item.IdDocente == request.IdDocente, cancellationToken))
                {
                    return BadRequest(new { mensaje = "Selecciona el docente de la materia." });
                }
                if (await _db.TblMateria.AnyAsync(item => item.Codigo == codigo, cancellationToken))
                {
                    return Conflict(new { mensaje = "Ya existe una materia con ese código." });
                }
                _db.TblMateria.Add(new TblMaterium
                {
                    Codigo = codigo,
                    Nombre = nombre,
                    IdDocente = request.IdDocente.Value,
                    Descripcion = descripcion
                });
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
                ? "Tiene carreras asignadas; elimínalas o cámbialas primero." : null,
            "carreras" => await _db.TblProyectos.AnyAsync(item => item.IdCarrera == id, cancellationToken)
                ? "Hay proyectos registrados en esta carrera." : null,
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
            "materias" => await _db.TblMateria.Where(item => item.IdMateria == id).ExecuteDeleteAsync(cancellationToken),
            _ => -1
        };

        return eliminados switch
        {
            -1 => NotFound(new { mensaje = "Catálogo no reconocido." }),
            0 => NotFound(new { mensaje = "No se encontró el registro." }),
            _ => Ok(new { mensaje = "Registro eliminado." })
        };
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
}

public sealed class CatalogoRequest
{
    public string? Codigo { get; set; }
    public string? Nombre { get; set; }
    public string? Descripcion { get; set; }
    public int? IdDepartamento { get; set; }
    public int? IdDocente { get; set; }
}
