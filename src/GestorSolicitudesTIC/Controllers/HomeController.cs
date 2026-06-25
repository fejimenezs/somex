using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Data;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Controllers;

public class HomeController : Controller
{
    private readonly ApplicationDbContext _db;

    public HomeController(ApplicationDbContext db) => _db = db;

    public async Task<IActionResult> Index()
    {
        ViewBag.TotalAbiertas   = await _db.Solicitudes.CountAsync(s => s.Estado == "Abierta");
        ViewBag.TotalEnProceso  = await _db.Solicitudes.CountAsync(s => s.Estado == "En Proceso");
        ViewBag.TotalResueltas  = await _db.Solicitudes.CountAsync(s => s.Estado == "Resuelta");
        ViewBag.TotalCerradas   = await _db.Solicitudes.CountAsync(s => s.Estado == "Cerrada");
        ViewBag.TotalAlta       = await _db.Solicitudes.CountAsync(s => s.Prioridad == "Alta" && s.Estado != "Cerrada");
        ViewBag.UltimasAbiertas = await _db.Solicitudes
            .Include(s => s.Usuario).Include(s => s.Categoria)
            .Where(s => s.Estado != "Cerrada")
            .OrderByDescending(s => s.FechaCreacion)
            .Take(5).ToListAsync();
        return View();
    }

    public IActionResult Privacy() => View();

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error() =>
        View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
}
