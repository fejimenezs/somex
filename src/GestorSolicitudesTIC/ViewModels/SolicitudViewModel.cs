using Microsoft.AspNetCore.Mvc.Rendering;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.ViewModels;

public class SolicitudViewModel
{
    public Solicitud Solicitud { get; set; } = new();
    public IEnumerable<SelectListItem> Categorias { get; set; } = [];
    public IEnumerable<SelectListItem> Usuarios   { get; set; } = [];
    public IEnumerable<SelectListItem> Analistas  { get; set; } = [];
}

public class SolicitudFiltroViewModel
{
    public string? Estado     { get; set; }
    public string? Prioridad  { get; set; }
    public DateTime? FechaDesde { get; set; }
    public DateTime? FechaHasta { get; set; }
    public IEnumerable<Solicitud> Solicitudes { get; set; } = [];
}

public class CambiarEstadoViewModel
{
    public int    SolicitudId  { get; set; }
    public string EstadoActual { get; set; } = string.Empty;
    public string EstadoNuevo  { get; set; } = string.Empty;
    public string? Observacion { get; set; }
    public int?   AnalistaId   { get; set; }
    public IEnumerable<SelectListItem> Analistas { get; set; } = [];
    public IEnumerable<SelectListItem> EstadosSiguientes { get; set; } = [];
}

public class ReporteAnalistaViewModel
{
    public string Analista            { get; set; } = string.Empty;
    public string Especialidad        { get; set; } = string.Empty;
    public int    TotalSolicitudes    { get; set; }
    public int    Cerradas            { get; set; }
    public int    Resueltas           { get; set; }
    public int    EnCurso             { get; set; }
    public decimal? PromedioHorasAtencion { get; set; }
}
