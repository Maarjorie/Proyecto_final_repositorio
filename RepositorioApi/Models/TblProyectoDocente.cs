namespace RepositorioApi.Models;

/// <summary>Docente asesor de un proyecto.</summary>
public partial class TblProyectoDocente
{
    public int IdProyecto { get; set; }

    public int IdDocente { get; set; }

    /// <summary>Se autorizó mostrar su nombre en el catálogo.</summary>
    public bool NombreAutorizado { get; set; }

    public virtual TblProyecto IdProyectoNavigation { get; set; } = null!;

    public virtual TblDocente IdDocenteNavigation { get; set; } = null!;
}
