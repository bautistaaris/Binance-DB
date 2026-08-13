USE Binance_DB;
GO

DROP TABLE IF EXISTS dbo.DemoUsuarios;
GO

CREATE TABLE dbo.DemoUsuarios (
    id INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_DemoUsuarios PRIMARY KEY,
    email VARCHAR(120) NOT NULL,
    pais VARCHAR(60) NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL
        CONSTRAINT DF_DemoUsuarios_Fecha DEFAULT (SYSDATETIME())
);
GO

-- La regla UNIQUE evita duplicados y crea una ruta eficiente para el email.
CREATE UNIQUE INDEX UX_DemoUsuarios_Email
    ON dbo.DemoUsuarios(email);
GO

-- Índice pensado para filtros por país y orden por fecha de alta.
CREATE INDEX IX_DemoUsuarios_Pais_Fecha
    ON dbo.DemoUsuarios(pais, fecha_registro DESC);
GO

INSERT INTO dbo.DemoUsuarios (email, pais) VALUES
('juan@ejemplo.com', 'Argentina'),
('maria@ejemplo.com', 'Argentina'),
('pedro@ejemplo.com', 'España'),
('ana@ejemplo.com', 'México');
GO

SELECT id, email, pais, fecha_registro
FROM dbo.DemoUsuarios
WHERE email = 'maria@ejemplo.com';
GO

-- Inventario de índices definidos para la tabla de demostración.
SELECT i.name AS nombre_indice,
       i.type_desc AS tipo,
       i.is_unique AS es_unico
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.DemoUsuarios')
  AND i.index_id > 0;
GO
