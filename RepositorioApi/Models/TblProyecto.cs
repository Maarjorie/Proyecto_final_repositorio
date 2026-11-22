using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblProyecto
{
    public int IdProyecto { get; set; }

    public string Titulo { get; set; } = null!;

    public string Resumen { get; set; } = null!;

    public int Anio { get; set; }

    public int IdTipoProyecto { get; set; }

    public int IdCarrera { get; set; }

    public int IdTematica { get; set; }

    public int? IdMateria { get; set; }

    public string EstadoPublicacion { get; set; } = null!;

    public string EstadoAutorizacion { get; set; } = null!;

    public bool EsDestacado { get; set; }

    public DateTime FechaRegistro { get; set; }

    public DateTime FechaActualizacion { get; set; }

    public virtual TblCarrera IdCarreraNavigation { get; set; } = null!;

    public virtual TblMaterium? IdMateriaNavigation { get; set; }

    public virtual TblTematica IdTematicaNavigation { get; set; } = null!;

    public virtual TblTipoProyecto IdTipoProyectoNavigation { get; set; } = null!;

    public virtual ICollection<TblEntrega> TblEntregas { get; set; } = new List<TblEntrega>();

    public virtual ICollection<TblFavorito> TblFavoritos { get; set; } = new List<TblFavorito>();

    public virtual ICollection<TblHistorial> TblHistorials { get; set; } = new List<TblHistorial>();

    public virtual ICollection<TblProyectoAutor> TblProyectoAutors { get; set; } = new List<TblProyectoAutor>();

    public virtual ICollection<TblDocente> IdDocentes { get; set; } = new List<TblDocente>();

    /// <summary>Asesores del proyecto.</summary>
    public virtual ICollection<TblProyectoDocente> TblProyectoDocentes { get; set; } = new List<TblProyectoDocente>();

    public virtual ICollection<TblEtiqueta> IdEtiqueta { get; set; } = new List<TblEtiqueta>();
}
