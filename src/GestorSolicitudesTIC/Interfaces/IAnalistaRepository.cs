using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Interfaces;

public interface IAnalistaRepository
{
    Task<IEnumerable<Analista>> GetAllAsync();
    Task<Analista?> GetByIdAsync(int id);
    Task<int> CreateAsync(Analista analista);
    Task UpdateAsync(Analista analista);
    Task DeleteAsync(int id);
}
