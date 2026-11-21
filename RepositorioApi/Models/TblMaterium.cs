using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblMaterium
{
    public int IdMateria { get; set; }

    public string Codigo { get; set; } = null!;

    public string Nombre { get; set; } = null!;

    public string? Descripcion { get; set; }

    /// <summary>Docentes que imparten la materia (tbl_materia_docente).</summary>
    public virtual ICollection<TblDocente> IdDocentes { get; set; } = new List<TblDocente>();

    /// <summary>Carreras cuyo plan incluye la materia, con su ciclo.</summary>
    public virtual ICollection<TblCarreraMaterium> TblCarreraMateria { get; set; } = new List<TblCarreraMaterium>();

    public virtual ICollection<TblProyecto> TblProyectos { get; set; } = new List<TblProyecto>();
}
