using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblMaterium
{
    public int IdMateria { get; set; }

    public string Codigo { get; set; } = null!;

    public string Nombre { get; set; } = null!;

    public int IdDocente { get; set; }

    public string? Descripcion { get; set; }

    public virtual TblDocente IdDocenteNavigation { get; set; } = null!;

    public virtual ICollection<TblProyecto> TblProyectos { get; set; } = new List<TblProyecto>();
}
