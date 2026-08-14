-- =============================================================================
-- Binance_DB · Datos de ejemplo (seed) — 10 registros por tabla
-- Materia: Ingeniería de Datos I · UADE · Grupo 11
--
-- Carga 10 filas en cada una de las 17 tablas del Hito 1.
-- El script es idempotente: primero borra los datos existentes (en orden
-- inverso de dependencias) y luego inserta de nuevo.
-- =============================================================================

USE Binance_DB;
GO

-- =============================================================================
-- 0) LIMPIEZA PREVIA (orden inverso al de creación)
-- =============================================================================

DELETE FROM dbo.Notificaciones;
DELETE FROM dbo.Auditorias;
DELETE FROM dbo.LimitesTransaccion;
DELETE FROM dbo.CarterasInversion;
DELETE FROM dbo.AlertasPrecio;
DELETE FROM dbo.Comisiones;
DELETE FROM dbo.HistorialPrecios;
DELETE FROM dbo.OrdenTrading;
DELETE FROM dbo.MetodosPago;
DELETE FROM dbo.CuentasBancarias;
DELETE FROM dbo.Transacciones;
DELETE FROM dbo.Wallets;
DELETE FROM dbo.SesionesUsuario;
DELETE FROM dbo.RolesPermisos;
DELETE FROM dbo.VerificacionesKYC;
DELETE FROM dbo.Criptomonedas;
DELETE FROM dbo.Usuarios;
DELETE FROM dbo.DemoUsuarios;
GO

-- =============================================================================
-- 1) CATÁLOGO DE CRIPTOMONEDAS
-- =============================================================================

SET IDENTITY_INSERT dbo.Criptomonedas ON;
INSERT INTO dbo.Criptomonedas
    (id, codigo, nombre, decimales, red_blockchain, activa_para_trading)
VALUES
    (1,  'BTC',  'Bitcoin',       8,  'Bitcoin',     1),
    (2,  'ETH',  'Ethereum',      18, 'Ethereum',    1),
    (3,  'USDT', 'Tether',        6,  'Tron',        1),
    (4,  'BNB',  'BNB',           8,  'BNB Chain',   1),
    (5,  'SOL',  'Solana',        9,  'Solana',      1),
    (6,  'ADA',  'Cardano',       6,  'Cardano',     1),
    (7,  'XRP',  'XRP',           6,  'XRP Ledger',  1),
    (8,  'DOGE', 'Dogecoin',      8,  'Dogecoin',    1),
    (9,  'MATIC','Polygon',       18, 'Polygon',     1),
    (10, 'LTC',  'Litecoin',      8,  'Litecoin',    0);
SET IDENTITY_INSERT dbo.Criptomonedas OFF;
GO

-- =============================================================================
-- 2) USUARIOS
-- =============================================================================

SET IDENTITY_INSERT dbo.Usuarios ON;
INSERT INTO dbo.Usuarios
    (id, email, nombre_completo, fecha_registro, pais,
     estado_verificacion, documento_identidad, tipo_documento, saldo_total_usd)
VALUES
    (1,  'juan@ejemplo.com',     'Juan Pérez',        '2025-03-14', 'Argentina', 'verificado',    '38541234',   'DNI',       15230.50),
    (2,  'maria@ejemplo.com',    'María López',       '2025-05-02', 'Argentina', 'verificado',    '40223115',   'DNI',        8230.75),
    (3,  'pedro@ejemplo.com',    'Pedro García',      '2025-06-21', 'España',    'no_verificado', NULL,         NULL,            0.00),
    (4,  'ana@ejemplo.com',      'Ana Fernández',     '2025-07-11', 'México',    'verificado',    'M12345678',  'pasaporte',  3421.10),
    (5,  'carlos@ejemplo.com',   'Carlos Rodríguez',  '2025-08-30', 'Chile',     'premium',       '20123456',   'DNI',       98765.00),
    (6,  'lucia@ejemplo.com',    'Lucía Martínez',    '2025-09-18', 'Uruguay',   'verificado',    '51222333',   'DNI',        5120.40),
    (7,  'martin@ejemplo.com',   'Martín Díaz',       '2025-10-05', 'Colombia',  'no_verificado', NULL,         NULL,            0.00),
    (8,  'valentina@ejemplo.com','Valentina Ruiz',    '2025-11-22', 'Perú',      'verificado',    'P7654321',   'pasaporte',  9800.90),
    (9,  'nicolas@ejemplo.com',  'Nicolás Torres',    '2026-01-15', 'Argentina', 'premium',       '30987654',   'DNI',       23450.60),
    (10, 'camila@ejemplo.com',   'Camila Suárez',     '2026-02-27', 'Brasil',    'verificado',    'R44332211',  'pasaporte',  6754.25);
SET IDENTITY_INSERT dbo.Usuarios OFF;
GO

-- =============================================================================
-- 3) VERIFICACIÓN KYC (uno por usuario)
-- =============================================================================

SET IDENTITY_INSERT dbo.VerificacionesKYC ON;
INSERT INTO dbo.VerificacionesKYC
    (id, usuario_id, nivel, tipo_documento, numero_documento,
     documento_url, estado, fecha_verificacion)
VALUES
    (1,  1, 'intermedio', 'DNI',       '38541234',  '/kyc/juan_dni.pdf',   'aprobado', '2025-03-15'),
    (2,  2, 'intermedio', 'DNI',       '40223115',  '/kyc/maria_dni.pdf',  'aprobado', '2025-05-03'),
    (3,  3, 'basico',     'DNI',       '12345678',  '/kyc/pedro_dni.pdf',  'pendiente', NULL),
    (4,  4, 'intermedio', 'pasaporte', 'M12345678', '/kyc/ana_pasap.pdf',  'aprobado', '2025-07-12'),
    (5,  5, 'avanzado',   'DNI',       '20123456',  '/kyc/carlos_dni.pdf', 'aprobado', '2025-08-31'),
    (6,  6, 'intermedio', 'DNI',       '51222333',  '/kyc/lucia_dni.pdf',  'aprobado', '2025-09-19'),
    (7,  7, 'basico',     'DNI',       '87654321',  '/kyc/martin_dni.pdf', 'rechazado', '2025-10-06'),
    (8,  8, 'intermedio', 'pasaporte', 'P7654321',  '/kyc/valen_pasap.pdf','aprobado', '2025-11-23'),
    (9,  9, 'avanzado',   'DNI',       '30987654',  '/kyc/nico_dni.pdf',   'aprobado', '2026-01-16'),
    (10, 10, 'intermedio', 'pasaporte','R44332211', '/kyc/camila_pasap.pdf','aprobado','2026-02-28');
SET IDENTITY_INSERT dbo.VerificacionesKYC OFF;
GO

-- =============================================================================
-- 4) ROLES Y PERMISOS
-- =============================================================================

SET IDENTITY_INSERT dbo.RolesPermisos ON;
INSERT INTO dbo.RolesPermisos
    (id, nombre_rol, permiso, descripcion, activo)
VALUES
    (1,  'admin',      'congelar_wallet',   'Congelar la wallet de un usuario ante fraude', 1),
    (2,  'admin',      'descongelar_wallet', 'Reactivar una wallet previamente congelada',   1),
    (3,  'soporte',    'ver_kyc',           'Consultar la documentación KYC del usuario',    1),
    (4,  'soporte',    'resetear_2fa',      'Reiniciar la doble autenticación de una cuenta',1),
    (5,  'compliance', 'revisar_kyc',       'Aprobar o rechazar procesos de verificación',   1),
    (6,  'compliance', 'aplicar_limites',   'Modificar los límites de transacción',          1),
    (7,  'auditor',    'leer_auditoria',    'Consultar el registro de auditoría',            1),
    (8,  'auditor',    'exportar_reportes', 'Exportar reportes regulatorios',                1),
    (9,  'admin',      'gestionar_roles',   'Asignar roles a usuarios internos',             1),
    (10, 'soporte',    'cerrar_sesiones',   'Cerrar todas las sesiones de un usuario',       1);
SET IDENTITY_INSERT dbo.RolesPermisos OFF;
GO

-- =============================================================================
-- 5) SESIONES DE USUARIO
-- =============================================================================

SET IDENTITY_INSERT dbo.SesionesUsuario ON;
INSERT INTO dbo.SesionesUsuario
    (id, usuario_id, dispositivo, ip_origen, fecha_inicio, fecha_fin)
VALUES
    (1,  1,  'iPhone 15 Pro',     '190.1.2.10',   '2026-08-13 08:10:00', '2026-08-13 12:45:00'),
    (2,  2,  'Windows 11 Chrome', '181.3.4.55',   '2026-08-13 09:00:00', '2026-08-13 11:30:00'),
    (3,  3,  'Android Pixel 9',   '85.54.12.77',  '2026-08-13 10:15:00', '2026-08-13 10:40:00'),
    (4,  4,  'Windows 10 Edge',   '189.20.33.8',  '2026-08-13 11:00:00', NULL),
    (5,  5,  'macOS Safari',      '201.10.90.23', '2026-08-13 12:20:00', '2026-08-13 14:00:00'),
    (6,  6,  'iPhone 13',         '167.15.44.12', '2026-08-13 13:05:00', NULL),
    (7,  7,  'Windows 11 Firefox','186.4.77.31',  '2026-08-13 14:10:00', '2026-08-13 14:15:00'),
    (8,  8,  'Android Galaxy S24','200.8.60.19',  '2026-08-13 15:30:00', NULL),
    (9,  9,  'macOS Chrome',      '190.2.15.88',  '2026-08-13 16:45:00', '2026-08-13 18:00:00'),
    (10, 10, 'iPhone 14',         '179.9.22.44',  '2026-08-13 17:20:00', NULL);
SET IDENTITY_INSERT dbo.SesionesUsuario OFF;
GO

-- =============================================================================
-- 6) WALLETS (una wallet por usuario y criptomoneda)
-- =============================================================================

SET IDENTITY_INSERT dbo.Wallets ON;
INSERT INTO dbo.Wallets
    (id, usuario_id, criptomoneda_id, saldo, fecha_creacion, estado, direccion_publica)
VALUES
    (1,  1,  1, 0.25000000,  '2025-03-14', 'activa',   'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'),
    (2,  2,  2, 3.10000000,  '2025-05-02', 'activa',   '0x4d8fA1B6e8C2dD3f9A4bE5c6D7e8F9a0B1c2D3e4'),
    (3,  3,  3, 1500.000000, '2025-06-21', 'activa',   'TXyXfU9KzWp8Qm2Rn3Vc4Bd5Ae6Fg7Hj8Kl9Mn0'),
    (4,  4,  4, 8.75000000,  '2025-07-11', 'activa',   'bnb1q7l5k2j9s4w6d8f3e0r5t6y7u8i9o0p1a2s3d4'),
    (5,  5,  5, 45.00000000, '2025-08-30', 'activa',   'So11111111111111111111111111111111111111112'),
    (6,  6,  6, 1200.000000, '2025-09-18', 'activa',   'addr1q9k2m4n6p8r0s2t4v6x8z0b2d4f6h8j0k2m4n6'),
    (7,  7,  7, 5200.000000, '2025-10-05', 'congelada','rHb9CJAWyB4rj91VRWn96DkukG4bwdtyTh'),
    (8,  8,  8, 90000.00000, '2025-11-22', 'activa',   'D7qk4jW9mQ3zR5tY6uI8oP0aS2dF4gH6jK8lZ9x'),
    (9,  9,  9, 300.0000000, '2026-01-15', 'activa',   '0x9f3B7c1D5e8A2b4C6d9E0f1A3b5C7d9E1f3B5c7'),
    (10, 10, 10, 14.50000000,'2026-02-27', 'activa',   'ltc1q8z3w5e7r9t1y3u5i7o9p1a3s5d7f9g1h3j5k7');
SET IDENTITY_INSERT dbo.Wallets OFF;
GO

-- =============================================================================
-- 7) TRANSACCIONES (wallet_origen NULL = depósito externo)
-- =============================================================================

SET IDENTITY_INSERT dbo.Transacciones ON;
INSERT INTO dbo.Transacciones
    (id, wallet_origen_id, wallet_destino_id, cantidad, fecha_hora, estado, hash_transaccion)
VALUES
    (1,  NULL, 1,  0.25000000, '2026-08-01 09:00:00', 'completada', 'a1b2c3d4e5f60718293a4b5c6d7e8f901234567890abcdef1234567890ab'),
    (2,  NULL, 2,  3.10000000, '2026-08-02 10:30:00', 'completada', 'b2c3d4e5f60718293a4b5c6d7e8f901234567890abcdef1234567890abc'),
    (3,  1,    3,  0.05000000, '2026-08-03 11:15:00', 'completada', 'c3d4e5f60718293a4b5c6d7e8f901234567890abcdef1234567890abcd'),
    (4,  2,    4,  0.75000000, '2026-08-04 12:45:00', 'completada', 'd4e5f60718293a4b5c6d7e8f901234567890abcdef1234567890abcde'),
    (5,  3,    5,  100.000000, '2026-08-05 14:00:00', 'fallida',    'e5f60718293a4b5c6d7e8f901234567890abcdef1234567890abcdef1'),
    (6,  NULL, 6,  1200.00000, '2026-08-06 15:20:00', 'completada', 'f60718293a4b5c6d7e8f901234567890abcdef1234567890abcdef12'),
    (7,  5,    7,  5.00000000, '2026-08-07 16:35:00', 'completada', '0718293a4b5c6d7e8f901234567890abcdef1234567890abcdef123'),
    (8,  6,    8,  8000.00000, '2026-08-08 17:50:00', 'pendiente',  '18293a4b5c6d7e8f901234567890abcdef1234567890abcdef1234'),
    (9,  7,    9,  25.0000000, '2026-08-09 18:10:00', 'completada', '293a4b5c6d7e8f901234567890abcdef1234567890abcdef12345'),
    (10, 8,    10, 1.75000000, '2026-08-10 19:25:00', 'completada', '3a4b5c6d7e8f901234567890abcdef1234567890abcdef123456');
SET IDENTITY_INSERT dbo.Transacciones OFF;
GO

-- =============================================================================
-- 8) CUENTAS BANCARIAS
-- =============================================================================

SET IDENTITY_INSERT dbo.CuentasBancarias ON;
INSERT INTO dbo.CuentasBancarias
    (id, usuario_id, banco, cbu_iban, titular, verificada)
VALUES
    (1,  1,  'Banco Nación',      '0110499930000001234567', 'Juan Pérez',      1),
    (2,  2,  'Banco Galicia',     '0070499930000007654321', 'María López',     1),
    (3,  3,  'Santander España',  'ES9121000418450200051332', 'Pedro García',   0),
    (4,  4,  'Banorte',           '0121800150000008765432', 'Ana Fernández',   1),
    (5,  5,  'Banco de Chile',    '0011499930000003456789', 'Carlos Rodríguez',1),
    (6,  6,  'Banco República',   '0001140440000009012345', 'Lucía Martínez',  1),
    (7,  7,  'Bancolombia',       '0601499930000004567890', 'Martín Díaz',     0),
    (8,  8,  'BBVA Perú',         '0181499930000002345678', 'Valentina Ruiz',  1),
    (9,  9,  'Banco Provincia',   '0140499930000006789012', 'Nicolás Torres',  1),
    (10, 10, 'Itaú Brasil',       'BR1500000000000010932',  'Camila Suárez',   0);
SET IDENTITY_INSERT dbo.CuentasBancarias OFF;
GO

-- =============================================================================
-- 9) MÉTODOS DE PAGO
-- =============================================================================

SET IDENTITY_INSERT dbo.MetodosPago ON;
INSERT INTO dbo.MetodosPago
    (id, usuario_id, tipo, proveedor, token_pago, estado)
VALUES
    (1,  1,  'tarjeta',          'Visa',           'tok_visa_123456',       'activo'),
    (2,  2,  'tarjeta',          'Mastercard',     'tok_mc_654321',         'activo'),
    (3,  3,  'transferencia',    'SEPA',           NULL,                    'activo'),
    (4,  4,  'billetera_terceros','Mercado Pago',  'tok_mp_111213',          'activo'),
    (5,  5,  'tarjeta',          'Visa',           'tok_visa_222333',       'activo'),
    (6,  6,  'transferencia',    'Redpagos',       NULL,                    'expirado'),
    (7,  7,  'tarjeta',          'American Express','tok_amex_444555',      'activo'),
    (8,  8,  'billetera_terceros','Yape',          'tok_yape_666777',       'activo'),
    (9,  9,  'tarjeta',          'Mastercard',     'tok_mc_888999',         'activo'),
    (10, 10, 'transferencia',    'PIX',            NULL,                    'eliminado');
SET IDENTITY_INSERT dbo.MetodosPago OFF;
GO

-- =============================================================================
-- 10) ÓRDENES DE TRADING
-- =============================================================================

SET IDENTITY_INSERT dbo.OrdenTrading ON;
INSERT INTO dbo.OrdenTrading
    (id, usuario_id, par_trading, tipo_orden, lado, cantidad, estado)
VALUES
    (1,  1,  'BTC/USDT',  'market',    'compra', 0.01000000, 'ejecutada'),
    (2,  2,  'ETH/USDT',  'limit',     'compra', 1.50000000, 'abierta'),
    (3,  3,  'USDT/ARS',  'market',    'venta',  500.000000, 'ejecutada'),
    (4,  4,  'BNB/USDT',  'limit',     'venta',  2.00000000, 'cancelada'),
    (5,  5,  'SOL/USDT',  'stop-loss', 'venta',  10.0000000, 'abierta'),
    (6,  6,  'ADA/USDT',  'market',    'compra', 500.000000, 'ejecutada'),
    (7,  7,  'XRP/USDT',  'limit',     'venta',  1000.00000, 'abierta'),
    (8,  8,  'DOGE/USDT', 'market',    'compra', 5000.00000, 'ejecutada'),
    (9,  9,  'MATIC/USDT','stop-loss', 'compra', 100.000000, 'abierta'),
    (10, 10, 'LTC/USDT',  'limit',     'compra', 3.00000000, 'ejecutada');
SET IDENTITY_INSERT dbo.OrdenTrading OFF;
GO

-- =============================================================================
-- 11) HISTORIAL DE PRECIOS
-- =============================================================================

SET IDENTITY_INSERT dbo.HistorialPrecios ON;
INSERT INTO dbo.HistorialPrecios
    (id, criptomoneda_id, precio_usd, volumen_24h, fecha_hora)
VALUES
    (1,  1,  61000.00000000, 25000000000.00, '2026-08-13 00:00:00'),
    (2,  2,  3350.00000000,  18000000000.00, '2026-08-13 00:00:00'),
    (3,  3,  1.00000000,     45000000000.00, '2026-08-13 00:00:00'),
    (4,  4,  590.00000000,   3200000000.00,  '2026-08-13 00:00:00'),
    (5,  5,  145.00000000,   2100000000.00,  '2026-08-13 00:00:00'),
    (6,  6,  0.45000000,     780000000.00,   '2026-08-13 00:00:00'),
    (7,  7,  0.62000000,     980000000.00,   '2026-08-13 00:00:00'),
    (8,  8,  0.15000000,     540000000.00,   '2026-08-13 00:00:00'),
    (9,  9,  0.89000000,     360000000.00,   '2026-08-13 00:00:00'),
    (10, 10, 84.00000000,    420000000.00,   '2026-08-13 00:00:00');
SET IDENTITY_INSERT dbo.HistorialPrecios OFF;
GO

-- =============================================================================
-- 12) COMISIONES / FEES
-- =============================================================================

SET IDENTITY_INSERT dbo.Comisiones ON;
INSERT INTO dbo.Comisiones
    (id, tipo_operacion, porcentaje, monto_fijo, nivel_usuario, vigente_desde)
VALUES
    (1,  'trading',   0.0010, 0.00000000, 'estandar', '2026-01-01'),
    (2,  'trading',   0.0009, 0.00000000, 'vip1',     '2026-01-01'),
    (3,  'trading',   0.0008, 0.00000000, 'vip2',     '2026-01-01'),
    (4,  'trading',   0.0007, 0.00000000, 'vip3',     '2026-01-01'),
    (5,  'trading',   0.0006, 0.00000000, 'vip4',     '2026-01-01'),
    (6,  'retiro',    0.0010, 1.50000000, 'estandar', '2026-01-01'),
    (7,  'retiro',    0.0005, 0.50000000, 'vip1',     '2026-01-01'),
    (8,  'deposito',  0.0000, 0.00000000, 'estandar', '2026-01-01'),
    (9,  'deposito',  0.0000, 0.00000000, 'vip1',     '2026-01-01'),
    (10, 'trading',   0.0005, 0.00000000, 'vip5',     '2026-07-01');
SET IDENTITY_INSERT dbo.Comisiones OFF;
GO

-- =============================================================================
-- 13) ALERTAS DE PRECIO
-- =============================================================================

SET IDENTITY_INSERT dbo.AlertasPrecio ON;
INSERT INTO dbo.AlertasPrecio
    (id, usuario_id, criptomoneda_id, precio_objetivo, condicion, activa)
VALUES
    (1,  1,  1, 65000.00000000, 'mayor_que',  1),
    (2,  2,  2, 3500.00000000,  'mayor_que',  1),
    (3,  3,  3, 0.99000000,     'menor_que',  0),
    (4,  4,  4, 600.00000000,   'mayor_que',  1),
    (5,  5,  5, 150.00000000,   'mayor_que',  1),
    (6,  6,  6, 0.40000000,     'menor_que',  1),
    (7,  7,  7, 0.58000000,     'menor_que',  0),
    (8,  8,  8, 0.20000000,     'mayor_que',  1),
    (9,  9,  9, 0.85000000,     'menor_que',  1),
    (10, 10, 10, 90.00000000,   'mayor_que',  0);
SET IDENTITY_INSERT dbo.AlertasPrecio OFF;
GO

-- =============================================================================
-- 14) CARTERAS DE INVERSIÓN
-- =============================================================================

SET IDENTITY_INSERT dbo.CarterasInversion ON;
INSERT INTO dbo.CarterasInversion
    (id, usuario_id, nombre, fecha_creacion, valor_total_usd)
VALUES
    (1,  1,  'Portafolio largo plazo', '2025-03-14', 15230.50),
    (2,  2,  'Fondo de emergencia',    '2025-05-02', 8230.75),
    (3,  3,  'Sin cartera',            '2025-06-21', 0.00),
    (4,  4,  'Cripto diversificada',   '2025-07-11', 3421.10),
    (5,  5,  'Trading activo',         '2025-08-30', 98765.00),
    (6,  6,  'Ahorro en cripto',       '2025-09-18', 5120.40),
    (7,  7,  'Sin cartera',            '2025-10-05', 0.00),
    (8,  8,  'Jubilación alternativa', '2025-11-22', 9800.90),
    (9,  9,  'Alta frecuencia',        '2026-01-15', 23450.60),
    (10, 10, 'Portafolio equilibrado', '2026-02-27', 6754.25);
SET IDENTITY_INSERT dbo.CarterasInversion OFF;
GO

-- =============================================================================
-- 15) LÍMITES DE TRANSACCIÓN
-- =============================================================================

SET IDENTITY_INSERT dbo.LimitesTransaccion ON;
INSERT INTO dbo.LimitesTransaccion
    (id, usuario_id, tipo_limite, monto_maximo, monto_utilizado, fecha_reinicio)
VALUES
    (1,  1,  'diario',  5000.00,  1200.00, '2026-08-14'),
    (2,  2,  'diario',  5000.00,   800.00, '2026-08-14'),
    (3,  3,  'diario',  1000.00,     0.00, '2026-08-14'),
    (4,  4,  'diario',  5000.00,  2500.00, '2026-08-14'),
    (5,  5,  'mensual', 100000.00, 45000.00, '2026-09-01'),
    (6,  6,  'diario',  5000.00,   300.00, '2026-08-14'),
    (7,  7,  'diario',  1000.00,     0.00, '2026-08-14'),
    (8,  8,  'mensual', 50000.00,  12000.00, '2026-09-01'),
    (9,  9,  'mensual', 100000.00, 60000.00, '2026-09-01'),
    (10, 10, 'diario',  5000.00,  1500.00, '2026-08-14');
SET IDENTITY_INSERT dbo.LimitesTransaccion OFF;
GO

-- =============================================================================
-- 16) AUDITORÍAS
-- =============================================================================

SET IDENTITY_INSERT dbo.Auditorias ON;
INSERT INTO dbo.Auditorias
    (id, usuario_id, entidad_afectada, accion, ip_origen, fecha_hora)
VALUES
    (1,  1,  'Usuarios',     'login exitoso',              '190.1.2.10',   '2026-08-13 08:10:00'),
    (2,  5,  'Wallets',      'congelar wallet',            '201.10.90.23', '2026-08-13 09:00:00'),
    (3,  9,  'OrdenTrading', 'cancelar orden',             '190.2.15.88',  '2026-08-13 10:30:00'),
    (4,  2,  'Transacciones','transferencia completada',   '181.3.4.55',   '2026-08-13 11:15:00'),
    (5,  1,  'Usuarios',     'cambio de contraseña',       '190.1.2.10',   '2026-08-13 12:00:00'),
    (6,  7,  'VerificacionesKYC','rechazo de documento',   '186.4.77.31',  '2026-08-13 13:45:00'),
    (7,  9,  'CuentasBancarias','alta de cuenta bancaria', '190.2.15.88',  '2026-08-13 14:20:00'),
    (8,  3,  'SesionesUsuario','cierre de sesión remoto',  '85.54.12.77',  '2026-08-13 15:05:00'),
    (9,  5,  'AlertasPrecio','desactivar alerta',          '201.10.90.23', '2026-08-13 16:40:00'),
    (10, 2,  'MetodosPago',  'eliminar método de pago',    '181.3.4.55',   '2026-08-13 17:55:00');
SET IDENTITY_INSERT dbo.Auditorias OFF;
GO

-- =============================================================================
-- 17) NOTIFICACIONES
-- =============================================================================

SET IDENTITY_INSERT dbo.Notificaciones ON;
INSERT INTO dbo.Notificaciones
    (id, usuario_id, tipo, mensaje, leida, fecha_envio)
VALUES
    (1,  1,  'seguridad',   'Inicio de sesión desde un dispositivo nuevo (iPhone 15 Pro).', 0, '2026-08-13 08:10:00'),
    (2,  2,  'transaccion', 'Depósito de 3.1 ETH confirmado.',                               1, '2026-08-13 09:00:00'),
    (3,  3,  'marketing',   'Nuevo evento de trading este viernes.',                         0, '2026-08-13 10:00:00'),
    (4,  4,  'precio',      'BNB superó el precio objetivo de tu alerta.',                   1, '2026-08-13 11:30:00'),
    (5,  5,  'transaccion', 'Retiro de fondos pendiente de confirmación.',                   0, '2026-08-13 12:15:00'),
    (6,  6,  'seguridad',   'Verificación de identidad completada.',                         1, '2026-08-13 13:00:00'),
    (7,  7,  'seguridad',   'Tu KYC fue rechazado. Volvé a cargar tu documento.',            0, '2026-08-13 14:00:00'),
    (8,  8,  'precio',      'DOGE superó tu precio objetivo.',                               1, '2026-08-13 15:30:00'),
    (9,  9,  'marketing',   'Beneficios exclusivos para usuarios VIP.',                      0, '2026-08-13 16:00:00'),
    (10, 10, 'transaccion', 'Compra de 1.75 LTC ejecutada con éxito.',                       1, '2026-08-13 17:00:00');
SET IDENTITY_INSERT dbo.Notificaciones OFF;
GO

-- =============================================================================
-- 18) DemoUsuarios (tabla de la Clase 2) — completa hasta 10 registros
-- =============================================================================

INSERT INTO dbo.DemoUsuarios (email, pais) VALUES
('juan@ejemplo.com',     'Argentina'),
('maria@ejemplo.com',    'Argentina'),
('pedro@ejemplo.com',    'España'),
('ana@ejemplo.com',      'México'),
('carlos@ejemplo.com',   'Chile'),
('lucia@ejemplo.com',    'Uruguay'),
('martin@ejemplo.com',   'Colombia'),
('valentina@ejemplo.com','Perú'),
('nicolas@ejemplo.com',  'Argentina'),
('camila@ejemplo.com',   'Brasil');
GO

-- =============================================================================
-- 19) VERIFICACIÓN DEL SEED — 10 registros por tabla
-- =============================================================================

SELECT 'AlertasPrecio' AS tabla, COUNT(*) AS registros FROM dbo.AlertasPrecio
UNION ALL SELECT 'Auditorias', COUNT(*) FROM dbo.Auditorias
UNION ALL SELECT 'CarterasInversion', COUNT(*) FROM dbo.CarterasInversion
UNION ALL SELECT 'Comisiones', COUNT(*) FROM dbo.Comisiones
UNION ALL SELECT 'Criptomonedas', COUNT(*) FROM dbo.Criptomonedas
UNION ALL SELECT 'CuentasBancarias', COUNT(*) FROM dbo.CuentasBancarias
UNION ALL SELECT 'HistorialPrecios', COUNT(*) FROM dbo.HistorialPrecios
UNION ALL SELECT 'LimitesTransaccion', COUNT(*) FROM dbo.LimitesTransaccion
UNION ALL SELECT 'MetodosPago', COUNT(*) FROM dbo.MetodosPago
UNION ALL SELECT 'Notificaciones', COUNT(*) FROM dbo.Notificaciones
UNION ALL SELECT 'OrdenTrading', COUNT(*) FROM dbo.OrdenTrading
UNION ALL SELECT 'RolesPermisos', COUNT(*) FROM dbo.RolesPermisos
UNION ALL SELECT 'SesionesUsuario', COUNT(*) FROM dbo.SesionesUsuario
UNION ALL SELECT 'Transacciones', COUNT(*) FROM dbo.Transacciones
UNION ALL SELECT 'Usuarios', COUNT(*) FROM dbo.Usuarios
UNION ALL SELECT 'VerificacionesKYC', COUNT(*) FROM dbo.VerificacionesKYC
UNION ALL SELECT 'Wallets', COUNT(*) FROM dbo.Wallets
UNION ALL SELECT 'DemoUsuarios', COUNT(*) FROM dbo.DemoUsuarios;
GO
