using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;
using RepositorioApi.Models;

namespace RepositorioApi.Data;

public partial class RepositorioDbContext : DbContext
{
    public RepositorioDbContext(DbContextOptions<RepositorioDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<TblAutor> TblAutors { get; set; }

    public virtual DbSet<TblCarrera> TblCarreras { get; set; }

    public virtual DbSet<TblDepartamento> TblDepartamentos { get; set; }

    public virtual DbSet<TblDocente> TblDocentes { get; set; }

    public virtual DbSet<TblEntrega> TblEntregas { get; set; }

    public virtual DbSet<TblEtiqueta> TblEtiquetas { get; set; }

    public virtual DbSet<TblFavorito> TblFavoritos { get; set; }

    public virtual DbSet<TblHistorial> TblHistorials { get; set; }

    public virtual DbSet<TblMaterium> TblMateria { get; set; }

    public virtual DbSet<TblCarreraMaterium> TblCarreraMateria { get; set; }

    public virtual DbSet<TblNotificacion> TblNotificacions { get; set; }

    public virtual DbSet<TblProyecto> TblProyectos { get; set; }

    public virtual DbSet<TblProyectoAutor> TblProyectoAutors { get; set; }

    public virtual DbSet<TblProyectoDocente> TblProyectoDocentes { get; set; }

    public virtual DbSet<TblRecurso> TblRecursos { get; set; }

    public virtual DbSet<TblRol> TblRols { get; set; }

    public virtual DbSet<TblTematica> TblTematicas { get; set; }

    public virtual DbSet<TblTipoProyecto> TblTipoProyectos { get; set; }

    public virtual DbSet<TblTipoRecurso> TblTipoRecursos { get; set; }

    public virtual DbSet<TblUsuario> TblUsuarios { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TblAutor>(entity =>
        {
            entity.HasKey(e => e.IdAutor).HasName("tbl_autor_pkey");

            entity.ToTable("tbl_autor");

            entity.HasIndex(e => e.Carnet, "uq_autor_carnet").IsUnique();

            entity.HasIndex(e => e.IdUsuario, "uq_autor_usuario").IsUnique();

            entity.Property(e => e.IdAutor).HasColumnName("id_autor");
            entity.Property(e => e.Apellidos)
                .HasMaxLength(100)
                .HasColumnName("apellidos");
            entity.Property(e => e.Carnet)
                .HasMaxLength(20)
                .HasColumnName("carnet");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Nombres)
                .HasMaxLength(100)
                .HasColumnName("nombres");

            entity.HasOne(d => d.IdUsuarioNavigation).WithOne(p => p.TblAutor)
                .HasForeignKey<TblAutor>(d => d.IdUsuario)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_autor_usuario");
        });

        modelBuilder.Entity<TblCarrera>(entity =>
        {
            entity.HasKey(e => e.IdCarrera).HasName("tbl_carrera_pkey");

            entity.ToTable("tbl_carrera");

            entity.HasIndex(e => e.Codigo, "uq_carrera_codigo").IsUnique();

            entity.Property(e => e.IdCarrera).HasColumnName("id_carrera");
            entity.Property(e => e.Codigo)
                .HasMaxLength(20)
                .HasColumnName("codigo");
            entity.Property(e => e.IdDepartamento).HasColumnName("id_departamento");
            entity.Property(e => e.Nombre)
                .HasMaxLength(150)
                .HasColumnName("nombre");

            entity.HasOne(d => d.IdDepartamentoNavigation).WithMany(p => p.TblCarreras)
                .HasForeignKey(d => d.IdDepartamento)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_carrera_departamento");
        });

        modelBuilder.Entity<TblDepartamento>(entity =>
        {
            entity.HasKey(e => e.IdDepartamento).HasName("tbl_departamento_pkey");

            entity.ToTable("tbl_departamento");

            entity.Property(e => e.IdDepartamento).HasColumnName("id_departamento");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.Nombre)
                .HasMaxLength(150)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<TblDocente>(entity =>
        {
            entity.HasKey(e => e.IdDocente).HasName("tbl_docente_pkey");

            entity.ToTable("tbl_docente");

            entity.HasIndex(e => e.CodigoDocente, "uq_docente_codigo").IsUnique();

            entity.HasIndex(e => e.IdUsuario, "uq_docente_usuario").IsUnique();

            entity.Property(e => e.IdDocente).HasColumnName("id_docente");
            entity.Property(e => e.CodigoDocente)
                .HasMaxLength(20)
                .HasColumnName("codigo_docente");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.IdDepartamento).HasColumnName("id_departamento");

            entity.HasOne(d => d.IdDepartamentoNavigation).WithMany(p => p.TblDocentes)
                .HasForeignKey(d => d.IdDepartamento)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_docente_departamento");

            entity.HasOne(d => d.IdUsuarioNavigation).WithOne(p => p.TblDocente)
                .HasForeignKey<TblDocente>(d => d.IdUsuario)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_docente_usuario");
        });

        modelBuilder.Entity<TblEntrega>(entity =>
        {
            entity.HasKey(e => e.IdEntrega).HasName("tbl_entrega_pkey");

            entity.ToTable("tbl_entrega");

            entity.Property(e => e.IdEntrega).HasColumnName("id_entrega");
            entity.Property(e => e.EstadoEntrega)
                .HasMaxLength(20)
                .HasDefaultValueSql("'pendiente'::character varying")
                .HasColumnName("estado_entrega");
            entity.Property(e => e.FechaEnvio)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_envio");
            entity.Property(e => e.FechaRevision)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_revision");
            entity.Property(e => e.DatosPropuestos)
                .HasColumnType("jsonb")
                .HasColumnName("datos_propuestos");
            entity.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
            entity.Property(e => e.IdUsuarioEnvia).HasColumnName("id_usuario_envia");
            entity.Property(e => e.IdUsuarioRevisa).HasColumnName("id_usuario_revisa");

            entity.HasOne(d => d.IdProyectoNavigation).WithMany(p => p.TblEntregas)
                .HasForeignKey(d => d.IdProyecto)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_entrega_proyecto");

            entity.HasOne(d => d.IdUsuarioEnviaNavigation).WithMany(p => p.TblEntregaIdUsuarioEnviaNavigations)
                .HasForeignKey(d => d.IdUsuarioEnvia)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_entrega_usuario_envia");

            entity.HasOne(d => d.IdUsuarioRevisaNavigation).WithMany(p => p.TblEntregaIdUsuarioRevisaNavigations)
                .HasForeignKey(d => d.IdUsuarioRevisa)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_entrega_usuario_revisa");
        });

        modelBuilder.Entity<TblEtiqueta>(entity =>
        {
            entity.HasKey(e => e.IdEtiqueta).HasName("tbl_etiquetas_pkey");

            entity.ToTable("tbl_etiquetas");

            entity.HasIndex(e => e.Nombre, "uq_etiqueta_nombre").IsUnique();

            entity.Property(e => e.IdEtiqueta).HasColumnName("id_etiqueta");
            entity.Property(e => e.Nombre)
                .HasMaxLength(60)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<TblFavorito>(entity =>
        {
            entity.HasKey(e => new { e.IdUsuario, e.IdProyecto }).HasName("pk_favorito");

            entity.ToTable("tbl_favorito");

            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
            entity.Property(e => e.FechaRegistro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_registro");

            entity.HasOne(d => d.IdProyectoNavigation).WithMany(p => p.TblFavoritos)
                .HasForeignKey(d => d.IdProyecto)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_favorito_proyecto");

            entity.HasOne(d => d.IdUsuarioNavigation).WithMany(p => p.TblFavoritos)
                .HasForeignKey(d => d.IdUsuario)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_favorito_usuario");
        });

        modelBuilder.Entity<TblHistorial>(entity =>
        {
            entity.HasKey(e => e.IdHistorial).HasName("tbl_historial_pkey");

            entity.ToTable("tbl_historial");

            entity.Property(e => e.IdHistorial).HasColumnName("id_historial");
            entity.Property(e => e.Accion)
                .HasMaxLength(20)
                .HasColumnName("accion");
            entity.Property(e => e.Detalle).HasColumnName("detalle");
            entity.Property(e => e.FechaAccion)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_accion");
            entity.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");

            entity.HasOne(d => d.IdProyectoNavigation).WithMany(p => p.TblHistorials)
                .HasForeignKey(d => d.IdProyecto)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_historial_proyecto");

            entity.HasOne(d => d.IdUsuarioNavigation).WithMany(p => p.TblHistorials)
                .HasForeignKey(d => d.IdUsuario)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_historial_usuario");
        });

        modelBuilder.Entity<TblMaterium>(entity =>
        {
            entity.HasKey(e => e.IdMateria).HasName("tbl_materia_pkey");

            entity.ToTable("tbl_materia");

            // La UES repite códigos entre carreras: la materia es única por código y nombre.
            entity.HasIndex(e => new { e.Codigo, e.Nombre }, "uq_materia_codigo_nombre").IsUnique();

            entity.Property(e => e.IdMateria).HasColumnName("id_materia");
            entity.Property(e => e.Codigo)
                .HasMaxLength(20)
                .HasColumnName("codigo");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.Nombre)
                .HasMaxLength(150)
                .HasColumnName("nombre");

            // Docentes que imparten la materia.
            entity.HasMany(d => d.IdDocentes).WithMany(p => p.IdMateria)
                .UsingEntity<Dictionary<string, object>>(
                    "TblMateriaDocente",
                    r => r.HasOne<TblDocente>().WithMany()
                        .HasForeignKey("IdDocente")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_materia_docente_docente"),
                    l => l.HasOne<TblMaterium>().WithMany()
                        .HasForeignKey("IdMateria")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_materia_docente_materia"),
                    j =>
                    {
                        j.HasKey("IdMateria", "IdDocente").HasName("pk_materia_docente");
                        j.ToTable("tbl_materia_docente");
                        j.IndexerProperty<int>("IdMateria").HasColumnName("id_materia");
                        j.IndexerProperty<int>("IdDocente").HasColumnName("id_docente");
                    });
        });

        // Plan de estudios: materia dentro de una carrera, con su ciclo.
        modelBuilder.Entity<TblCarreraMaterium>(entity =>
        {
            entity.HasKey(e => new { e.IdCarrera, e.IdMateria }).HasName("pk_carrera_materia");

            entity.ToTable("tbl_carrera_materia");

            entity.Property(e => e.IdCarrera).HasColumnName("id_carrera");
            entity.Property(e => e.IdMateria).HasColumnName("id_materia");
            entity.Property(e => e.Ciclo).HasColumnName("ciclo");

            entity.HasOne(d => d.IdCarreraNavigation).WithMany(p => p.TblCarreraMateria)
                .HasForeignKey(d => d.IdCarrera)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_carrera_materia_carrera");

            entity.HasOne(d => d.IdMateriaNavigation).WithMany(p => p.TblCarreraMateria)
                .HasForeignKey(d => d.IdMateria)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_carrera_materia_materia");
        });

        modelBuilder.Entity<TblNotificacion>(entity =>
        {
            entity.HasKey(e => e.IdNotificacion).HasName("tbl_notificacion_pkey");

            entity.ToTable("tbl_notificacion");

            entity.Property(e => e.IdNotificacion).HasColumnName("id_notificacion");
            entity.Property(e => e.FechaEnvio)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_envio");
            entity.Property(e => e.FechaLectura)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_lectura");
            entity.Property(e => e.IdEntrega).HasColumnName("id_entrega");
            entity.Property(e => e.IdUsuarioDestino).HasColumnName("id_usuario_destino");
            entity.Property(e => e.Mensaje).HasColumnName("mensaje");

            entity.HasOne(d => d.IdEntregaNavigation).WithMany(p => p.TblNotificacions)
                .HasForeignKey(d => d.IdEntrega)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_notificacion_entrega");

            entity.HasOne(d => d.IdUsuarioDestinoNavigation).WithMany(p => p.TblNotificacions)
                .HasForeignKey(d => d.IdUsuarioDestino)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_notificacion_destinatario");
        });

        modelBuilder.Entity<TblProyecto>(entity =>
        {
            entity.HasKey(e => e.IdProyecto).HasName("tbl_proyecto_pkey");

            entity.ToTable("tbl_proyecto");

            entity.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
            entity.Property(e => e.Anio).HasColumnName("anio");
            entity.Property(e => e.EsDestacado).HasColumnName("es_destacado");
            entity.Property(e => e.EstadoAutorizacion)
                .HasMaxLength(20)
                .HasDefaultValueSql("'pendiente'::character varying")
                .HasColumnName("estado_autorizacion");
            entity.Property(e => e.EstadoPublicacion)
                .HasMaxLength(15)
                .HasDefaultValueSql("'no_publicado'::character varying")
                .HasColumnName("estado_publicacion");
            entity.Property(e => e.FechaActualizacion)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_actualizacion");
            entity.Property(e => e.FechaRegistro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_registro");
            entity.Property(e => e.IdCarrera).HasColumnName("id_carrera");
            entity.Property(e => e.IdMateria).HasColumnName("id_materia");
            entity.Property(e => e.IdTematica).HasColumnName("id_tematica");
            entity.Property(e => e.IdTipoProyecto).HasColumnName("id_tipo_proyecto");
            entity.Property(e => e.Resumen).HasColumnName("resumen");
            entity.Property(e => e.Titulo)
                .HasMaxLength(300)
                .HasColumnName("titulo");

            entity.HasOne(d => d.IdCarreraNavigation).WithMany(p => p.TblProyectos)
                .HasForeignKey(d => d.IdCarrera)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_carrera");

            entity.HasOne(d => d.IdMateriaNavigation).WithMany(p => p.TblProyectos)
                .HasForeignKey(d => d.IdMateria)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_materia");

            entity.HasOne(d => d.IdTematicaNavigation).WithMany(p => p.TblProyectos)
                .HasForeignKey(d => d.IdTematica)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_tematica");

            entity.HasOne(d => d.IdTipoProyectoNavigation).WithMany(p => p.TblProyectos)
                .HasForeignKey(d => d.IdTipoProyecto)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_tipo");

            // Relación con dato propio: si se autorizó mostrar al asesor.
            entity.HasMany(d => d.IdDocentes).WithMany(p => p.IdProyectos)
                .UsingEntity<TblProyectoDocente>(
                    r => r.HasOne(e => e.IdDocenteNavigation).WithMany(p => p.TblProyectoDocentes)
                        .HasForeignKey(e => e.IdDocente)
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_proyecto_docente_docente"),
                    l => l.HasOne(e => e.IdProyectoNavigation).WithMany(p => p.TblProyectoDocentes)
                        .HasForeignKey(e => e.IdProyecto)
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_proyecto_docente_proyecto"),
                    j =>
                    {
                        j.HasKey(e => new { e.IdProyecto, e.IdDocente }).HasName("pk_proyecto_docente");
                        j.ToTable("tbl_proyecto_docente");
                        j.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
                        j.Property(e => e.IdDocente).HasColumnName("id_docente");
                        j.Property(e => e.NombreAutorizado)
                            .HasDefaultValue(false)
                            .HasColumnName("nombre_autorizado");
                    });

            entity.HasMany(d => d.IdEtiqueta).WithMany(p => p.IdProyectos)
                .UsingEntity<Dictionary<string, object>>(
                    "TblProyectoEtiquetum",
                    r => r.HasOne<TblEtiqueta>().WithMany()
                        .HasForeignKey("IdEtiqueta")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_proyecto_etiqueta_etiqueta"),
                    l => l.HasOne<TblProyecto>().WithMany()
                        .HasForeignKey("IdProyecto")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_proyecto_etiqueta_proyecto"),
                    j =>
                    {
                        j.HasKey("IdProyecto", "IdEtiqueta").HasName("pk_proyecto_etiqueta");
                        j.ToTable("tbl_proyecto_etiqueta");
                        j.IndexerProperty<int>("IdProyecto").HasColumnName("id_proyecto");
                        j.IndexerProperty<int>("IdEtiqueta").HasColumnName("id_etiqueta");
                    });
        });

        modelBuilder.Entity<TblProyectoAutor>(entity =>
        {
            entity.HasKey(e => new { e.IdProyecto, e.IdAutor }).HasName("pk_proyecto_autor");

            entity.ToTable("tbl_proyecto_autor");

            entity.HasIndex(e => new { e.IdProyecto, e.OrdenAutoria }, "uq_proyecto_orden_autoria").IsUnique();

            entity.Property(e => e.IdProyecto).HasColumnName("id_proyecto");
            entity.Property(e => e.IdAutor).HasColumnName("id_autor");
            entity.Property(e => e.OrdenAutoria).HasColumnName("orden_autoria");

            entity.HasOne(d => d.IdAutorNavigation).WithMany(p => p.TblProyectoAutors)
                .HasForeignKey(d => d.IdAutor)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_autor_autor");

            entity.HasOne(d => d.IdProyectoNavigation).WithMany(p => p.TblProyectoAutors)
                .HasForeignKey(d => d.IdProyecto)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_proyecto_autor_proyecto");
        });

        modelBuilder.Entity<TblRecurso>(entity =>
        {
            entity.HasKey(e => e.IdRecurso).HasName("tbl_recurso_pkey");

            entity.ToTable("tbl_recurso");

            entity.Property(e => e.IdRecurso).HasColumnName("id_recurso");
            entity.Property(e => e.IdEntrega).HasColumnName("id_entrega");
            entity.Property(e => e.IdTipoRecurso).HasColumnName("id_tipo_recurso");
            entity.Property(e => e.Nombre)
                .HasMaxLength(200)
                .HasColumnName("nombre");
            entity.Property(e => e.Ubicacion).HasColumnName("ubicacion");
            entity.Property(e => e.DifusionAutorizada)
                .HasDefaultValue(false)
                .HasColumnName("difusion_autorizada");

            entity.HasOne(d => d.IdEntregaNavigation).WithMany(p => p.TblRecursos)
                .HasForeignKey(d => d.IdEntrega)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_recurso_entrega");

            entity.HasOne(d => d.IdTipoRecursoNavigation).WithMany(p => p.TblRecursos)
                .HasForeignKey(d => d.IdTipoRecurso)
                .OnDelete(DeleteBehavior.Restrict)
                .HasConstraintName("fk_recurso_tipo");
        });

        modelBuilder.Entity<TblRol>(entity =>
        {
            entity.HasKey(e => e.IdRol).HasName("tbl_rol_pkey");

            entity.ToTable("tbl_rol");

            entity.HasIndex(e => e.NombreRol, "uq_rol_nombre").IsUnique();

            entity.Property(e => e.IdRol).HasColumnName("id_rol");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.NombreRol)
                .HasMaxLength(50)
                .HasColumnName("nombre_rol");
        });

        modelBuilder.Entity<TblTematica>(entity =>
        {
            entity.HasKey(e => e.IdTematica).HasName("tbl_tematica_pkey");

            entity.ToTable("tbl_tematica");

            entity.HasIndex(e => e.Nombre, "uq_tematica_nombre").IsUnique();

            entity.Property(e => e.IdTematica).HasColumnName("id_tematica");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.Nombre)
                .HasMaxLength(100)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<TblTipoProyecto>(entity =>
        {
            entity.HasKey(e => e.IdTipoProyecto).HasName("tbl_tipo_proyecto_pkey");

            entity.ToTable("tbl_tipo_proyecto");

            entity.HasIndex(e => e.Nombre, "uq_tipo_proyecto_nombre").IsUnique();

            entity.Property(e => e.IdTipoProyecto).HasColumnName("id_tipo_proyecto");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.Nombre)
                .HasMaxLength(50)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<TblTipoRecurso>(entity =>
        {
            entity.HasKey(e => e.IdTipoRecurso).HasName("tbl_tipo_recurso_pkey");

            entity.ToTable("tbl_tipo_recurso");

            entity.HasIndex(e => e.Nombre, "uq_tipo_recurso_nombre").IsUnique();

            entity.Property(e => e.IdTipoRecurso).HasColumnName("id_tipo_recurso");
            entity.Property(e => e.Descripcion).HasColumnName("descripcion");
            entity.Property(e => e.Nombre)
                .HasMaxLength(50)
                .HasColumnName("nombre");
        });

        modelBuilder.Entity<TblUsuario>(entity =>
        {
            entity.HasKey(e => e.IdUsuario).HasName("tbl_usuario_pkey");

            entity.ToTable("tbl_usuario");

            entity.HasIndex(e => e.Correo, "uq_usuario_correo").IsUnique();

            entity.Property(e => e.IdUsuario).HasColumnName("id_usuario");
            entity.Property(e => e.Activo)
                .HasDefaultValue(true)
                .HasColumnName("activo");
            entity.Property(e => e.Apellidos)
                .HasMaxLength(100)
                .HasColumnName("apellidos");
            entity.Property(e => e.ContrasenaHash).HasColumnName("contrasena_hash");
            entity.Property(e => e.Correo)
                .HasMaxLength(254)
                .HasColumnName("correo");
            entity.Property(e => e.FechaRegistro)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("fecha_registro");
            entity.Property(e => e.Nombres)
                .HasMaxLength(100)
                .HasColumnName("nombres");

            entity.HasMany(d => d.IdRols).WithMany(p => p.IdUsuarios)
                .UsingEntity<Dictionary<string, object>>(
                    "TblUsuarioRol",
                    r => r.HasOne<TblRol>().WithMany()
                        .HasForeignKey("IdRol")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_usuario_rol_rol"),
                    l => l.HasOne<TblUsuario>().WithMany()
                        .HasForeignKey("IdUsuario")
                        .OnDelete(DeleteBehavior.Restrict)
                        .HasConstraintName("fk_usuario_rol_usuario"),
                    j =>
                    {
                        j.HasKey("IdUsuario", "IdRol").HasName("pk_usuario_rol");
                        j.ToTable("tbl_usuario_rol");
                        j.IndexerProperty<int>("IdUsuario").HasColumnName("id_usuario");
                        j.IndexerProperty<int>("IdRol").HasColumnName("id_rol");
                    });
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
