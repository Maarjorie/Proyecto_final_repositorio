using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblNotificacion
{
    public int IdNotificacion { get; set; }

    public int IdEntrega { get; set; }

    public int IdUsuarioDestino { get; set; }

    public string Mensaje { get; set; } = null!;

    public DateTime FechaEnvio { get; set; }

    public DateTime? FechaLectura { get; set; }

    public virtual TblEntrega IdEntregaNavigation { get; set; } = null!;

    public virtual TblUsuario IdUsuarioDestinoNavigation { get; set; } = null!;
}
