using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblRol
{
    public int IdRol { get; set; }

    public string NombreRol { get; set; } = null!;

    public string? Descripcion { get; set; }

    public virtual ICollection<TblUsuario> IdUsuarios { get; set; } = new List<TblUsuario>();
}
