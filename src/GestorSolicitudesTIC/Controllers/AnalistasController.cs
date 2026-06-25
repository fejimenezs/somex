using Microsoft.AspNetCore.Mvc;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Controllers;

public class AnalistasController : Controller
{
    private readonly IAnalistaRepository _repo;
    public AnalistasController(IAnalistaRepository repo) => _repo = repo;

    public async Task<IActionResult> Index() => View(await _repo.GetAllAsync());

    public IActionResult Create() => View(new Analista());

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Analista a)
    {
        if (!ModelState.IsValid) return View(a);
        try
        {
            await _repo.CreateAsync(a);
            TempData["Exito"] = "Analista creado correctamente.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(a);
        }
    }

    public async Task<IActionResult> Edit(int id)
    {
        var a = await _repo.GetByIdAsync(id);
        return a is null ? NotFound() : View(a);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(Analista a)
    {
        if (!ModelState.IsValid) return View(a);
        try
        {
            await _repo.UpdateAsync(a);
            TempData["Exito"] = "Analista actualizado.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(a);
        }
    }

    [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        await _repo.DeleteAsync(id);
        TempData["Exito"] = "Analista desactivado.";
        return RedirectToAction(nameof(Index));
    }
}
