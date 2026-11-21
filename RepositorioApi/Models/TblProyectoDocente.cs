namespace RepositorioApi.Models;

/// <summary>
/// Docente asesor de un proyecto (tbl_proyecto_docente). RF-16: su nombre
/// solo se muestra en la ficha pública si se autorizó.
/// </summary>
public partial class TblProyectoDocente
{
    public int IdProyecto { get; set; }

    public int IdDocente { get; set; }

    /// <summary>Se autorizó mostrar el nombre del asesor en el catálogo (RF-16).</summary>
    public bool NombreAutorizado { get; set; }

    public virtual TblProyecto IdProyectoNavigation { get; set; } = null!;

    public virtual TblDocente IdDocenteNavigation { get; set; } = null!;
}
