using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblRecurso
{
    public int IdRecurso { get; set; }

    public int IdEntrega { get; set; }

    public int IdTipoRecurso { get; set; }

    public string Nombre { get; set; } = null!;

    public string Ubicacion { get; set; } = null!;

    public virtual TblEntrega IdEntregaNavigation { get; set; } = null!;

    public virtual TblTipoRecurso IdTipoRecursoNavigation { get; set; } = null!;
}
