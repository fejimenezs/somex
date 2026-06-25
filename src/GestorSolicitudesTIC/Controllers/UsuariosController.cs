using Microsoft.AspNetCore.Mvc;
using GestorSolicitudesTIC.Interfaces;
using GestorSolicitudesTIC.Models;

namespace GestorSolicitudesTIC.Controllers;

public class UsuariosController : Controller
{
    private readonly IUsuarioRepository _repo;
    public UsuariosController(IUsuarioRepository repo) => _repo = repo;

    public async Task<IActionResult> Index() => View(await _repo.GetAllAsync());

    public IActionResult Create() => View(new Usuario());

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(Usuario u)
    {
        if (!ModelState.IsValid) return View(u);
        try
        {
            await _repo.CreateAsync(u);
            TempData["Exito"] = "Usuario creado correctamente.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(u);
        }
    }

    public async Task<IActionResult> Edit(int id)
    {
        var u = await _repo.GetByIdAsync(id);
        return u is null ? NotFound() : View(u);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(Usuario u)
    {
        if (!ModelState.IsValid) return View(u);
        try
        {
            await _repo.UpdateAsync(u);
            TempData["Exito"] = "Usuario actualizado.";
            return RedirectToAction(nameof(Index));
        }
        catch (Exception ex)
        {
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(u);
        }
    }

    [HttpPost, ActionName("Delete"), ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id)
    {
        await _repo.DeleteAsync(id);
        TempData["Exito"] = "Usuario desactivado.";
        return RedirectToAction(nameof(Index));
    }
}
