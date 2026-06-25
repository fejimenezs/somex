using System.ComponentModel.DataAnnotations;

namespace GestorSolicitudesTIC.Models;

public class HistorialEstado
{
    public int HistorialId { get; set; }
    public int SolicitudId { get; set; }

    [StringLength(20)]
    public string? EstadoAnterior { get; set; }

    [Required]
    [StringLength(20)]
    public string EstadoNuevo { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Observacion { get; set; }

    public DateTime FechaCambio { get; set; } = DateTime.Now;

    [StringLength(100)]
    public string UsuarioCambio { get; set; } = "Sistema";

    public Solicitud? Solicitud { get; set; }
}
