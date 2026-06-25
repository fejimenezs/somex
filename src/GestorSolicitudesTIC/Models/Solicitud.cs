using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GestorSolicitudesTIC.Models;

public class Solicitud
{
    public int SolicitudId { get; set; }

    [Required(ErrorMessage = "El título es obligatorio.")]
    [StringLength(150, ErrorMessage = "Máximo 150 caracteres.")]
    public string Titulo { get; set; } = string.Empty;

    [Required(ErrorMessage = "La descripción es obligatoria.")]
    [StringLength(1000, ErrorMessage = "Máximo 1000 caracteres.")]
    public string Descripcion { get; set; } = string.Empty;

    [Required(ErrorMessage = "La categoría es obligatoria.")]
    public int CategoriaId { get; set; }

    [Required(ErrorMessage = "La prioridad es obligatoria.")]
    public string Prioridad { get; set; } = string.Empty;

    public string Estado { get; set; } = "Abierta";

    [Required(ErrorMessage = "El usuario solicitante es obligatorio.")]
    public int UsuarioId { get; set; }

    public int? AnalistaId { get; set; }

    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime FechaUltModif { get; set; } = DateTime.Now;
    public DateTime? FechaCierre { get; set; }

    // Navegación
    public Categoria? Categoria { get; set; }
    public Usuario? Usuario { get; set; }
    public Analista? Analista { get; set; }
    public ICollection<HistorialEstado> Historial { get; set; } = new List<HistorialEstado>();
}
