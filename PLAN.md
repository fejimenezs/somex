# Plan de Trabajo — Gestor de Solicitudes TIC
### Mapa de desarrollo · Checklist por fases

> Usa este documento como mapa diario. Marca cada ítem al completarlo.  
> **Regla de oro:** flujo funcional de extremo a extremo primero, detalles visuales después.

---

## Resumen de entregables

| # | Entregable | Estado |
|---|---|---|
| 1 | Repositorio Git con commits históricos | ✅ Completado |
| 2 | Script SQL Server completo | ✅ Completado |
| 3 | Aplicación ASP.NET Core MVC funcional | ✅ Completado |
| 4 | Flujo Power Automate (alertas SLA) | ⬜ Pendiente |
| 5 | Tablero Power BI (.pbix) | ⬜ Pendiente |
| 6 | Documento de soporte (PDF/Word) | ⬜ Pendiente |
| 7 | Sitio web explicativo (docs/index.html) | ✅ Completado |
| 8 | Video demo (opcional) | ⬜ Opcional |

---

## FASE 0 — Preparación y planeación ✅
> Objetivo: tener el entorno listo y el mapa claro antes de escribir código.

- [x] Leer y analizar el documento de la prueba técnica
- [x] Crear estructura de carpetas del proyecto
- [x] Crear README.md
- [x] Crear este plan de trabajo (PLAN.md)
- [x] Crear sitio web explicativo (docs/index.html)
- [x] Inicializar repositorio Git con commit inicial
- [x] Definir diagrama ER (entidades, relaciones, cardinalidades)
- [x] Decidir arquitectura de capas del proyecto ASP.NET

---

## FASE 1 — Base de datos SQL Server ✅
> Objetivo: tener el script SQL completo y funcional antes de tocar el backend.

### 1.1 Diseño del modelo relacional
- [x] Diseñar diagrama ER en papel / draw.io / dbdiagram.io
- [x] Definir tipos de dato, restricciones NOT NULL y CHECK
- [x] Definir índices (PK, FK, índices de búsqueda frecuente)

### 1.2 Creación de tablas
- [x] `Categorias` (catálogo: Incidente, Requerimiento, Mejora)
- [x] `Usuarios` (nombre, área, correo)
- [x] `Analistas` (nombre, especialidad)
- [x] `Solicitudes` (tabla principal + todas las FK + CHECK de prioridad/estado)
- [x] `HistorialEstados` (bitácora de cambios)
- [x] `AlertasSLA` (tabla de control para el Job y Power Automate)

### 1.3 Procedimientos almacenados
- [x] `sp_CrearSolicitud` — inserta solicitud y primer registro en HistorialEstados
- [x] `sp_CambiarEstadoSolicitud` — cambia estado, valida que "Cerrada" no retroceda, registra en historial
- [x] `sp_ReporteSolicitudesPorAnalista` — resumen por analista en rango de fechas

### 1.4 Vistas
- [x] `vw_SolicitudesAbiertas` — todas las no cerradas con nombres resueltos (sin IDs)
- [x] `vw_TiempoPromedioAtencion` — horas promedio entre apertura y cierre, por categoría

### 1.5 SQL Server Agent Job
- [x] Script T-SQL del Job (identificar solicitudes Alta > 24h en estado Abierta)
- [x] Insertar resultados en `AlertasSLA`
- [x] Configurar horario: diario 7:00 a.m.

### 1.6 Datos de prueba (seed)
- [x] Insertar 3 categorías
- [x] Insertar 5 usuarios de prueba
- [x] Insertar 3 analistas de prueba
- [x] Insertar 10–15 solicitudes con diferentes estados, prioridades y fechas
- [x] Insertar registros en HistorialEstados coherentes con las solicitudes

---

## FASE 2 — Aplicación ASP.NET Core MVC ✅
> Objetivo: aplicación web funcional con todas las operaciones CRUD y el flujo de estados.

### 2.1 Configuración inicial del proyecto
- [x] Crear proyecto ASP.NET Core MVC (.NET 8) en `src/GestorSolicitudesTIC/`
- [x] Agregar paquetes NuGet: EF Core, Dapper, SQL Server provider
- [x] Configurar `appsettings.json` con cadena de conexión
- [x] Crear estructura de carpetas: Controllers / Models / Repositories / Views / ViewModels

### 2.2 Capa de datos (Models / Entities)
- [x] Clase `Solicitud` con todas las propiedades y anotaciones
- [x] Clase `Usuario`
- [x] Clase `Analista`
- [x] Clase `Categoria`
- [x] Clase `HistorialEstado`
- [x] Clase `AlertaSLA`
- [x] `ApplicationDbContext` (EF Core)

### 2.3 Capa de repositorios / servicios
- [x] `ISolicitudRepository` + implementación (llama SPs via Dapper)
- [x] `IUsuarioRepository` + implementación
- [x] `IAnalistaRepository` + implementación
- [x] Inyección de dependencias en `Program.cs`

### 2.4 Módulo de Solicitudes (Controller + Views)
- [x] `SolicitudesController` con acciones: Index, Create, CambiarEstado, Details, Delete, Reporte
- [x] `Index.cshtml` — listado con filtros (estado, prioridad, fechas) + tabla Bootstrap
- [x] `Create.cshtml` — formulario con validaciones JS + char counter
- [x] `CambiarEstado.cshtml` — cambio de estado + asignación de analista
- [x] `Details.cshtml` — detalle + historial timeline de cambios de estado
- [x] `Reporte.cshtml` — reporte por analista con KPIs + tabla
- [x] Confirmar eliminación con modal Bootstrap (global en Layout)

### 2.5 Módulo de Usuarios (Controller + Views)
- [x] `UsuariosController` con acciones: Index, Create, Edit, Delete
- [x] Vistas con Bootstrap: tabla, formularios

### 2.6 Módulo de Analistas (Controller + Views)
- [x] `AnalistasController` con acciones: Index, Create, Edit, Delete
- [x] Vistas con Bootstrap: tabla, formularios

### 2.7 Validaciones JavaScript (obligatorias)
- [x] Validar campos obligatorios antes de enviar formulario (Bootstrap needs-validation)
- [x] Contador dinámico de caracteres restantes en Título (150) y Descripción (1000)
- [x] Modal de confirmación Bootstrap antes de eliminar solicitud/usuario/analista

### 2.8 UI / UX con Bootstrap 5 + SOMEX branding
- [x] Layout principal (`_Layout.cshtml`) con navbar dark + sidebar fijo 240px
- [x] Badges por estado (Abierta=azul, En Proceso=amarillo, Resuelta=verde, Cerrada=gris)
- [x] Badges por prioridad (Alta=rojo, Media=amarillo, Baja=verde)
- [x] Tabla dark-header verde oscuro SOMEX
- [x] Alertas TempData (Exito/Error) feedback de operaciones
- [x] Dashboard con KPIs (4 tarjetas) + tabla solicitudes recientes

### 2.9 Manejo de errores
- [x] Try/catch en todos los controladores con TempData["Error"]
- [x] Mensajes de error claros al usuario
- [x] 0 errores de compilación (.NET 8)

---

## FASE 3 — Power Automate ⬜ PENDIENTE
> Objetivo: flujo automatizado que notifica sobre solicitudes que incumplen SLA de 24 horas.
> **Requiere:** SQL Server instalado y BD poblada, cuenta Microsoft 365.

- [ ] Crear flujo en Power Automate (Flow)
- [ ] Configurar disparador: programado diario
- [ ] Acción: conectar a SQL Server → consultar tabla `AlertasSLA` (WHERE Notificado = 0)
- [ ] Condición: si hay registros
- [ ] Acción de notificación (Outlook / Teams)
- [ ] Exportar el flujo como paquete .zip

---

## FASE 4 — Power BI ⬜ PENDIENTE
> Objetivo: tablero visual con KPIs e indicadores.
> **Requiere:** SQL Server instalado y BD poblada, Power BI Desktop.

- [ ] Conectar a `GestorSolicitudesTIC` desde Power BI Desktop
- [ ] Importar tablas + vistas
- [ ] Medidas DAX: Total solicitudes, % Cumplimiento SLA, Tiempo Promedio
- [ ] Visualizaciones: KPIs, barras por categoría, dona por prioridad, columnas por analista
- [ ] Slicers de fecha y categoría
- [ ] Guardar como `GestorSolicitudesTIC.pbix`

---

## FASE 5 — Documentación ⬜ PENDIENTE
> Objetivo: entregar el documento de soporte requerido (1-2 páginas).

- [ ] Acta de levantamiento de requerimientos (supuestos del negocio)
- [ ] Diagrama ER (imagen exportada)
- [ ] Manual rápido de usuario (crear solicitud, cambiar estado)
- [ ] Supuestos y decisiones técnicas (.NET 8, EF Core + Dapper, Bootstrap 5)
- [ ] Exportar a PDF → `documents/DocumentoSoporte.pdf`

---

## FASE 6 — Revisión final y entrega ⬜ PENDIENTE
> **Requiere:** SQL Server instalado.

- [ ] Ejecutar `database/GestorSolicitudesTIC.sql` en SSMS
- [ ] `dotnet run` y prueba de extremo a extremo: crear → En Proceso → Resolver → Cerrar
- [ ] Verificar filtros, historial, reporte de analistas
- [ ] Verificar que el Job SQL inserta en AlertasSLA correctamente
- [ ] Revisar historial de Git (commits distribuidos)
- [ ] (Opcional) Grabar video demo de 3-5 minutos

---

## Orden de desarrollo — Estado actual

```
✅ Fase 0: Preparación y planeación
✅ Fase 1: Script SQL Server completo (tablas, SPs, vistas, Job, seed)
✅ Fase 2: Aplicación ASP.NET Core MVC completa (build 0 errores)
⬜ Fase 3: Power Automate  ← SIGUIENTE (requiere SQL Server instalado)
⬜ Fase 4: Power BI        ← SIGUIENTE (requiere SQL Server + datos)
⬜ Fase 5: Documentación
⬜ Fase 6: Prueba E2E + entrega final
```

---

## Criterios de evaluación (peso)

| Criterio | Peso | Estado |
|---|---|---|
| Desarrollo ASP.NET MVC | 30% | ✅ Completado |
| Base de datos SQL Server | 25% | ✅ Script listo (falta instalar) |
| Power Platform (Automate) | 15% | ⬜ Pendiente |
| Power BI | 15% | ⬜ Pendiente |
| Documentación | 10% | ⬜ Pendiente |
| Sustentación | 5% | ⬜ Pendiente |
