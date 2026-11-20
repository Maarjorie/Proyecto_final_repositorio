using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblDocente
{
    public int IdDocente { get; set; }

    public int IdUsuario { get; set; }

    public string CodigoDocente { get; set; } = null!;

    public virtual TblUsuario IdUsuarioNavigation { get; set; } = null!;

    public virtual ICollection<TblMaterium> TblMateria { get; set; } = new List<TblMaterium>();

    public virtual ICollection<TblProyecto> IdProyectos { get; set; } = new List<TblProyecto>();
}
