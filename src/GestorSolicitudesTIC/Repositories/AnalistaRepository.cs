using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Data;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Repositories;

public class AnalistaRepository : IAnalistaRepository
{
    private readonly ApplicationDbContext _db;
    public AnalistaRepository(ApplicationDbContext db) => _db = db;

    public async Task<IEnumerable<Analista>> GetAllAsync() =>
        await _db.Analistas.Where(a => a.Activo).OrderBy(a => a.Nombre).ToListAsync();

    public async Task<Analista?> GetByIdAsync(int id) =>
        await _db.Analistas.FindAsync(id);

    public async Task<int> CreateAsync(Analista a)
    {
        _db.Analistas.Add(a);
        await _db.SaveChangesAsync();
        return a.AnalistaId;
    }

    public async Task UpdateAsync(Analista a)
    {
        _db.Analistas.Update(a);
        await _db.SaveChangesAsync();
    }

    public async Task DeleteAsync(int id)
    {
        var a = await _db.Analistas.FindAsync(id);
        if (a != null) { a.Activo = false; await _db.SaveChangesAsync(); }
    }
}
