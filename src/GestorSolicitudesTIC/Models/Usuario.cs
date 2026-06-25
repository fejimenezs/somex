using System.ComponentModel.DataAnnotations;

namespace GestorSolicitudesTIC.Models;

public class Usuario
{
    public int UsuarioId { get; set; }

    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(100)]
    public string Nombre { get; set; } = string.Empty;

    [Required(ErrorMessage = "El área es obligatoria.")]
    [StringLength(80)]
    public string Area { get; set; } = string.Empty;

    [Required(ErrorMessage = "El correo es obligatorio.")]
    [EmailAddress(ErrorMessage = "Correo inválido.")]
    [StringLength(120)]
    public string Correo { get; set; } = string.Empty;

    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    public ICollection<Solicitud> Solicitudes { get; set; } = new List<Solicitud>();
}
