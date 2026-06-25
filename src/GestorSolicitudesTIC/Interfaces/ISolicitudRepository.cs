using GestorSolicitudesTIC.Models;
using GestorSolicitudesTIC.ViewModels;

namespace GestorSolicitudesTIC.Interfaces;

public interface ISolicitudRepository
{
    Task<IEnumerable<Solicitud>> GetAllAsync(string? estado = null, string? prioridad = null, DateTime? desde = null, DateTime? hasta = null);
    Task<Solicitud?> GetByIdAsync(int id);
    Task<int> CrearAsync(Solicitud solicitud);
    Task CambiarEstadoAsync(int solicitudId, string estadoNuevo, string? observacion, int? analistaId);
    Task<IEnumerable<ReporteAnalistaViewModel>> ReportePorAnalistaAsync(DateTime desde, DateTime hasta);
}
