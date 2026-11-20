using System;
using System.Collections.Generic;

namespace RepositorioApi.Models;

public partial class TblAutor
{
    public int IdAutor { get; set; }

    public string Nombres { get; set; } = null!;

    public string Apellidos { get; set; } = null!;

    public string? Carnet { get; set; }

    public int? IdUsuario { get; set; }

    public virtual TblUsuario? IdUsuarioNavigation { get; set; }

    public virtual ICollection<TblProyectoAutor> TblProyectoAutors { get; set; } = new List<TblProyectoAutor>();
}
