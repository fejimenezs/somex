# Plan de Trabajo — Gestor de Solicitudes TIC
### Mapa de desarrollo · Checklist por fases

> Usa este documento como mapa diario. Marca cada ítem al completarlo.  
> **Regla de oro:** flujo funcional de extremo a extremo primero, detalles visuales después.

---

## Resumen de entregables

| # | Entregable | Estado |
|---|---|---|
| 1 | Repositorio Git con commits históricos | ⬜ Pendiente |
| 2 | Script SQL Server completo | ⬜ Pendiente |
| 3 | Aplicación ASP.NET Core MVC funcional | ⬜ Pendiente |
| 4 | Flujo Power Automate (alertas SLA) | ⬜ Pendiente |
| 5 | Tablero Power BI (.pbix) | ⬜ Pendiente |
| 6 | Documento de soporte (PDF/Word) | ⬜ Pendiente |
| 7 | Sitio web explicativo (docs/index.html) | ✅ Completado |
| 8 | Video demo (opcional) | ⬜ Opcional |

---

## FASE 0 — Preparación y planeación
> Objetivo: tener el entorno listo y el mapa claro antes de escribir código.

- [x] Leer y analizar el documento de la prueba técnica
- [x] Crear estructura de carpetas del proyecto
- [x] Crear README.md
- [x] Crear este plan de trabajo (PLAN.md)
- [x] Crear sitio web explicativo (docs/index.html)
- [ ] Inicializar repositorio Git con commit inicial
- [ ] Definir diagrama ER (entidades, relaciones, cardinalidades)
- [ ] Decidir arquitectura de capas del proyecto ASP.NET

---

## FASE 1 — Base de datos SQL Server
> Objetivo: tener el script SQL completo y funcional antes de tocar el backend.

### 1.1 Diseño del modelo relacional
- [ ] Diseñar diagrama ER en papel / draw.io / dbdiagram.io
- [ ] Definir tipos de dato, restricciones NOT NULL y CHECK
- [ ] Definir índices (PK, FK, índices de búsqueda frecuente)

### 1.2 Creación de tablas
- [ ] `Categorias` (catálogo: Incidente, Requerimiento, Mejora)
- [ ] `Usuarios` (nombre, área, correo)
- [ ] `Analistas` (nombre, especialidad)
- [ ] `Solicitudes` (tabla principal + todas las FK + CHECK de prioridad/estado)
- [ ] `HistorialEstados` (bitácora de cambios)
- [ ] `AlertasSLA` (tabla de control para el Job y Power Automate)

### 1.3 Procedimientos almacenados
- [ ] `sp_CrearSolicitud` — inserta solicitud y primer registro en HistorialEstados
- [ ] `sp_CambiarEstadoSolicitud` — cambia estado, valida que "Cerrada" no retroceda, registra en historial
- [ ] `sp_ReporteSolicitudesPorAnalista` — resumen por analista en rango de fechas

### 1.4 Vistas
- [ ] `vw_SolicitudesAbiertas` — todas las no cerradas con nombres resueltos (sin IDs)
- [ ] `vw_TiempoPromedioAtencion` — horas promedio entre apertura y cierre, por categoría

### 1.5 SQL Server Agent Job
- [ ] Escribir script T-SQL del Job (identificar solicitudes Alta > 24h en estado Abierta)
- [ ] Insertar resultados en `AlertasSLA`
- [ ] Configurar horario: diario 7:00 a.m.
- [ ] Si no hay Agent disponible: documentar el script + captura de configuración

### 1.6 Datos de prueba (seed)
- [ ] Insertar 3 categorías
- [ ] Insertar 5 usuarios de prueba
- [ ] Insertar 3 analistas de prueba
- [ ] Insertar 10–15 solicitudes con diferentes estados, prioridades y fechas
- [ ] Insertar registros en HistorialEstados coherentes con las solicitudes

---

## FASE 2 — Aplicación ASP.NET Core MVC
> Objetivo: aplicación web funcional con todas las operaciones CRUD y el flujo de estados.

### 2.1 Configuración inicial del proyecto
- [ ] Crear proyecto ASP.NET Core MVC (.NET 8) en `src/GestorSolicitudesTIC/`
- [ ] Agregar paquetes NuGet: EF Core, Dapper, SQL Server provider
- [ ] Configurar `appsettings.json` con cadena de conexión
- [ ] Crear estructura de carpetas: Controllers / Models / Services / Repositories / Views

### 2.2 Capa de datos (Models / Entities)
- [ ] Clase `Solicitud` con todas las propiedades y anotaciones
- [ ] Clase `Usuario`
- [ ] Clase `Analista`
- [ ] Clase `Categoria`
- [ ] Clase `HistorialEstado`
- [ ] Clase `AlertaSLA`
- [ ] `ApplicationDbContext` (EF Core)

### 2.3 Capa de repositorios / servicios
- [ ] `ISolicitudRepository` + implementación (llama SPs via Dapper)
- [ ] `IUsuarioRepository` + implementación
- [ ] `IAnalistaRepository` + implementación
- [ ] Inyección de dependencias en `Program.cs`

### 2.4 Módulo de Solicitudes (Controller + Views)
- [ ] `SolicitudesController` con acciones: Index, Create, Edit, Details, Delete
- [ ] `Index.cshtml` — listado con filtros (estado, prioridad, fechas) + tabla Bootstrap
- [ ] `Create.cshtml` — formulario con validaciones JS
- [ ] `Edit.cshtml` — cambio de estado + asignación de analista
- [ ] `Details.cshtml` — detalle + historial de cambios de estado
- [ ] Confirmar eliminación con modal Bootstrap

### 2.5 Módulo de Usuarios (Controller + Views)
- [ ] `UsuariosController` con acciones: Index, Create, Edit, Delete
- [ ] Vistas con Bootstrap: tabla, formularios

### 2.6 Módulo de Analistas (Controller + Views)
- [ ] `AnalistasController` con acciones: Index, Create, Edit, Delete
- [ ] Vistas con Bootstrap: tabla, formularios

### 2.7 Validaciones JavaScript (obligatorias)
- [ ] Validar campos obligatorios antes de enviar formulario de creación
- [ ] Contador dinámico de caracteres restantes en campo Descripción (sin recargar página)
- [ ] Modal de confirmación Bootstrap antes de cerrar o eliminar solicitud

### 2.8 UI / UX con Bootstrap 5
- [ ] Layout principal (`_Layout.cshtml`) con navbar y sidebar
- [ ] Badges de colores para estados (Abierta=azul, En Proceso=naranja, Resuelta=verde, Cerrada=gris)
- [ ] Badges de colores para prioridad (Alta=rojo, Media=amarillo, Baja=verde)
- [ ] Tablas responsivas con Bootstrap
- [ ] Alertas (`alert-success`, `alert-danger`) para feedback de operaciones

### 2.9 Manejo de errores
- [ ] Try/catch en todos los controladores
- [ ] Mensajes de error claros al usuario (sin exponer detalles técnicos)
- [ ] Página de error personalizada

### 2.10 Calidad de código
- [ ] Nomenclatura consistente (PascalCase para clases, camelCase para variables)
- [ ] Sin lógica de negocio en las vistas
- [ ] Parámetros en consultas (prevención de SQL Injection)
- [ ] Commits frecuentes con mensajes descriptivos

---

## FASE 3 — Power Automate
> Objetivo: flujo automatizado que notifica sobre solicitudes que incumplen SLA de 24 horas.

- [ ] Crear flujo en Power Automate (Flow)
- [ ] Configurar disparador: programado diario O trigger manual/HTTP
- [ ] Agregar acción: conectar a SQL Server → consultar tabla `AlertasSLA`
- [ ] Agregar condición: si hay registros con incumplimiento
- [ ] Agregar acción de notificación (elegir disponible):
  - [ ] Opción A: Enviar correo (Outlook/Gmail connector)
  - [ ] Opción B: Mensaje en Teams
  - [ ] Opción C: Registrar en lista SharePoint
- [ ] Probar el flujo manualmente
- [ ] Exportar el flujo como paquete .zip  
  *Si no es posible exportar: capturas de cada paso + explicación*

---

## FASE 4 — Power BI
> Objetivo: tablero visual con KPIs e indicadores para toma de decisiones.

- [ ] Abrir Power BI Desktop → Obtener datos → SQL Server
- [ ] Conectar a la base de datos `GestorSolicitudesTIC`
- [ ] Importar tablas: Solicitudes, Usuarios, Analistas, Categorias, HistorialEstados
- [ ] Importar vistas: vw_SolicitudesAbiertas, vw_TiempoPromedioAtencion
- [ ] Definir relaciones en el modelo de datos (diagrama estrella)
- [ ] Crear medidas DAX:
  - [ ] `Total Solicitudes = COUNT(Solicitudes[SolicitudId])`
  - [ ] `% Cumplimiento SLA = DIVIDE([Cerradas en 24h], [Total Alta Prioridad])`
  - [ ] `Tiempo Promedio Atención = AVERAGE(vw_TiempoPromedioAtencion[PromedioHoras])`
- [ ] Construir visualizaciones:
  - [ ] Tarjeta KPI: Total solicitudes por estado
  - [ ] Gráfico de barras: Solicitudes por categoría
  - [ ] Gráfico de dona: Solicitudes por prioridad
  - [ ] Gráfico de columnas: Tiempo promedio de atención por analista
  - [ ] Tarjeta KPI: % cumplimiento SLA (prioridad alta ≤ 24h)
- [ ] Agregar slicers (filtros interactivos): por fecha, por categoría
- [ ] Revisar coherencia de datos con la BD de prueba
- [ ] Guardar como `GestorSolicitudesTIC.pbix`

---

## FASE 5 — Documentación
> Objetivo: entregar el documento de soporte requerido (1-2 páginas).

- [ ] **Acta de levantamiento de requerimientos** (como si se entrevistó al área TIC)
  - [ ] 3-4 supuestos del negocio
  - [ ] Necesidades identificadas
  - [ ] Alcance acordado
- [ ] **Diagrama ER** (imagen exportada de la BD)
- [ ] **Manual rápido de usuario**:
  - [ ] Cómo crear una solicitud (paso a paso con screenshots)
  - [ ] Cómo cambiar el estado de una solicitud
- [ ] **Supuestos y decisiones técnicas**:
  - [ ] Por qué .NET 8 vs .NET Framework
  - [ ] Por qué EF Core + Dapper
  - [ ] Por qué Bootstrap 5
  - [ ] Decisiones de diseño de BD
- [ ] Exportar a PDF → `documents/DocumentoSoporte.pdf`

---

## FASE 6 — Revisión final y entrega
> Objetivo: verificar que todo funciona y empacar los entregables.

- [ ] Prueba de extremo a extremo: crear → En Proceso → Resolver → Cerrar
- [ ] Verificar que los filtros del listado funcionan
- [ ] Verificar que el historial de cambios aparece en el detalle
- [ ] Verificar que el Job SQL inserta en AlertasSLA correctamente
- [ ] Revisar historial de Git (mínimo 10 commits distribuidos)
- [ ] Actualizar README con URL del repositorio
- [ ] Comprimir todos los archivos como alternativa de entrega
- [ ] (Opcional) Grabar video demo de 3-5 minutos

---

## Orden de desarrollo recomendado

```
Día 1: Fase 0 completa + Diseño ER + Script BD (tablas + seed)
Día 2: SPs + Vistas + Job SQL  /  Setup proyecto ASP.NET
Día 3: Capa de datos (models, repos) + Controllers básicos
Día 4: Vistas Solicitudes (listado, crear, editar, detalle)
Día 5: Módulos Usuarios y Analistas + validaciones JS
Día 6: Power Automate + Power BI
Día 7: Documento de soporte + revisión final + commits
```

---

## Criterios de evaluación (peso)

| Criterio | Peso | Prioridad de desarrollo |
|---|---|---|
| Desarrollo ASP.NET MVC | 30% | 🔴 Alta |
| Base de datos SQL Server | 25% | 🔴 Alta |
| Power Platform (Automate) | 15% | 🟡 Media |
| Power BI | 15% | 🟡 Media |
| Documentación | 10% | 🟢 Normal |
| Sustentación | 5% | 🟢 Normal |
