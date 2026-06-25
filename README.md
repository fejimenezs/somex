# Gestor de Solicitudes TIC
### Prueba Técnica — Desarrollador(a) de Software TIC

Sistema centralizado para la gestión de solicitudes de soporte técnico y funcional de la empresa **TIC Soluciones S.A.**, construido como solución integrada con ASP.NET Core MVC, SQL Server, Power Automate y Power BI.

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Backend | ASP.NET Core MVC (.NET 8) |
| ORM / Acceso a datos | Entity Framework Core + Dapper (para SPs) |
| Base de datos | SQL Server 2019+ |
| Frontend | Bootstrap 5 + JavaScript / jQuery |
| Automatización | Power Automate (Microsoft 365) |
| Reportes | Power BI Desktop |
| Control de versiones | Git / GitHub |

---

## Estructura del Repositorio

```
Somex/
├── README.md                     ← Este archivo
├── PLAN.md                       ← Plan de trabajo y checklist
├── docs/
│   └── index.html                ← Sitio web explicativo (para usuarios no técnicos)
├── database/
│   └── GestorSolicitudesTIC.sql  ← Script completo de BD (tablas, SPs, vistas, Job, seed)
├── src/
│   └── GestorSolicitudesTIC/     ← Proyecto ASP.NET Core MVC
├── powerautomate/
│   └── flujo_alertas_sla.zip     ← Paquete exportado del flujo (o capturas)
├── powerbi/
│   └── GestorSolicitudesTIC.pbix ← Tablero Power BI
└── documents/
    └── DocumentoSoporte.pdf      ← Acta de requerimientos, ER, manual de usuario
```

---

## Módulos del Sistema

### 1. Módulo de Solicitudes
- Crear solicitud (título, descripción, categoría, prioridad, usuario, área)
- Listar con filtros (estado, prioridad, rango de fechas)
- Flujo de estados: **Abierta → En Proceso → Resuelta → Cerrada**
- Asignar a analista de soporte
- Ver historial/bitácora de cambios de estado

### 2. Módulo de Usuarios y Analistas
- CRUD de usuarios solicitantes (nombre, área, correo)
- CRUD de analistas de soporte (nombre, especialidad)

### 3. Base de Datos SQL Server
- 6 tablas normalizadas + AlertasSLA
- 3 procedimientos almacenados
- 2 vistas analíticas
- SQL Server Agent Job (diario 7:00 a.m.)

### 4. Power Automate
- Flujo diario que consulta AlertasSLA y envía notificaciones de incumplimiento SLA

### 5. Power BI
- Dashboard con KPIs, gráficos por categoría/prioridad, cumplimiento SLA

---

## Cómo ejecutar el proyecto

### Prerrequisitos
- .NET 8 SDK
- SQL Server 2019+ (o SQL Server Express)
- Visual Studio 2022 o VS Code
- Power BI Desktop (para el tablero)

### Configuración

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/fejimenezs/somex.git
   cd somex
   ```

2. Crear la base de datos:
   ```sql
   -- Ejecutar en SQL Server Management Studio (SSMS):
   -- database/GestorSolicitudesTIC.sql
   ```

3. Configurar cadena de conexión en `src/GestorSolicitudesTIC/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=.;Database=GestorSolicitudesTIC;Trusted_Connection=True;"
     }
   }
   ```

4. Ejecutar la aplicación:
   ```bash
   cd src/GestorSolicitudesTIC
   dotnet run
   ```

---

## Decisiones Técnicas

- **ASP.NET Core MVC (.NET 8)**: versión LTS más reciente, mejor rendimiento y soporte multiplataforma vs .NET Framework.
- **Entity Framework Core + Dapper**: EF Core para modelos/relaciones, Dapper para llamar los procedimientos almacenados con mayor control.
- **Bootstrap 5**: sin dependencia de jQuery en los componentes UI, más moderno que Bootstrap 4.
- **Arquitectura por capas**: Controllers → Services → Repositories → Data (separación clara de responsabilidades).

---

## Autor

**Fausto Jiménez** · fejimenezs88@gmail.com  
Prueba técnica — Junio 2026
