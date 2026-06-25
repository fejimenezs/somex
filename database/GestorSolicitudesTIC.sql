-- ============================================================
-- GESTOR DE SOLICITUDES TIC
-- Base de datos SQL Server
-- Autor: Fausto Jiménez | fejimenezs88@gmail.com
-- Fecha: Junio 2026
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 0. CREAR Y USAR LA BASE DE DATOS
-- ─────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'GestorSolicitudesTIC')
    CREATE DATABASE GestorSolicitudesTIC
    COLLATE Latin1_General_CI_AI;
GO

USE GestorSolicitudesTIC;
GO

-- ─────────────────────────────────────────────────────────────
-- 1. TABLAS
-- ─────────────────────────────────────────────────────────────

-- 1.1 Categorias (catálogo)
IF OBJECT_ID('dbo.Categorias', 'U') IS NOT NULL DROP TABLE dbo.Categorias;
CREATE TABLE dbo.Categorias (
    CategoriaId   INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(50)   NOT NULL,
    Descripcion   VARCHAR(200)  NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Categorias_Nombre UNIQUE (Nombre)
);
GO

-- 1.2 Usuarios (solicitantes)
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
CREATE TABLE dbo.Usuarios (
    UsuarioId     INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(100)  NOT NULL,
    Area          VARCHAR(80)   NOT NULL,
    Correo        VARCHAR(120)  NOT NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Usuarios_Correo UNIQUE (Correo),
    CONSTRAINT CK_Usuarios_Correo CHECK (Correo LIKE '%@%.%')
);
GO

-- 1.3 Analistas (equipo TIC)
IF OBJECT_ID('dbo.Analistas', 'U') IS NOT NULL DROP TABLE dbo.Analistas;
CREATE TABLE dbo.Analistas (
    AnalistaId    INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(100)  NOT NULL,
    Especialidad  VARCHAR(80)   NOT NULL,
    Correo        VARCHAR(120)  NOT NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Analistas_Correo UNIQUE (Correo)
);
GO

-- 1.4 Solicitudes (tabla principal)
IF OBJECT_ID('dbo.HistorialEstados', 'U') IS NOT NULL DROP TABLE dbo.HistorialEstados;
IF OBJECT_ID('dbo.AlertasSLA', 'U')       IS NOT NULL DROP TABLE dbo.AlertasSLA;
IF OBJECT_ID('dbo.Solicitudes', 'U')      IS NOT NULL DROP TABLE dbo.Solicitudes;

CREATE TABLE dbo.Solicitudes (
    SolicitudId   INT            IDENTITY(1,1) PRIMARY KEY,
    Titulo        VARCHAR(150)   NOT NULL,
    Descripcion   VARCHAR(1000)  NOT NULL,
    CategoriaId   INT            NOT NULL,
    Prioridad     VARCHAR(10)    NOT NULL,
    Estado        VARCHAR(20)    NOT NULL DEFAULT 'Abierta',
    UsuarioId     INT            NOT NULL,
    AnalistaId    INT            NULL,
    FechaCreacion DATETIME       NOT NULL DEFAULT GETDATE(),
    FechaUltModif DATETIME       NOT NULL DEFAULT GETDATE(),
    FechaCierre   DATETIME       NULL,
    CONSTRAINT FK_Solicitudes_Categorias FOREIGN KEY (CategoriaId) REFERENCES dbo.Categorias(CategoriaId),
    CONSTRAINT FK_Solicitudes_Usuarios   FOREIGN KEY (UsuarioId)   REFERENCES dbo.Usuarios(UsuarioId),
    CONSTRAINT FK_Solicitudes_Analistas  FOREIGN KEY (AnalistaId)  REFERENCES dbo.Analistas(AnalistaId),
    CONSTRAINT CK_Solicitudes_Prioridad  CHECK (Prioridad IN ('Alta', 'Media', 'Baja')),
    CONSTRAINT CK_Solicitudes_Estado     CHECK (Estado IN ('Abierta', 'En Proceso', 'Resuelta', 'Cerrada'))
);
GO

-- 1.5 HistorialEstados (bitácora de cambios)
CREATE TABLE dbo.HistorialEstados (
    HistorialId     INT          IDENTITY(1,1) PRIMARY KEY,
    SolicitudId     INT          NOT NULL,
    EstadoAnterior  VARCHAR(20)  NULL,
    EstadoNuevo     VARCHAR(20)  NOT NULL,
    Observacion     VARCHAR(500) NULL,
    FechaCambio     DATETIME     NOT NULL DEFAULT GETDATE(),
    UsuarioCambio   VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    CONSTRAINT FK_Historial_Solicitudes FOREIGN KEY (SolicitudId) REFERENCES dbo.Solicitudes(SolicitudId)
);
GO

-- 1.6 AlertasSLA (control para Power Automate)
CREATE TABLE dbo.AlertasSLA (
    AlertaId        INT          IDENTITY(1,1) PRIMARY KEY,
    SolicitudId     INT          NOT NULL,
    Titulo          VARCHAR(150) NOT NULL,
    UsuarioNombre   VARCHAR(100) NOT NULL,
    AnalistaNombre  VARCHAR(100) NULL,
    HorasTranscurr  DECIMAL(6,2) NOT NULL,
    FechaDeteccion  DATETIME     NOT NULL DEFAULT GETDATE(),
    Notificado      BIT          NOT NULL DEFAULT 0,
    CONSTRAINT FK_AlertasSLA_Solicitudes FOREIGN KEY (SolicitudId) REFERENCES dbo.Solicitudes(SolicitudId)
);
GO

-- ─────────────────────────────────────────────────────────────
-- 2. ÍNDICES (performance en filtros frecuentes)
-- ─────────────────────────────────────────────────────────────
CREATE NONCLUSTERED INDEX IX_Solicitudes_Estado
    ON dbo.Solicitudes (Estado) INCLUDE (SolicitudId, Prioridad, FechaCreacion);

CREATE NONCLUSTERED INDEX IX_Solicitudes_Prioridad_Estado
    ON dbo.Solicitudes (Prioridad, Estado) INCLUDE (SolicitudId, FechaCreacion, AnalistaId);

CREATE NONCLUSTERED INDEX IX_Solicitudes_UsuarioId
    ON dbo.Solicitudes (UsuarioId);

CREATE NONCLUSTERED INDEX IX_Solicitudes_AnalistaId
    ON dbo.Solicitudes (AnalistaId);

CREATE NONCLUSTERED INDEX IX_HistorialEstados_SolicitudId
    ON dbo.HistorialEstados (SolicitudId, FechaCambio);

CREATE NONCLUSTERED INDEX IX_AlertasSLA_Notificado
    ON dbo.AlertasSLA (Notificado, FechaDeteccion);
GO

-- ─────────────────────────────────────────────────────────────
-- 3. PROCEDIMIENTOS ALMACENADOS
-- ─────────────────────────────────────────────────────────────

-- 3.1 sp_CrearSolicitud
-- Crea una solicitud y registra el primer estado en HistorialEstados.
CREATE OR ALTER PROCEDURE dbo.sp_CrearSolicitud
    @Titulo       VARCHAR(150),
    @Descripcion  VARCHAR(1000),
    @CategoriaId  INT,
    @Prioridad    VARCHAR(10),
    @UsuarioId    INT,
    @AnalistaId   INT = NULL,
    @SolicitudId  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Titulo IS NULL OR LEN(LTRIM(RTRIM(@Titulo))) = 0
        THROW 50001, 'El título es obligatorio.', 1;

    IF @Prioridad NOT IN ('Alta', 'Media', 'Baja')
        THROW 50002, 'Prioridad inválida. Use: Alta, Media o Baja.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE UsuarioId = @UsuarioId AND Activo = 1)
        THROW 50003, 'El usuario solicitante no existe o está inactivo.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Categorias WHERE CategoriaId = @CategoriaId AND Activo = 1)
        THROW 50004, 'La categoría no existe o está inactiva.', 1;

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO dbo.Solicitudes (Titulo, Descripcion, CategoriaId, Prioridad, Estado, UsuarioId, AnalistaId)
        VALUES (@Titulo, @Descripcion, @CategoriaId, @Prioridad, 'Abierta', @UsuarioId, @AnalistaId);

        SET @SolicitudId = SCOPE_IDENTITY();

        INSERT INTO dbo.HistorialEstados (SolicitudId, EstadoAnterior, EstadoNuevo, Observacion)
        VALUES (@SolicitudId, NULL, 'Abierta', 'Solicitud creada.');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 3.2 sp_CambiarEstadoSolicitud
-- Cambia el estado de una solicitud. Valida que "Cerrada" no retroceda.
-- Flujo permitido: Abierta → En Proceso → Resuelta → Cerrada
CREATE OR ALTER PROCEDURE dbo.sp_CambiarEstadoSolicitud
    @SolicitudId   INT,
    @EstadoNuevo   VARCHAR(20),
    @Observacion   VARCHAR(500) = NULL,
    @AnalistaId    INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstadoActual VARCHAR(20);
    DECLARE @FechaCierre  DATETIME = NULL;

    SELECT @EstadoActual = Estado
    FROM dbo.Solicitudes
    WHERE SolicitudId = @SolicitudId;

    IF @EstadoActual IS NULL
        THROW 50010, 'La solicitud no existe.', 1;

    IF @EstadoActual = 'Cerrada'
        THROW 50011, 'Una solicitud cerrada no puede cambiar de estado.', 1;

    IF @EstadoNuevo NOT IN ('Abierta', 'En Proceso', 'Resuelta', 'Cerrada')
        THROW 50012, 'Estado inválido. Use: Abierta, En Proceso, Resuelta o Cerrada.', 1;

    -- Validar flujo hacia atrás (no permitir regresar a estados anteriores)
    IF (@EstadoActual = 'Resuelta'  AND @EstadoNuevo = 'Abierta')   THROW 50013, 'No se puede retroceder de Resuelta a Abierta.', 1;
    IF (@EstadoActual = 'En Proceso' AND @EstadoNuevo = 'Abierta')  THROW 50013, 'No se puede retroceder de En Proceso a Abierta.', 1;

    IF @EstadoNuevo = 'Cerrada'
        SET @FechaCierre = GETDATE();

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE dbo.Solicitudes
        SET Estado        = @EstadoNuevo,
            FechaUltModif = GETDATE(),
            FechaCierre   = ISNULL(@FechaCierre, FechaCierre),
            AnalistaId    = ISNULL(@AnalistaId, AnalistaId)
        WHERE SolicitudId = @SolicitudId;

        INSERT INTO dbo.HistorialEstados (SolicitudId, EstadoAnterior, EstadoNuevo, Observacion)
        VALUES (@SolicitudId, @EstadoActual, @EstadoNuevo, @Observacion);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 3.3 sp_ReporteSolicitudesPorAnalista
-- Solicitudes atendidas por analista en un rango de fechas.
CREATE OR ALTER PROCEDURE dbo.sp_ReporteSolicitudesPorAnalista
    @FechaInicio DATETIME,
    @FechaFin    DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaInicio > @FechaFin
        THROW 50020, 'La fecha de inicio no puede ser posterior a la fecha fin.', 1;

    SELECT
        a.AnalistaId,
        a.Nombre                                           AS Analista,
        a.Especialidad,
        COUNT(s.SolicitudId)                               AS TotalSolicitudes,
        SUM(CASE WHEN s.Estado = 'Cerrada'  THEN 1 ELSE 0 END) AS Cerradas,
        SUM(CASE WHEN s.Estado = 'Resuelta' THEN 1 ELSE 0 END) AS Resueltas,
        SUM(CASE WHEN s.Estado IN ('Abierta','En Proceso') THEN 1 ELSE 0 END) AS EnCurso,
        AVG(CASE
                WHEN s.FechaCierre IS NOT NULL
                THEN CAST(DATEDIFF(MINUTE, s.FechaCreacion, s.FechaCierre) AS DECIMAL(10,2)) / 60
            END)                                            AS PromedioHorasAtencion
    FROM dbo.Analistas a
    INNER JOIN dbo.Solicitudes s
        ON s.AnalistaId = a.AnalistaId
       AND s.FechaCreacion BETWEEN @FechaInicio AND @FechaFin
    GROUP BY a.AnalistaId, a.Nombre, a.Especialidad
    ORDER BY TotalSolicitudes DESC;
END;
GO

-- ─────────────────────────────────────────────────────────────
-- 4. VISTAS
-- ─────────────────────────────────────────────────────────────

-- 4.1 vw_SolicitudesAbiertas
-- Todas las no cerradas con nombres resueltos (sin IDs desnudos).
CREATE OR ALTER VIEW dbo.vw_SolicitudesAbiertas AS
SELECT
    s.SolicitudId,
    s.Titulo,
    s.Descripcion,
    c.Nombre        AS Categoria,
    s.Prioridad,
    s.Estado,
    u.Nombre        AS UsuarioSolicitante,
    u.Area          AS AreaSolicitante,
    u.Correo        AS CorreoUsuario,
    a.Nombre        AS AnalistaAsignado,
    a.Especialidad  AS EspecialidadAnalista,
    s.FechaCreacion,
    s.FechaUltModif,
    DATEDIFF(HOUR, s.FechaCreacion, GETDATE()) AS HorasTranscurridas
FROM dbo.Solicitudes s
INNER JOIN dbo.Categorias c ON c.CategoriaId = s.CategoriaId
INNER JOIN dbo.Usuarios   u ON u.UsuarioId   = s.UsuarioId
LEFT  JOIN dbo.Analistas  a ON a.AnalistaId  = s.AnalistaId
WHERE s.Estado <> 'Cerrada';
GO

-- 4.2 vw_TiempoPromedioAtencion
-- Tiempo promedio (en horas) entre apertura y cierre, agrupado por categoría.
CREATE OR ALTER VIEW dbo.vw_TiempoPromedioAtencion AS
SELECT
    c.CategoriaId,
    c.Nombre                                                               AS Categoria,
    COUNT(s.SolicitudId)                                                   AS TotalCerradas,
    AVG(CAST(DATEDIFF(MINUTE, s.FechaCreacion, s.FechaCierre) AS DECIMAL(10,2)) / 60) AS PromedioHoras,
    MIN(CAST(DATEDIFF(MINUTE, s.FechaCreacion, s.FechaCierre) AS DECIMAL(10,2)) / 60) AS MinHoras,
    MAX(CAST(DATEDIFF(MINUTE, s.FechaCreacion, s.FechaCierre) AS DECIMAL(10,2)) / 60) AS MaxHoras
FROM dbo.Solicitudes s
INNER JOIN dbo.Categorias c ON c.CategoriaId = s.CategoriaId
WHERE s.Estado = 'Cerrada'
  AND s.FechaCierre IS NOT NULL
GROUP BY c.CategoriaId, c.Nombre;
GO

-- ─────────────────────────────────────────────────────────────
-- 5. SQL SERVER AGENT JOB (script T-SQL)
-- Detecta solicitudes Alta >24h en estado Abierta e inserta en AlertasSLA
-- Frecuencia: diaria a las 7:00 a.m.
-- Si no hay SQL Server Agent, ejecutar este bloque manualmente o con un SP programado.
-- ─────────────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_JobAlertasSLA
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpiar alertas del día anterior (se regeneran cada ejecución)
    DELETE FROM dbo.AlertasSLA
    WHERE CAST(FechaDeteccion AS DATE) < CAST(GETDATE() AS DATE);

    -- Insertar nuevas alertas: prioridad Alta, estado Abierta, más de 24h
    INSERT INTO dbo.AlertasSLA (SolicitudId, Titulo, UsuarioNombre, AnalistaNombre, HorasTranscurr)
    SELECT
        s.SolicitudId,
        s.Titulo,
        u.Nombre                                                AS UsuarioNombre,
        ISNULL(a.Nombre, 'Sin asignar')                        AS AnalistaNombre,
        CAST(DATEDIFF(MINUTE, s.FechaCreacion, GETDATE()) AS DECIMAL(6,2)) / 60 AS HorasTranscurr
    FROM dbo.Solicitudes s
    INNER JOIN dbo.Usuarios  u ON u.UsuarioId  = s.UsuarioId
    LEFT  JOIN dbo.Analistas a ON a.AnalistaId = s.AnalistaId
    WHERE s.Prioridad = 'Alta'
      AND s.Estado    = 'Abierta'
      AND DATEDIFF(HOUR, s.FechaCreacion, GETDATE()) > 24
      -- Evitar insertar duplicados del mismo día
      AND s.SolicitudId NOT IN (
          SELECT SolicitudId FROM dbo.AlertasSLA
          WHERE CAST(FechaDeteccion AS DATE) = CAST(GETDATE() AS DATE)
      );
END;
GO

-- Script de configuración del SQL Server Agent Job:
-- Ejecutar en SSMS con permisos de sysadmin.
/*
USE msdb;
GO

EXEC sp_add_job
    @job_name = N'GestorTIC - Alertas SLA Diarias';

EXEC sp_add_jobstep
    @job_name   = N'GestorTIC - Alertas SLA Diarias',
    @step_name  = N'Detectar incumplimientos SLA',
    @subsystem  = N'TSQL',
    @command    = N'EXEC GestorSolicitudesTIC.dbo.sp_JobAlertasSLA;',
    @database_name = N'GestorSolicitudesTIC';

EXEC sp_add_schedule
    @schedule_name    = N'Diario 7am',
    @freq_type        = 4,     -- Diario
    @freq_interval    = 1,
    @active_start_time = 070000; -- 07:00:00

EXEC sp_attach_schedule
    @job_name      = N'GestorTIC - Alertas SLA Diarias',
    @schedule_name = N'Diario 7am';

EXEC sp_add_jobserver
    @job_name = N'GestorTIC - Alertas SLA Diarias';
GO
*/

-- ─────────────────────────────────────────────────────────────
-- 6. DATOS DE PRUEBA (SEED)
-- ─────────────────────────────────────────────────────────────

-- 6.1 Categorías
SET IDENTITY_INSERT dbo.Categorias ON;
INSERT INTO dbo.Categorias (CategoriaId, Nombre, Descripcion) VALUES
(1, 'Incidente',     'Fallo o interrupción inesperada de un servicio o aplicación.'),
(2, 'Requerimiento', 'Solicitud de nuevo servicio, acceso o funcionalidad.'),
(3, 'Mejora',        'Sugerencia de optimización sobre un proceso o herramienta existente.');
SET IDENTITY_INSERT dbo.Categorias OFF;

-- 6.2 Usuarios
SET IDENTITY_INSERT dbo.Usuarios ON;
INSERT INTO dbo.Usuarios (UsuarioId, Nombre, Area, Correo) VALUES
(1, 'María Rodríguez',  'Contabilidad',    'mrodriguez@ticsoluciones.co'),
(2, 'Carlos Gómez',     'Recursos Humanos','cgomez@ticsoluciones.co'),
(3, 'Laura Martínez',   'Ventas',          'lmartinez@ticsoluciones.co'),
(4, 'Andrés Vargas',    'Logística',       'avargas@ticsoluciones.co'),
(5, 'Patricia Jiménez', 'Gerencia',        'pjimenez@ticsoluciones.co');
SET IDENTITY_INSERT dbo.Usuarios OFF;

-- 6.3 Analistas
SET IDENTITY_INSERT dbo.Analistas ON;
INSERT INTO dbo.Analistas (AnalistaId, Nombre, Especialidad, Correo) VALUES
(1, 'Juan Pérez',    'Infraestructura y redes',  'jperez.tic@ticsoluciones.co'),
(2, 'Ana Torres',    'Desarrollo y aplicaciones', 'atorres.tic@ticsoluciones.co'),
(3, 'Luis Herrera',  'Soporte a usuarios',        'lherrera.tic@ticsoluciones.co');
SET IDENTITY_INSERT dbo.Analistas OFF;

-- 6.4 Solicitudes
SET IDENTITY_INSERT dbo.Solicitudes ON;
INSERT INTO dbo.Solicitudes
    (SolicitudId, Titulo, Descripcion, CategoriaId, Prioridad, Estado, UsuarioId, AnalistaId, FechaCreacion, FechaCierre)
VALUES
-- Cerradas (para que las vistas y KPIs tengan datos)
(1,  'Fallo de acceso al ERP',
     'No puedo iniciar sesión en el sistema ERP desde ayer en la mañana. El error dice "credenciales inválidas" aunque la clave es correcta.',
     1, 'Alta', 'Cerrada', 1, 2, DATEADD(DAY,-10,GETDATE()), DATEADD(DAY,-9,GETDATE())),

(2,  'Lentitud extrema en portal de nómina',
     'El portal tarda más de 5 minutos en cargar los recibos de pago. Afecta a todo el departamento de RRHH.',
     1, 'Alta', 'Cerrada', 2, 1, DATEADD(DAY,-8,GETDATE()), DATEADD(DAY,-7,GETDATE())),

(3,  'Solicitud de acceso a carpeta compartida',
     'Necesito acceso de lectura a la carpeta \\server01\Ventas\Proyectos para revisar las cotizaciones del mes.',
     2, 'Media', 'Cerrada', 3, 3, DATEADD(DAY,-6,GETDATE()), DATEADD(DAY,-5,GETDATE())),

(4,  'Impresora de logística no funciona',
     'La impresora HP del área de despachos no imprime desde el viernes. Muestra error de cola de impresión.',
     1, 'Media', 'Cerrada', 4, 3, DATEADD(DAY,-5,GETDATE()), DATEADD(DAY,-4,GETDATE())),

(5,  'Agregar campo de centro de costo en reporte',
     'El reporte mensual de contabilidad no incluye el centro de costo. Se necesita en la próxima versión del mes.',
     3, 'Baja', 'Cerrada', 1, 2, DATEADD(DAY,-15,GETDATE()), DATEADD(DAY,-10,GETDATE())),

-- Resueltas
(6,  'Correo corporativo no sincroniza en celular',
     'El correo de Outlook no llega al celular Android desde el lunes. Solo funciona en el computador.',
     1, 'Media', 'Resuelta', 2, 3, DATEADD(DAY,-3,GETDATE()), NULL),

(7,  'Crear usuario nuevo en el sistema de ventas',
     'Ingresó una nueva asesora comercial, Natalia Cruz. Necesita usuario y clave en el CRM de ventas.',
     2, 'Media', 'Resuelta', 3, 2, DATEADD(DAY,-2,GETDATE()), NULL),

-- En Proceso
(8,  'Error al exportar reportes en PDF',
     'Al intentar exportar cualquier reporte a PDF desde el módulo de gerencia, el sistema arroja un error 500.',
     1, 'Alta', 'En Proceso', 5, 2, DATEADD(DAY,-1,GETDATE()), NULL),

(9,  'Mejora en el módulo de logística',
     'Sería útil tener un filtro por fecha de despacho en el listado de órdenes. Actualmente solo se puede filtrar por estado.',
     3, 'Baja', 'En Proceso', 4, 2, DATEADD(HOUR,-5,GETDATE()), NULL),

-- Abiertas (algunas con más de 24h para activar alertas SLA)
(10, 'Sistema ERP caído en sede Norte',
     'Todos los usuarios de la sede Norte no pueden acceder al ERP desde las 7am. Impacto crítico en operación.',
     1, 'Alta', 'Abierta', 4, NULL, DATEADD(HOUR,-30,GETDATE()), NULL),

(11, 'Solicitud de licencia de software AutoCAD',
     'El área de proyectos requiere 2 licencias adicionales de AutoCAD para contratistas que empiezan la próxima semana.',
     2, 'Alta', 'Abierta', 5, NULL, DATEADD(HOUR,-26,GETDATE()), NULL),

(12, 'Capacitación en herramienta Power BI',
     'Se requiere una capacitación básica de Power BI para el equipo de contabilidad (6 personas).',
     2, 'Media', 'Abierta', 1, 2, DATEADD(HOUR,-4,GETDATE()), NULL),

(13, 'Actualizar versión de antivirus',
     'Las estaciones del área de ventas tienen el antivirus desactualizado (versión 2022). Riesgo de seguridad.',
     2, 'Alta', 'Abierta', 3, 1, DATEADD(HOUR,-2,GETDATE()), NULL),

(14, 'Optimizar consultas lentas en módulo de inventario',
     'Las búsquedas en el módulo de inventario tardan más de 10 segundos cuando hay más de 1000 registros.',
     3, 'Media', 'Abierta', 4, 2, DATEADD(HOUR,-1,GETDATE()), NULL);
SET IDENTITY_INSERT dbo.Solicitudes OFF;

-- 6.5 HistorialEstados (coherente con las solicitudes anteriores)
SET IDENTITY_INSERT dbo.HistorialEstados ON;
INSERT INTO dbo.HistorialEstados (HistorialId, SolicitudId, EstadoAnterior, EstadoNuevo, Observacion, FechaCambio) VALUES
-- Solicitud 1 (Cerrada)
(1,  1, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-10,GETDATE())),
(2,  1, 'Abierta',    'En Proceso', 'Revisando configuración de Active Directory.',           DATEADD(HOUR,-9*24+2,GETDATE())),
(3,  1, 'En Proceso', 'Resuelta',   'Se restableció la contraseña y se sincronizó el AD.',   DATEADD(HOUR,-9*24+5,GETDATE())),
(4,  1, 'Resuelta',   'Cerrada',    'Usuario confirmó acceso exitoso.',                       DATEADD(DAY,-9,GETDATE())),
-- Solicitud 2 (Cerrada)
(5,  2, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-8,GETDATE())),
(6,  2, 'Abierta',    'En Proceso', 'Revisando logs del servidor de aplicaciones.',           DATEADD(HOUR,-7*24+3,GETDATE())),
(7,  2, 'En Proceso', 'Resuelta',   'Se optimizó la consulta SQL del módulo de nómina.',     DATEADD(HOUR,-7*24+6,GETDATE())),
(8,  2, 'Resuelta',   'Cerrada',    'Confirmado por jefe de RRHH. Tiempo de carga: 8s.',     DATEADD(DAY,-7,GETDATE())),
-- Solicitud 3 (Cerrada)
(9,  3, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-6,GETDATE())),
(10, 3, 'Abierta',    'En Proceso', 'Verificando con jefe de área la autorización.',         DATEADD(HOUR,-5*24+1,GETDATE())),
(11, 3, 'En Proceso', 'Cerrada',    'Acceso otorgado. Se notificó al usuario.',              DATEADD(DAY,-5,GETDATE())),
-- Solicitud 4 (Cerrada)
(12, 4, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-5,GETDATE())),
(13, 4, 'Abierta',    'En Proceso', 'Se fue a revisar la impresora físicamente.',            DATEADD(HOUR,-4*24+2,GETDATE())),
(14, 4, 'En Proceso', 'Cerrada',    'Cola limpiada y driver reinstalado. Imprime OK.',       DATEADD(DAY,-4,GETDATE())),
-- Solicitud 5 (Cerrada)
(15, 5, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-15,GETDATE())),
(16, 5, 'Abierta',    'En Proceso', 'Analizando reporte actual para diseñar el cambio.',     DATEADD(DAY,-13,GETDATE())),
(17, 5, 'En Proceso', 'Resuelta',   'Campo de centro de costo agregado al reporte.',         DATEADD(DAY,-11,GETDATE())),
(18, 5, 'Resuelta',   'Cerrada',    'Aprobado por jefe de contabilidad.',                    DATEADD(DAY,-10,GETDATE())),
-- Solicitud 6 (Resuelta)
(19, 6, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-3,GETDATE())),
(20, 6, 'Abierta',    'En Proceso', 'Revisando configuración Exchange ActiveSync.',          DATEADD(HOUR,-2*24+3,GETDATE())),
(21, 6, 'En Proceso', 'Resuelta',   'Se reconfiguró el perfil del dispositivo móvil.',       DATEADD(HOUR,-1*24+2,GETDATE())),
-- Solicitud 7 (Resuelta)
(22, 7, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-2,GETDATE())),
(23, 7, 'Abierta',    'En Proceso', 'Creando usuario en CRM con permisos de asesora.',       DATEADD(HOUR,-1*24+2,GETDATE())),
(24, 7, 'En Proceso', 'Resuelta',   'Usuario creado. Credenciales enviadas por correo.',     DATEADD(HOUR,-1*24+5,GETDATE())),
-- Solicitud 8 (En Proceso)
(25, 8, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(DAY,-1,GETDATE())),
(26, 8, 'Abierta',    'En Proceso', 'Revisando logs del servidor de reportes.',              DATEADD(HOUR,-18,GETDATE())),
-- Solicitud 9 (En Proceso)
(27, 9, NULL,         'Abierta',    'Solicitud creada.',                                     DATEADD(HOUR,-5,GETDATE())),
(28, 9, 'Abierta',    'En Proceso', 'Analizando viabilidad del filtro solicitado.',          DATEADD(HOUR,-3,GETDATE())),
-- Solicitudes 10-14 (Abiertas, solo primer registro)
(29, 10, NULL, 'Abierta', 'Solicitud creada. URGENTE: impacto en operación.',               DATEADD(HOUR,-30,GETDATE())),
(30, 11, NULL, 'Abierta', 'Solicitud creada.',                                              DATEADD(HOUR,-26,GETDATE())),
(31, 12, NULL, 'Abierta', 'Solicitud creada.',                                              DATEADD(HOUR,-4,GETDATE())),
(32, 13, NULL, 'Abierta', 'Solicitud creada.',                                              DATEADD(HOUR,-2,GETDATE())),
(33, 14, NULL, 'Abierta', 'Solicitud creada.',                                              DATEADD(HOUR,-1,GETDATE()));
SET IDENTITY_INSERT dbo.HistorialEstados OFF;
GO

-- Semilla inicial de AlertasSLA (solicitudes 10 y 11 ya llevan >24h en Alta+Abierta)
EXEC dbo.sp_JobAlertasSLA;
GO

-- ─────────────────────────────────────────────────────────────
-- 7. VERIFICACIÓN
-- ─────────────────────────────────────────────────────────────
SELECT 'Categorias'     AS Tabla, COUNT(*) AS Registros FROM dbo.Categorias     UNION ALL
SELECT 'Usuarios',                COUNT(*)               FROM dbo.Usuarios       UNION ALL
SELECT 'Analistas',               COUNT(*)               FROM dbo.Analistas      UNION ALL
SELECT 'Solicitudes',             COUNT(*)               FROM dbo.Solicitudes    UNION ALL
SELECT 'HistorialEstados',        COUNT(*)               FROM dbo.HistorialEstados UNION ALL
SELECT 'AlertasSLA',              COUNT(*)               FROM dbo.AlertasSLA;

SELECT * FROM dbo.vw_SolicitudesAbiertas     ORDER BY Prioridad, FechaCreacion;
SELECT * FROM dbo.vw_TiempoPromedioAtencion  ORDER BY PromedioHoras DESC;

EXEC dbo.sp_ReporteSolicitudesPorAnalista
    @FechaInicio = DATEADD(MONTH, -1, GETDATE()),
    @FechaFin    = GETDATE();
GO
