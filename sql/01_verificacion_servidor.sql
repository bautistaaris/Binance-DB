-- Identifica servidor, edicion y version del motor al que SSMS se conecto.
SELECT
    @@SERVERNAME AS servidor,
    SERVERPROPERTY('Edition') AS edicion,
    SERVERPROPERTY('ProductVersion') AS version;
GO

-- Crea la base destinada al proyecto. Se ejecuta una vez por equipo.
IF DB_ID('Binance_DB') IS NULL
    CREATE DATABASE Binance_DB;
GO

USE Binance_DB;
GO

-- Verifica el contexto actual de trabajo.
SELECT DB_NAME() AS base_actual,
       SCHEMA_NAME() AS esquema_predeterminado;
GO
