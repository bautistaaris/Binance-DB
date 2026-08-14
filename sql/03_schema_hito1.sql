-- =============================================================================
-- Binance_DB · Esquema del Hito 1 — Wallet Digital con Trading
-- Materia: Ingeniería de Datos I · UADE · Grupo 11
--
-- Implementa las 17 entidades relevadas en el Hito 1, con:
--   * Claves primarias y foráneas para representar las relaciones del dominio.
--   * ENUM del relevamiento modelados como VARCHAR + CHECK (SQL Server no
--     tiene el tipo ENUM nativo; el CHECK es el equivalente estándar).
--   * DECIMAL(18,2) para dinero fiat y DECIMAL(18,8) para criptomonedas.
--   * Índices justificados por las preguntas de negocio de la Clase 2.
--
-- El script es idempotente: se puede re-ejecutar sin duplicar objetos.
-- =============================================================================

USE Binance_DB;
GO

-- =============================================================================
-- 1) DOMINIO: IDENTIDAD Y USUARIOS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ENTIDAD 1 · Usuario
-- Persona física registrada en la plataforma.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
GO

CREATE TABLE dbo.Usuarios (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Usuarios PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    nombre_completo VARCHAR(150) NOT NULL,
    fecha_registro DATE NOT NULL,
    pais VARCHAR(50) NOT NULL,
    estado_verificacion VARCHAR(20) NOT NULL
        CONSTRAINT DF_Usuarios_EstadoVerificacion DEFAULT ('no_verificado'),
    documento_identidad VARCHAR(20) NULL,
    tipo_documento VARCHAR(10) NULL,
    saldo_total_usd DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Usuarios_SaldoTotal DEFAULT (0),
    CONSTRAINT CK_Usuarios_EstadoVerificacion
        CHECK (estado_verificacion IN ('no_verificado', 'verificado', 'premium')),
    CONSTRAINT CK_Usuarios_TipoDocumento
        CHECK (tipo_documento IN ('DNI', 'pasaporte') OR tipo_documento IS NULL)
);
GO

-- Pregunta de negocio (Clase 2): "¿Existe una cuenta para este correo?"
-- El email es la clave de negocio del login: debe ser única y buscable.
CREATE UNIQUE INDEX UX_Usuarios_Email ON dbo.Usuarios (email);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 13 · Verificación KYC
-- Proceso y documentación que certifica la identidad real del usuario.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.VerificacionesKYC', 'U') IS NOT NULL DROP TABLE dbo.VerificacionesKYC;
GO

CREATE TABLE dbo.VerificacionesKYC (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_VerificacionesKYC PRIMARY KEY,
    usuario_id INT NOT NULL,
    nivel VARCHAR(20) NOT NULL
        CONSTRAINT DF_VerificacionesKYC_Nivel DEFAULT ('basico'),
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    documento_url VARCHAR(255) NULL,
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_VerificacionesKYC_Estado DEFAULT ('pendiente'),
    fecha_verificacion DATE NULL,
    CONSTRAINT FK_VerificacionesKYC_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT CK_VerificacionesKYC_Nivel
        CHECK (nivel IN ('basico', 'intermedio', 'avanzado')),
    CONSTRAINT CK_VerificacionesKYC_TipoDocumento
        CHECK (tipo_documento IN ('DNI', 'pasaporte')),
    CONSTRAINT CK_VerificacionesKYC_Estado
        CHECK (estado IN ('pendiente', 'aprobado', 'rechazado'))
);
GO

-- Un usuario tiene un único proceso KYC vigente.
CREATE UNIQUE INDEX UX_VerificacionesKYC_Usuario ON dbo.VerificacionesKYC (usuario_id);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 16 · Rol y Permiso
-- Define qué puede hacer cada tipo de usuario interno (admin, soporte, etc.).
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.RolesPermisos', 'U') IS NOT NULL DROP TABLE dbo.RolesPermisos;
GO

CREATE TABLE dbo.RolesPermisos (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_RolesPermisos PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL,
    permiso VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activo BIT NOT NULL
        CONSTRAINT DF_RolesPermisos_Activo DEFAULT (1),
    CONSTRAINT CK_RolesPermisos_NombreRol
        CHECK (nombre_rol IN ('admin', 'soporte', 'compliance', 'auditor'))
);
GO

-- Una misma combinación rol-permiso no puede repetirse.
CREATE UNIQUE INDEX UX_RolesPermisos_Rol_Permiso ON dbo.RolesPermisos (nombre_rol, permiso);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 17 · Sesión de Usuario
-- Registro de cada inicio de sesión (dispositivo, IP, horario).
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.SesionesUsuario', 'U') IS NOT NULL DROP TABLE dbo.SesionesUsuario;
GO

CREATE TABLE dbo.SesionesUsuario (
    id BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_SesionesUsuario PRIMARY KEY,
    usuario_id INT NOT NULL,
    dispositivo VARCHAR(100) NOT NULL,
    ip_origen VARCHAR(45) NOT NULL,
    fecha_inicio DATETIME2(0) NOT NULL
        CONSTRAINT DF_SesionesUsuario_FechaInicio DEFAULT (SYSDATETIME()),
    fecha_fin DATETIME2(0) NULL,
    CONSTRAINT FK_SesionesUsuario_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id)
);
GO

-- Pregunta de negocio: "¿Historial de accesos de este usuario?"
CREATE INDEX IX_SesionesUsuario_Usuario_Fecha
    ON dbo.SesionesUsuario (usuario_id, fecha_inicio DESC);
GO

-- =============================================================================
-- 2) DOMINIO: CUSTODIA DE FONDOS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ENTIDAD 5 · Criptomoneda
-- Catálogo maestro de activos digitales soportados por la plataforma.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Criptomonedas', 'U') IS NOT NULL DROP TABLE dbo.Criptomonedas;
GO

CREATE TABLE dbo.Criptomonedas (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Criptomonedas PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    decimales INT NOT NULL,
    red_blockchain VARCHAR(50) NOT NULL,
    activa_para_trading BIT NOT NULL
        CONSTRAINT DF_Criptomonedas_ActivaParaTrading DEFAULT (1)
);
GO

-- El código (BTC, ETH, USDT...) es único y es la clave de negocio del catálogo.
CREATE UNIQUE INDEX UX_Criptomonedas_Codigo ON dbo.Criptomonedas (codigo);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 2 · Wallet
-- Cartera digital que contiene el saldo de una criptomoneda para un usuario.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Wallets', 'U') IS NOT NULL DROP TABLE dbo.Wallets;
GO

CREATE TABLE dbo.Wallets (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Wallets PRIMARY KEY,
    usuario_id INT NOT NULL,
    -- El Hito 1 relevó "criptomoneda" como código; se normaliza a la FK del
    -- catálogo Criptomonedas para garantizar integridad referencial.
    criptomoneda_id INT NOT NULL,
    saldo DECIMAL(18,8) NOT NULL
        CONSTRAINT DF_Wallets_Saldo DEFAULT (0),
    fecha_creacion DATE NOT NULL
        CONSTRAINT DF_Wallets_FechaCreacion DEFAULT (CAST(SYSDATETIME() AS DATE)),
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Wallets_Estado DEFAULT ('activa'),
    direccion_publica VARCHAR(100) NULL,
    CONSTRAINT FK_Wallets_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT FK_Wallets_Criptomoneda
        FOREIGN KEY (criptomoneda_id) REFERENCES dbo.Criptomonedas (id),
    CONSTRAINT CK_Wallets_Estado
        CHECK (estado IN ('activa', 'congelada', 'cerrada'))
);
GO

-- Pregunta de negocio (Clase 2): "¿Qué saldos tiene Juan para cada cripto?"
-- Una wallet por (usuario, criptomoneda): sin duplicados y acceso directo.
CREATE UNIQUE INDEX UX_Wallets_Usuario_Cripto
    ON dbo.Wallets (usuario_id, criptomoneda_id);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 3 · Transacción
-- Movimiento de criptomonedas entre dos wallets (o depósito/retiro externo).
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Transacciones', 'U') IS NOT NULL DROP TABLE dbo.Transacciones;
GO

CREATE TABLE dbo.Transacciones (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Transacciones PRIMARY KEY,
    wallet_origen_id INT NULL,
    wallet_destino_id INT NOT NULL,
    cantidad DECIMAL(18,8) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL
        CONSTRAINT DF_Transacciones_FechaHora DEFAULT (SYSDATETIME()),
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_Transacciones_Estado DEFAULT ('pendiente'),
    hash_transaccion VARCHAR(100) NULL,
    CONSTRAINT FK_Transacciones_WalletOrigen
        FOREIGN KEY (wallet_origen_id) REFERENCES dbo.Wallets (id),
    CONSTRAINT FK_Transacciones_WalletDestino
        FOREIGN KEY (wallet_destino_id) REFERENCES dbo.Wallets (id),
    CONSTRAINT CK_Transacciones_Estado
        CHECK (estado IN ('pendiente', 'completada', 'fallida'))
);
GO

-- Pregunta de negocio (Clase 2): "Mostrá mis movimientos recientes."
-- Un índice compuesto por wallet y fecha evita recorrer el historial completo.
CREATE INDEX IX_Transacciones_WalletOrigen_Fecha
    ON dbo.Transacciones (wallet_origen_id, fecha_hora DESC);
GO

CREATE INDEX IX_Transacciones_WalletDestino_Fecha
    ON dbo.Transacciones (wallet_destino_id, fecha_hora DESC);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 7 · Cuenta Bancaria
-- Cuenta bancaria externa vinculada para depósitos y retiros fiat.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.CuentasBancarias', 'U') IS NOT NULL DROP TABLE dbo.CuentasBancarias;
GO

CREATE TABLE dbo.CuentasBancarias (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_CuentasBancarias PRIMARY KEY,
    usuario_id INT NOT NULL,
    banco VARCHAR(100) NOT NULL,
    cbu_iban VARCHAR(34) NOT NULL,
    titular VARCHAR(150) NOT NULL,
    verificada BIT NOT NULL
        CONSTRAINT DF_CuentasBancarias_Verificada DEFAULT (0),
    CONSTRAINT FK_CuentasBancarias_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id)
);
GO

-- El CBU/IBAN identifica de forma única una cuenta bancaria.
CREATE UNIQUE INDEX UX_CuentasBancarias_CbuIban ON dbo.CuentasBancarias (cbu_iban);
GO

CREATE INDEX IX_CuentasBancarias_Usuario ON dbo.CuentasBancarias (usuario_id);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 8 · Método de Pago
-- Medio habilitado por el usuario para depositar fondos.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.MetodosPago', 'U') IS NOT NULL DROP TABLE dbo.MetodosPago;
GO

CREATE TABLE dbo.MetodosPago (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_MetodosPago PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    proveedor VARCHAR(50) NOT NULL,
    token_pago VARCHAR(255) NULL,
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_MetodosPago_Estado DEFAULT ('activo'),
    CONSTRAINT FK_MetodosPago_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT CK_MetodosPago_Tipo
        CHECK (tipo IN ('tarjeta', 'transferencia', 'billetera_terceros')),
    CONSTRAINT CK_MetodosPago_Estado
        CHECK (estado IN ('activo', 'expirado', 'eliminado'))
);
GO

CREATE INDEX IX_MetodosPago_Usuario ON dbo.MetodosPago (usuario_id);
GO

-- =============================================================================
-- 3) DOMINIO: TRADING Y MERCADO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ENTIDAD 4 · Orden de Trading
-- Instrucción de compra o venta emitida por un usuario en el mercado spot.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.OrdenTrading', 'U') IS NOT NULL DROP TABLE dbo.OrdenTrading;
GO

CREATE TABLE dbo.OrdenTrading (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_OrdenTrading PRIMARY KEY,
    usuario_id INT NOT NULL,
    par_trading VARCHAR(15) NOT NULL,
    tipo_orden VARCHAR(20) NOT NULL,
    lado VARCHAR(10) NOT NULL,
    cantidad DECIMAL(18,8) NOT NULL,
    estado VARCHAR(20) NOT NULL
        CONSTRAINT DF_OrdenTrading_Estado DEFAULT ('abierta'),
    CONSTRAINT FK_OrdenTrading_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT CK_OrdenTrading_TipoOrden
        CHECK (tipo_orden IN ('market', 'limit', 'stop-loss')),
    CONSTRAINT CK_OrdenTrading_Lado
        CHECK (lado IN ('compra', 'venta')),
    CONSTRAINT CK_OrdenTrading_Estado
        CHECK (estado IN ('abierta', 'ejecutada', 'cancelada'))
);
GO

-- Pregunta de negocio (Clase 2): "¿Qué órdenes activas tiene este usuario?"
CREATE INDEX IX_OrdenTrading_Usuario_Estado
    ON dbo.OrdenTrading (usuario_id, estado);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 6 · Historial de Precios
-- Serie temporal con el precio de cada criptomoneda.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.HistorialPrecios', 'U') IS NOT NULL DROP TABLE dbo.HistorialPrecios;
GO

CREATE TABLE dbo.HistorialPrecios (
    id BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_HistorialPrecios PRIMARY KEY,
    criptomoneda_id INT NOT NULL,
    precio_usd DECIMAL(18,8) NOT NULL,
    volumen_24h DECIMAL(20,2) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL
        CONSTRAINT DF_HistorialPrecios_FechaHora DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_HistorialPrecios_Criptomoneda
        FOREIGN KEY (criptomoneda_id) REFERENCES dbo.Criptomonedas (id)
);
GO

-- Serie temporal: acceso por activo y por orden cronológico descendente.
CREATE INDEX IX_HistorialPrecios_Cripto_Fecha
    ON dbo.HistorialPrecios (criptomoneda_id, fecha_hora DESC);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 11 · Comisión / Fee
-- Regla de negocio que define cuánto cobra la plataforma por operación.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Comisiones', 'U') IS NOT NULL DROP TABLE dbo.Comisiones;
GO

CREATE TABLE dbo.Comisiones (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Comisiones PRIMARY KEY,
    tipo_operacion VARCHAR(20) NOT NULL,
    porcentaje DECIMAL(5,4) NOT NULL,
    monto_fijo DECIMAL(18,8) NOT NULL
        CONSTRAINT DF_Comisiones_MontoFijo DEFAULT (0),
    nivel_usuario VARCHAR(20) NOT NULL
        CONSTRAINT DF_Comisiones_NivelUsuario DEFAULT ('estandar'),
    vigente_desde DATE NOT NULL,
    CONSTRAINT CK_Comisiones_TipoOperacion
        CHECK (tipo_operacion IN ('trading', 'retiro', 'deposito'))
);
GO

-- Índice para localizar la regla vigente por operación y nivel de usuario.
CREATE INDEX IX_Comisiones_Tipo_Nivel_Fecha
    ON dbo.Comisiones (tipo_operacion, nivel_usuario, vigente_desde);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 15 · Alerta de Precio
-- Regla configurada por el usuario para ser notificado al alcanzar un precio.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.AlertasPrecio', 'U') IS NOT NULL DROP TABLE dbo.AlertasPrecio;
GO

CREATE TABLE dbo.AlertasPrecio (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_AlertasPrecio PRIMARY KEY,
    usuario_id INT NOT NULL,
    criptomoneda_id INT NOT NULL,
    precio_objetivo DECIMAL(18,8) NOT NULL,
    condicion VARCHAR(20) NOT NULL,
    activa BIT NOT NULL
        CONSTRAINT DF_AlertasPrecio_Activa DEFAULT (1),
    CONSTRAINT FK_AlertasPrecio_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT FK_AlertasPrecio_Criptomoneda
        FOREIGN KEY (criptomoneda_id) REFERENCES dbo.Criptomonedas (id),
    CONSTRAINT CK_AlertasPrecio_Condicion
        CHECK (condicion IN ('mayor_que', 'menor_que'))
);
GO

-- Motor de alertas: cuáles están activas por usuario y por activo monitoreado.
CREATE INDEX IX_AlertasPrecio_Usuario_Activa
    ON dbo.AlertasPrecio (usuario_id, activa);
GO

CREATE INDEX IX_AlertasPrecio_Cripto_Activa
    ON dbo.AlertasPrecio (criptomoneda_id, activa);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 14 · Cartera de Inversión
-- Agrupación lógica de activos que el usuario arma para su portafolio.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.CarterasInversion', 'U') IS NOT NULL DROP TABLE dbo.CarterasInversion;
GO

CREATE TABLE dbo.CarterasInversion (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_CarterasInversion PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    fecha_creacion DATE NOT NULL
        CONSTRAINT DF_CarterasInversion_FechaCreacion DEFAULT (CAST(SYSDATETIME() AS DATE)),
    valor_total_usd DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_CarterasInversion_ValorTotal DEFAULT (0),
    CONSTRAINT FK_CarterasInversion_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id)
);
GO

CREATE INDEX IX_CarterasInversion_Usuario ON dbo.CarterasInversion (usuario_id);
GO

-- =============================================================================
-- 4) DOMINIO: COMPLIANCE Y AUDITORÍA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ENTIDAD 12 · Límite de Transacción
-- Techo máximo de operación diario o mensual según el nivel del usuario.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.LimitesTransaccion', 'U') IS NOT NULL DROP TABLE dbo.LimitesTransaccion;
GO

CREATE TABLE dbo.LimitesTransaccion (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_LimitesTransaccion PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo_limite VARCHAR(20) NOT NULL,
    monto_maximo DECIMAL(18,2) NOT NULL,
    monto_utilizado DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_LimitesTransaccion_MontoUtilizado DEFAULT (0),
    fecha_reinicio DATE NOT NULL,
    CONSTRAINT FK_LimitesTransaccion_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT CK_LimitesTransaccion_Tipo
        CHECK (tipo_limite IN ('diario', 'mensual'))
);
GO

CREATE INDEX IX_LimitesTransaccion_Usuario
    ON dbo.LimitesTransaccion (usuario_id, tipo_limite);
GO

-- -----------------------------------------------------------------------------
-- ENTIDAD 9 · Auditoría
-- Registro inmutable (append-only) de acciones sobre cuentas y fondos.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Auditorias', 'U') IS NOT NULL DROP TABLE dbo.Auditorias;
GO

CREATE TABLE dbo.Auditorias (
    id BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Auditorias PRIMARY KEY,
    usuario_id INT NOT NULL,
    entidad_afectada VARCHAR(50) NOT NULL,
    accion VARCHAR(100) NOT NULL,
    ip_origen VARCHAR(45) NOT NULL,
    fecha_hora DATETIME2(0) NOT NULL
        CONSTRAINT DF_Auditorias_FechaHora DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Auditorias_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id)
);
GO

-- Auditoría transversal: reconstrucción por usuario y por rango temporal.
CREATE INDEX IX_Auditorias_Usuario_Fecha
    ON dbo.Auditorias (usuario_id, fecha_hora DESC);
GO

CREATE INDEX IX_Auditorias_Entidad_Fecha
    ON dbo.Auditorias (entidad_afectada, fecha_hora DESC);
GO

-- =============================================================================
-- 5) DOMINIO: COMUNICACIÓN Y CONFIGURACIÓN DEL USUARIO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ENTIDAD 10 · Notificación
-- Mensaje enviado al usuario informando eventos de su cuenta.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.Notificaciones', 'U') IS NOT NULL DROP TABLE dbo.Notificaciones;
GO

CREATE TABLE dbo.Notificaciones (
    id BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Notificaciones PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    mensaje VARCHAR(500) NOT NULL,
    leida BIT NOT NULL
        CONSTRAINT DF_Notificaciones_Leida DEFAULT (0),
    fecha_envio DATETIME2(0) NOT NULL
        CONSTRAINT DF_Notificaciones_FechaEnvio DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Notificaciones_Usuario
        FOREIGN KEY (usuario_id) REFERENCES dbo.Usuarios (id),
    CONSTRAINT CK_Notificaciones_Tipo
        CHECK (tipo IN ('seguridad', 'transaccion', 'precio', 'marketing'))
);
GO

-- Bandeja del usuario: notificaciones pendientes, ordenadas de más reciente.
CREATE INDEX IX_Notificaciones_Usuario_Leida_Fecha
    ON dbo.Notificaciones (usuario_id, leida, fecha_envio DESC);
GO

-- =============================================================================
-- 6) VERIFICACIÓN DEL ESQUEMA
-- =============================================================================

-- Inventario de las 17 tablas del modelo.
SELECT t.name AS tabla
FROM sys.tables AS t
WHERE t.schema_id = SCHEMA_ID('dbo')
ORDER BY t.name;
GO

-- Relaciones (claves foráneas) del modelo.
SELECT OBJECT_NAME(fk.parent_object_id) AS tabla,
       OBJECT_NAME(fk.referenced_object_id) AS referencia
FROM sys.foreign_keys AS fk
ORDER BY tabla;
GO
