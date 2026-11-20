using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblProyectoAutor
{
    public int IdProyecto { get; set; }

    public int IdAutor { get; set; }

    public int OrdenAutoria { get; set; }

    public virtual TblAutor IdAutorNavigation { get; set; } = null!;

    public virtual TblProyecto IdProyectoNavigation { get; set; } = null!;
}
