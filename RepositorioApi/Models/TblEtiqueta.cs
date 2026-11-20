using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblEtiqueta
{
    public int IdEtiqueta { get; set; }

    public string Nombre { get; set; } = null!;

    public virtual ICollection<TblProyecto> IdProyectos { get; set; } = new List<TblProyecto>();
}
