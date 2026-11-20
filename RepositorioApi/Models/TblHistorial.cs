using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblHistorial
{
    public int IdHistorial { get; set; }

    public int IdUsuario { get; set; }

    public int IdProyecto { get; set; }

    public string Accion { get; set; } = null!;

    public DateTime FechaAccion { get; set; }

    public string? Detalle { get; set; }

    public virtual TblProyecto IdProyectoNavigation { get; set; } = null!;

    public virtual TblUsuario IdUsuarioNavigation { get; set; } = null!;
}
