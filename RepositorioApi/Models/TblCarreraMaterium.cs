namespace RepositorioApi.Models;

/// <summary>Materia dentro del plan de una carrera, con su ciclo.</summary>
public partial class TblCarreraMaterium
{
    public int IdCarrera { get; set; }

    public int IdMateria { get; set; }

    public short Ciclo { get; set; }

    public virtual TblCarrera IdCarreraNavigation { get; set; } = null!;

    public virtual TblMaterium IdMateriaNavigation { get; set; } = null!;
}
