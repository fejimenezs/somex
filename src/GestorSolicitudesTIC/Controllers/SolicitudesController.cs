using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using GestorSolicitudesTIC.Data;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;
using GestorSolicitudesTIC.ViewModels;

namespace GestorSolicitudesTIC.Controllers;

public class SolicitudesController : Controller
{
    private readonly ISolicitudRepository _repo;
    private readonly ApplicationDbContext _db;

    private static readonly Dictionary<string, string[]> _flujo = new()
    {
        ["Abierta"]    = ["En Proceso"],
        ["En Proceso"] = ["Resuelta"],
        ["Resuelta"]   = ["Cerrada"],
        ["Cerrada"]    = []
    };

    public SolicitudesController(ISolicitudRepository repo, ApplicationDbContext db)
    {
        _repo = repo;
        _db   = db;
    }

    // GET: /Solicitudes
    public async Task<IActionResult> Index(string? estado, string? prioridad, DateTime? desde, DateTime? hasta)
    {
        var lista = await _repo.GetAllAsync(estado, prioridad, desde, hasta);
        var vm = new SolicitudFiltroViewModel
        {
            Estado      = estado,
            Prioridad   = prioridad,
            FechaDesde  = desde,
            FechaHasta  = hasta,
            Solicitudes = lista
        };
        return View(vm);
    }

    // GET: /Solicitudes/Details/5
    public async Task<IActionResult> Details(int id)
    {
        var s = await _repo.GetByIdAsync(id);
        if (s is null) return NotFound();
        return View(s);
    }

    // GET: /Solicitudes/Create
    public async Task<IActionResult> Create()
    {
        var vm = await BuildViewModelAsync(new Solicitud());
        return View(vm);
    }

    // POST: /Solicitudes/Create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Solicitud solicitud)
    {
        if (!ModelState.IsValid)
            return View(await BuildViewModelAsync(solicitud));
        try
        {
            await _repo.CrearAsync(solicitud);
            TempData["Exito"] = "Solicitud creada correctamente.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, $"Error al crear: {ex.Message}");
            return View(await BuildViewModelAsync(solicitud));
        }
    }

    // GET: /Solicitudes/CambiarEstado/5
    public async Task<IActionResult> CambiarEstado(int id)
    {
        var s = await _repo.GetByIdAsync(id);
        if (s is null) return NotFound();

        var siguientes = _flujo.TryGetValue(s.Estado, out var next) ? next : [];

        var vm = new CambiarEstadoViewModel
        {
            SolicitudId  = s.SolicitudId,
            EstadoActual = s.Estado,
            Analistas    = await GetAnalistasSelectAsync(),
            EstadosSiguientes = siguientes.Select(e => new SelectListItem(e, e))
        };
        return View(vm);
    }

    // POST: /Solicitudes/CambiarEstado
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CambiarEstado(CambiarEstadoViewModel vm)
    {
        try
        {
            await _repo.CambiarEstadoAsync(vm.SolicitudId, vm.EstadoNuevo, vm.Observacion, vm.AnalistaId);
            TempData["Exito"] = $"Estado cambiado a '{vm.EstadoNuevo}' correctamente.";
            return RedirectToAction(nameof(Details), new { id = vm.SolicitudId });
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, $"Error: {ex.Message}");
            vm.Analistas = await GetAnalistasSelectAsync();
            return View(vm);
        }
    }

    // POST: /Solicitudes/Delete/5
    [HttpPost, ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        var s = await _db.Solicitudes.FindAsync(id);
        if (s is null) return NotFound();
        if (s.Estado == "Cerrada")
        {
            TempData["Error"] = "No se puede eliminar una solicitud cerrada.";
            return RedirectToAction(nameof(Index));
        }
        _db.Solicitudes.Remove(s);
        await _db.SaveChangesAsync();
        TempData["Exito"] = "Solicitud eliminada.";
        return RedirectToAction(nameof(Index));
    }

    // GET: /Solicitudes/Reporte
    public async Task<IActionResult> Reporte(DateTime? desde, DateTime? hasta)
    {
        desde ??= DateTime.Now.AddMonths(-1);
        hasta ??= DateTime.Now;
        var data = await _repo.ReportePorAnalistaAsync(desde.Value, hasta.Value);
        ViewBag.Desde = desde.Value.ToString("yyyy-MM-dd");
        ViewBag.Hasta = hasta.Value.ToString("yyyy-MM-dd");
        return View(data);
    }

    // ── helpers ────────────────────────────────────────────────
    private async Task<SolicitudViewModel> BuildViewModelAsync(Solicitud s) => new()
    {
        Solicitud  = s,
        Categorias = await _db.Categorias.Where(c => c.Activo)
                        .Select(c => new SelectListItem(c.Nombre, c.CategoriaId.ToString())).ToListAsync(),
        Usuarios   = await _db.Usuarios.Where(u => u.Activo)
                        .Select(u => new SelectListItem(u.Nombre + " — " + u.Area, u.UsuarioId.ToString())).ToListAsync(),
        Analistas  = await GetAnalistasSelectAsync()
    };

    private async Task<IEnumerable<SelectListItem>> GetAnalistasSelectAsync() =>
        await _db.Analistas.Where(a => a.Activo)
            .Select(a => new SelectListItem(a.Nombre + " (" + a.Especialidad + ")", a.AnalistaId.ToString()))
            .ToListAsync();
}
