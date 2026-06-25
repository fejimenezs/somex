using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Data;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;
using GestorSolicitudesTIC.ViewModels;

namespace GestorSolicitudesTIC.Repositories;

public class SolicitudRepository : ISolicitudRepository
{
    private readonly ApplicationDbContext _db;
    private readonly string _conn;

    public SolicitudRepository(ApplicationDbContext db, IConfiguration config)
    {
        _db   = db;
        _conn = config.GetConnectionString("DefaultConnection")!;
    }

    public async Task<IEnumerable<Solicitud>> GetAllAsync(
        string? estado = null, string? prioridad = null,
        DateTime? desde = null, DateTime? hasta = null)
    {
        var query = _db.Solicitudes
            .Include(s => s.Categoria)
            .Include(s => s.Usuario)
            .Include(s => s.Analista)
            .AsQueryable();

        if (!string.IsNullOrEmpty(estado))    query = query.Where(s => s.Estado    == estado);
        if (!string.IsNullOrEmpty(prioridad)) query = query.Where(s => s.Prioridad == prioridad);
        if (desde.HasValue) query = query.Where(s => s.FechaCreacion >= desde.Value);
        if (hasta.HasValue) query = query.Where(s => s.FechaCreacion <= hasta.Value.AddDays(1));

        return await query.OrderByDescending(s => s.FechaCreacion).ToListAsync();
    }

    public async Task<Solicitud?> GetByIdAsync(int id) =>
        await _db.Solicitudes
            .Include(s => s.Categoria)
            .Include(s => s.Usuario)
            .Include(s => s.Analista)
            .Include(s => s.Historial)
            .FirstOrDefaultAsync(s => s.SolicitudId == id);

    // Llama al stored procedure sp_CrearSolicitud
    public async Task<int> CrearAsync(Solicitud s)
    {
        using var conn = new SqlConnection(_conn);
        var param = new DynamicParameters();
        param.Add("@Titulo",      s.Titulo);
        param.Add("@Descripcion", s.Descripcion);
        param.Add("@CategoriaId", s.CategoriaId);
        param.Add("@Prioridad",   s.Prioridad);
        param.Add("@UsuarioId",   s.UsuarioId);
        param.Add("@AnalistaId",  s.AnalistaId);
        param.Add("@SolicitudId", dbType: System.Data.DbType.Int32,
                  direction: System.Data.ParameterDirection.Output);

        await conn.ExecuteAsync("dbo.sp_CrearSolicitud", param,
            commandType: System.Data.CommandType.StoredProcedure);

        return param.Get<int>("@SolicitudId");
    }

    // Llama al stored procedure sp_CambiarEstadoSolicitud
    public async Task CambiarEstadoAsync(int solicitudId, string estadoNuevo, string? observacion, int? analistaId)
    {
        using var conn = new SqlConnection(_conn);
        var param = new DynamicParameters();
        param.Add("@SolicitudId",  solicitudId);
        param.Add("@EstadoNuevo",  estadoNuevo);
        param.Add("@Observacion",  observacion);
        param.Add("@AnalistaId",   analistaId);

        await conn.ExecuteAsync("dbo.sp_CambiarEstadoSolicitud", param,
            commandType: System.Data.CommandType.StoredProcedure);
    }

    // Llama al stored procedure sp_ReporteSolicitudesPorAnalista
    public async Task<IEnumerable<ReporteAnalistaViewModel>> ReportePorAnalistaAsync(DateTime desde, DateTime hasta)
    {
        using var conn = new SqlConnection(_conn);
        return await conn.QueryAsync<ReporteAnalistaViewModel>(
            "dbo.sp_ReporteSolicitudesPorAnalista",
            new { FechaInicio = desde, FechaFin = hasta },
            commandType: System.Data.CommandType.StoredProcedure);
    }
}
