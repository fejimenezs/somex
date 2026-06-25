# Contexto de sesión — Gestor de Solicitudes TIC · SOMEX®
> Archivo vivo: se actualiza en cada avance importante de la conversación.  
> Propósito: no perder el hilo entre sesiones o si se corta el contexto.

---

## 🧑‍💻 Quién y qué
- **Desarrollador:** Fausto Jiménez (`fejimenezs88@gmail.com`)
- **Proyecto:** Prueba Técnica Desarrollador TIC — empresa SOMEX® (sales minerales ganadería, Colombia)
- **Repositorio:** `https://github.com/fejimenezs/somex.git`
- **Carpeta local:** `C:\Users\USER\Desktop\Prueba_tecnicas\Somex\`
- **Rama:** `master`

---

## 📦 Stack tecnológico
| Capa | Tecnología |
|---|---|
| Backend | ASP.NET Core MVC (.NET 8) |
| ORM | Entity Framework Core 8 |
| Stored Procedures | Dapper 2.1.35 |
| Base de datos | SQL Server (Developer Edition) |
| Frontend | Bootstrap 5 + JS vanilla |
| Alertas | Power Automate |
| Reportes | Power BI Desktop |
| Fuente | Montserrat (Google Fonts) |
| Colores SOMEX | Verde `#1CAE27` · Verde oscuro `#0A3B0A` · Lima `#8DC63F` |

---

## ✅ Lo que ya está hecho

### Fase 0 — Planeación
- [x] Leer y analizar la prueba técnica (docx extraído como ZIP)
- [x] `README.md` con descripción completa del proyecto
- [x] `PLAN.md` — checklist de 6 fases (mapa de desarrollo)
- [x] `.gitignore` para .NET / ASP.NET Core
- [x] Repositorio Git inicializado en la carpeta del proyecto
- [x] Remote apuntando a `https://github.com/fejimenezs/somex.git`

### Fase 1 — Base de datos (`database/GestorSolicitudesTIC.sql`)
- [x] 6 tablas: `Categorias`, `Usuarios`, `Analistas`, `Solicitudes`, `HistorialEstados`, `AlertasSLA`
- [x] 6 índices de rendimiento
- [x] SP `sp_CrearSolicitud` (OUTPUT @SolicitudId, inserta primer historial)
- [x] SP `sp_CambiarEstadoSolicitud` (valida flujo, no permite retroceder ni reabrir cerradas)
- [x] SP `sp_ReporteSolicitudesPorAnalista` (@FechaInicio, @FechaFin)
- [x] Vista `vw_SolicitudesAbiertas`
- [x] Vista `vw_TiempoPromedioAtencion`
- [x] `sp_JobAlertasSLA` + script de SQL Server Agent Job (diario 7:00 a.m.)
- [x] 14 registros seed (categorías, usuarios, analistas, solicitudes con historial coherente)

### Fase 2 — Aplicación ASP.NET Core MVC
**Estructura:**
```
src/GestorSolicitudesTIC/
├── Controllers/        HomeController, SolicitudesController, UsuariosController, AnalistasController
├── Data/               ApplicationDbContext.cs
├── Interfaces/         ISolicitudRepository, IUsuarioRepository, IAnalistaRepository
├── Models/             Solicitud, Usuario, Analista, Categoria, HistorialEstado, AlertaSLA
├── Repositories/       SolicitudRepository (Dapper→SPs), UsuarioRepository, AnalistaRepository
├── ViewModels/         SolicitudViewModel, SolicitudFiltroViewModel, CambiarEstadoViewModel, ReporteAnalistaViewModel
├── Views/
│   ├── Home/           Index.cshtml (Dashboard KPIs)
│   ├── Solicitudes/    Index, Create, Details, CambiarEstado, Reporte
│   ├── Usuarios/       Index, Create, Edit
│   ├── Analistas/      Index, Create, Edit
│   └── Shared/         _Layout.cshtml (sidebar + navbar SOMEX)
└── wwwroot/
    ├── css/site.css    (SOMEX brand: KPIs, badges, tabla dark-header, timeline, pill-buttons)
    └── js/site.js      (char counter, Bootstrap validation, delete modal, sidebar active)
```
- [x] Build: **0 errores, 0 advertencias** (.NET 8)
- [x] Patrón Repository + DI en `Program.cs`
- [x] Dapper llama SPs con `CommandType.StoredProcedure`
- [x] EF Core para queries con `.Include()` y filtros dinámicos
- [x] Flujo de estados: Abierta → En Proceso → Resuelta → Cerrada (solo adelante)
- [x] Modal Bootstrap de confirmación antes de eliminar
- [x] Dashboard con 4 KPI cards + tabla últimas solicitudes
- [x] Reporte por analista con KPIs (rango de fechas)
- [x] Timeline de historial en vista Detalle
- [x] Badges por estado (azul/amarillo/verde/gris) y prioridad (rojo/amarillo/verde)

### Documentación interna
- [x] `docs/index.html` — página explicativa para colaboradores SOMEX (uso interno)
  - Secciones: Hero, Antes vs Ahora, ¿Qué hace?, Flujo 4 pasos, Roles, Prioridades, Cómo crear solicitud, SLA, Power BI mockup, Tecnología, FAQ (8 preguntas), Footer
  - FAQ con acordeón JavaScript
  - Badge "Uso interno SOMEX" en navbar

---

## ⬜ Pendiente

### Inmediato — Desbloquear SQL Server
- [ ] **Iniciar el servicio SQL Server** (está instalado pero detenido)
  - `Windows + R` → `services.msc`
  - Buscar `SQL Server (MSSQLSERVER)` o `SQL Server (SQLEXPRESS)`
  - Clic derecho → **Iniciar**
- [ ] Conectar SSMS con `localhost` (o `.`)
  - Cifrar: **Opcional**
  - Certificado de servidor de confianza: **✅ marcado**
- [ ] Ejecutar `database/GestorSolicitudesTIC.sql` en SSMS (F5)
- [ ] Verificar que aparezca la BD `GestorSolicitudesTIC` en el Explorador de objetos

### Fase 2 — Prueba E2E (después de BD)
- [ ] `dotnet run` desde `src/GestorSolicitudesTIC/`
  - Comando: `& "C:\Program Files\dotnet\dotnet.exe" run --project "C:\Users\USER\Desktop\Prueba_tecnicas\Somex\src\GestorSolicitudesTIC"`
- [ ] Probar flujo completo: crear solicitud → En Proceso → Resuelta → Cerrada
- [ ] Verificar filtros en la lista
- [ ] Verificar historial/timeline en el detalle
- [ ] Verificar reporte por analista

### Fase 3 — Power Automate
- [ ] Crear flujo con trigger programado (diario)
- [ ] Acción: consultar tabla `AlertasSLA` (WHERE Notificado = 0)
- [ ] Acción: notificación (Outlook/Teams)
- [ ] Exportar como paquete `.zip` o capturas de cada paso

### Fase 4 — Power BI
- [ ] Conectar Power BI Desktop a `GestorSolicitudesTIC`
- [ ] Importar tablas + vistas
- [ ] Medidas DAX: Total, % SLA, Promedio horas
- [ ] Visualizaciones: KPIs, barras por categoría, dona por prioridad, columnas por analista
- [ ] Guardar como `GestorSolicitudesTIC.pbix`

### Fase 5 — Documentación
- [ ] Acta de levantamiento de requerimientos
- [ ] Diagrama ER (imagen exportada)
- [ ] Manual de usuario (paso a paso con screenshots)
- [ ] `documents/DocumentoSoporte.pdf`

### Fase 6 — Revisión final
- [ ] Prueba de extremo a extremo
- [ ] Revisar historial de commits
- [ ] (Opcional) Video demo 3-5 min

---

## 🔧 Datos técnicos clave

### Cadena de conexión (`appsettings.json`)
```json
"DefaultConnection": "Server=.;Database=GestorSolicitudesTIC;Trusted_Connection=True;TrustServerCertificate=True;"
```

### Comando para correr la app
```powershell
& "C:\Program Files\dotnet\dotnet.exe" run --project "C:\Users\USER\Desktop\Prueba_tecnicas\Somex\src\GestorSolicitudesTIC"
```

### Comando para build
```powershell
& "C:\Program Files\dotnet\dotnet.exe" build "C:\Users\USER\Desktop\Prueba_tecnicas\Somex\src\GestorSolicitudesTIC\GestorSolicitudesTIC.csproj"
```

### Git
```bash
# Desde: C:\Users\USER\Desktop\Prueba_tecnicas\Somex\
git add .
git commit -m "mensaje"
git push origin master
```

---

## 🐛 Errores ya resueltos (para no repetirlos)
| Error | Causa | Solución |
|---|---|---|
| `dotnet` not found | No está en el PATH de Windows | Usar ruta completa `C:\Program Files\dotnet\dotnet.exe` |
| Write sin Read previo | Herramienta Edit/Write requiere leer primero | Siempre hacer Read antes de editar archivos existentes |
| Git en carpeta incorrecta | Repo raíz en `C:/Users/USER` (otro proyecto) | Init repo nuevo dentro de `Somex/`, remote a `fejimenezs/somex.git` |
| Abrir `.docx` | Word lo tenía bloqueado | Copiar a `.zip`, extraer, leer `word/document.xml` |
| `<em>` en expresión Razor | Sintaxis inválida en C# inline | Usar `@if` / `else` con HTML separado |
| SQL Server error 40 (Named Pipes) | Servicio SQL Server detenido | Iniciar servicio en `services.msc` |
| SSMS no conecta con `localhost` | Cifrar=Obligatorio + sin Trust Certificate | Cifrar→Opcional + marcar "Certificado de confianza" |

---

## 📁 Archivos importantes del proyecto
```
Somex/
├── README.md                          ← Descripción general del proyecto
├── PLAN.md                            ← Checklist fases 0-6
├── CONTEXTO_SESION.md                 ← Este archivo (contexto de sesión)
├── database/
│   └── GestorSolicitudesTIC.sql       ← Script completo BD (ejecutar en SSMS)
├── docs/
│   └── index.html                     ← Página interna explicativa para colaboradores
├── identidad_de_marca/
│   ├── logo.jpg
│   └── Captura de pantalla *.png      ← 8 screenshots de somex.com.co
└── src/GestorSolicitudesTIC/
    ├── GestorSolicitudesTIC.csproj
    ├── Program.cs
    ├── appsettings.json
    ├── Controllers/                   ← Home, Solicitudes, Usuarios, Analistas
    ├── Data/ApplicationDbContext.cs
    ├── Interfaces/
    ├── Models/                        ← 6 entidades
    ├── Repositories/                  ← Dapper + EF Core
    ├── ViewModels/
    ├── Views/                         ← Todas las vistas .cshtml
    └── wwwroot/css/site.css · js/site.js
```

---

## 🎯 Estado del progreso
```
✅ Fase 0 — Planeación y estructura
✅ Fase 1 — SQL Server (script listo, falta ejecutar)
✅ Fase 2 — ASP.NET Core MVC (build OK, falta probar con BD)
🔴 BLOQUEADO — Servicio SQL Server detenido (iniciar en services.msc)
⬜ Fase 3 — Power Automate
⬜ Fase 4 — Power BI
⬜ Fase 5 — Documentación
⬜ Fase 6 — Revisión final y entrega
```

---

*Última actualización: 25/06/2026 · Sesión en pausa — retomar con iniciar SQL Server*
