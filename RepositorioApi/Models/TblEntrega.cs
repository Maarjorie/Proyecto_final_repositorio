using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblEntrega
{
    public int IdEntrega { get; set; }

    public int IdProyecto { get; set; }

    public int IdUsuarioEnvia { get; set; }

    public int? IdUsuarioRevisa { get; set; }

    public DateTime FechaEnvio { get; set; }

    public string EstadoEntrega { get; set; } = null!;

    public DateTime? FechaRevision { get; set; }

    public virtual TblProyecto IdProyectoNavigation { get; set; } = null!;

    public virtual TblUsuario IdUsuarioEnviaNavigation { get; set; } = null!;

    public virtual TblUsuario? IdUsuarioRevisaNavigation { get; set; }

    public virtual ICollection<TblNotificacion> TblNotificacions { get; set; } = new List<TblNotificacion>();

    public virtual ICollection<TblRecurso> TblRecursos { get; set; } = new List<TblRecurso>();
}
