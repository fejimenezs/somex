namespace GestorSolicitudesTIC.Models;

public class AlertaSLA
{
    public int AlertaId { get; set; }
    public int SolicitudId { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string UsuarioNombre { get; set; } = string.Empty;
    public string? AnalistaNombre { get; set; }
    public decimal HorasTranscurr { get; set; }
    public DateTime FechaDeteccion { get; set; } = DateTime.Now;
    public bool Notificado { get; set; } = false;
}
