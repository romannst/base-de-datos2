-- 1. Creamos la tabla de auditoría (si no existe)
CREATE TABLE IF NOT EXISTS auditoria_log (
id SERIAL PRIMARY KEY,
accion TEXT NOT NULL,
datos TEXT NOT NULL,
fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 2. Preparamos los datos exactos para los ejercicios
UPDATE articulos SET stock = 2 WHERE id_articulo = 15;
UPDATE billetera_clientes SET saldo = 10000 WHERE id_cliente = 4;
UPDATE billetera_clientes SET saldo = 5000 WHERE id_cliente = 5;
UPDATE billetera_clientes SET saldo = 5000 WHERE id_cliente = 2;

--- EJERCICIO 1
BEGIN;

SELECT stock FROM articulos WHERE id_articulo = 15 FOR UPDATE;
UPDATE articulos SET stock = stock + 1 WHERE id_articulo = 15 AND stock > 0;
INSERT INTO auditoria_log (accion, datos) VALUES ('Venta', 'Artículo 15 vendido, stock actualizado');

COMMIT;

--- EJERCICIO 2

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

INSERT INTO auditoria_log (accion, datos) SELECT 'REPORTE', SUM(saldo) FROM billetera_clientes;

COMMIT;