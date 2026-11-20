using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblDepartamento
{
    public int IdDepartamento { get; set; }

    public string Nombre { get; set; } = null!;

    public string? Descripcion { get; set; }

    public virtual ICollection<TblCarrera> TblCarreras { get; set; } = new List<TblCarrera>();
}
