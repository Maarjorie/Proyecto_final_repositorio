using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblDocente
{
    public int IdDocente { get; set; }

    public int IdUsuario { get; set; }

    public string CodigoDocente { get; set; } = null!;

    public int IdDepartamento { get; set; }

    public virtual TblDepartamento IdDepartamentoNavigation { get; set; } = null!;

    public virtual TblUsuario IdUsuarioNavigation { get; set; } = null!;

    /// <summary>Materias que imparte (tbl_materia_docente).</summary>
    public virtual ICollection<TblMaterium> IdMateria { get; set; } = new List<TblMaterium>();

    public virtual ICollection<TblProyecto> IdProyectos { get; set; } = new List<TblProyecto>();

    public virtual ICollection<TblProyectoDocente> TblProyectoDocentes { get; set; } = new List<TblProyectoDocente>();
}
