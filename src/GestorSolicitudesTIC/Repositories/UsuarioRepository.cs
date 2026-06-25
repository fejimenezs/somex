using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Data;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Repositories;

public class UsuarioRepository : IUsuarioRepository
{
    private readonly ApplicationDbContext _db;
    public UsuarioRepository(ApplicationDbContext db) => _db = db;

    public async Task<IEnumerable<Usuario>> GetAllAsync() =>
        await _db.Usuarios.Where(u => u.Activo).OrderBy(u => u.Nombre).ToListAsync();

    public async Task<Usuario?> GetByIdAsync(int id) =>
        await _db.Usuarios.FindAsync(id);

    public async Task<int> CreateAsync(Usuario u)
    {
        _db.Usuarios.Add(u);
        await _db.SaveChangesAsync();
        return u.UsuarioId;
    }

    public async Task UpdateAsync(Usuario u)
    {
        _db.Usuarios.Update(u);
        await _db.SaveChangesAsync();
    }

    public async Task DeleteAsync(int id)
    {
        var u = await _db.Usuarios.FindAsync(id);
        if (u != null) { u.Activo = false; await _db.SaveChangesAsync(); }
    }
}
