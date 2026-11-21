using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblCarrera
{
    public int IdCarrera { get; set; }

    public string Codigo { get; set; } = null!;

    public string Nombre { get; set; } = null!;

    public int IdDepartamento { get; set; }

    public virtual TblDepartamento IdDepartamentoNavigation { get; set; } = null!;

    public virtual ICollection<TblProyecto> TblProyectos { get; set; } = new List<TblProyecto>();

    /// <summary>Plan de estudios de la carrera.</summary>
    public virtual ICollection<TblCarreraMaterium> TblCarreraMateria { get; set; } = new List<TblCarreraMaterium>();
}
