using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblTipoProyecto
{
    public int IdTipoProyecto { get; set; }

    public string Nombre { get; set; } = null!;

    public string? Descripcion { get; set; }

    public virtual ICollection<TblProyecto> TblProyectos { get; set; } = new List<TblProyecto>();
}
