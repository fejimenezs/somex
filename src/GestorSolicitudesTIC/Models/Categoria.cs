using System.ComponentModel.DataAnnotations;

namespace GestorSolicitudesTIC.Models;

public class Categoria
{
    public int CategoriaId { get; set; }

    [Required]
    [StringLength(50)]
    public string Nombre { get; set; } = string.Empty;

    [StringLength(200)]
    public string? Descripcion { get; set; }

    public bool Activo { get; set; } = true;

    public ICollection<Solicitud> Solicitudes { get; set; } = new List<Solicitud>();
}
