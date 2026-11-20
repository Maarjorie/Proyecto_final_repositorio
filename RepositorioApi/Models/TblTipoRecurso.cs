using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblTipoRecurso
{
    public int IdTipoRecurso { get; set; }

    public string Nombre { get; set; } = null!;

    public string? Descripcion { get; set; }

    public virtual ICollection<TblRecurso> TblRecursos { get; set; } = new List<TblRecurso>();
}
