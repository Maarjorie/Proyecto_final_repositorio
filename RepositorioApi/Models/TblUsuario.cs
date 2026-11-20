using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblUsuario
{
    public int IdUsuario { get; set; }

    public string Nombres { get; set; } = null!;

    public string Apellidos { get; set; } = null!;

    public string Correo { get; set; } = null!;

    public string ContrasenaHash { get; set; } = null!;

    public bool Activo { get; set; }

    public DateTime FechaRegistro { get; set; }

    public virtual TblAutor? TblAutor { get; set; }

    public virtual TblDocente? TblDocente { get; set; }

    public virtual ICollection<TblEntrega> TblEntregaIdUsuarioEnviaNavigations { get; set; } = new List<TblEntrega>();

    public virtual ICollection<TblEntrega> TblEntregaIdUsuarioRevisaNavigations { get; set; } = new List<TblEntrega>();

    public virtual ICollection<TblFavorito> TblFavoritos { get; set; } = new List<TblFavorito>();

    public virtual ICollection<TblHistorial> TblHistorials { get; set; } = new List<TblHistorial>();

    public virtual ICollection<TblNotificacion> TblNotificacions { get; set; } = new List<TblNotificacion>();

    public virtual ICollection<TblRol> IdRols { get; set; } = new List<TblRol>();
}
