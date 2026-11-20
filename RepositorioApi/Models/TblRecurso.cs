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

    /// <summary>Material autorizado por los autores para el catálogo (RF-10).</summary>
    public bool DifusionAutorizada { get; set; }

    public virtual TblEntrega IdEntregaNavigation { get; set; } = null!;

    public virtual TblTipoRecurso IdTipoRecursoNavigation { get; set; } = null!;
}
