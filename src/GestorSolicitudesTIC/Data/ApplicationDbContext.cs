using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

    public DbSet<Solicitud>      Solicitudes     { get; set; }
    public DbSet<Usuario>        Usuarios        { get; set; }
    public DbSet<Analista>       Analistas       { get; set; }
    public DbSet<Categoria>      Categorias      { get; set; }
    public DbSet<HistorialEstado> HistorialEstados { get; set; }
    public DbSet<AlertaSLA>      AlertasSLA      { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<Solicitud>(e =>
        {
            e.HasOne(s => s.Categoria).WithMany(c => c.Solicitudes).HasForeignKey(s => s.CategoriaId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(s => s.Usuario).WithMany(u => u.Solicitudes).HasForeignKey(s => s.UsuarioId).OnDelete(DeleteBehavior.Restrict);
            e.HasOne(s => s.Analista).WithMany(a => a.Solicitudes).HasForeignKey(s => s.AnalistaId).IsRequired(false).OnDelete(DeleteBehavior.Restrict);
            e.Property(s => s.Estado).HasDefaultValue("Abierta");
            e.Property(s => s.FechaCreacion).HasDefaultValueSql("GETDATE()");
            e.Property(s => s.FechaUltModif).HasDefaultValueSql("GETDATE()");
        });

        builder.Entity<HistorialEstado>(e =>
        {
            e.HasOne(h => h.Solicitud).WithMany(s => s.Historial).HasForeignKey(h => h.SolicitudId).OnDelete(DeleteBehavior.Cascade);
            e.Property(h => h.FechaCambio).HasDefaultValueSql("GETDATE()");
            e.Property(h => h.UsuarioCambio).HasDefaultValueSql("SYSTEM_USER");
        });
    }
}
