namespace RepositorioApi.Models;

/// <summary>
/// Plan de estudios: una materia dentro de una carrera, con el ciclo en que se
/// cursa. Una misma materia puede estar en varias carreras.
/// </summary>
public partial class TblCarreraMaterium
{
    public int IdCarrera { get; set; }

    public int IdMateria { get; set; }

    public short Ciclo { get; set; }

    public virtual TblCarrera IdCarreraNavigation { get; set; } = null!;

    public virtual TblMaterium IdMateriaNavigation { get; set; } = null!;
}
