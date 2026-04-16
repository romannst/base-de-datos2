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

-- Se utiliza REPEATABLE READ para obtener una "foto" de los datos
-- en un instante del tiempo (snapshot), evitando lecturas inconsistentes.
-- No se usan bloqueos explícitos (B2F), porque en este nivel de
-- aislamiento se garantiza consistencia sin bloquear a otros usuarios (MVCC).

--- EJERCICIO 3

BEGIN;

SELECT saldo FROM billetera_clientes WHERE id_cliente = 4 FOR UPDATE;
UPDATE billetera_clientes SET saldo = saldo - 10000 WHERE id_cliente = 4 AND saldo >= 10000;
INSERT INTO auditoria_log (accion, datos) VALUES ('COMPRA', 'Cliente 4 realizó una compra por 10000');

COMMIT;

-- Se utiliza un bloqueo explícito (SELECT ... FOR UPDATE) para implementar
-- control pesimista (B2F). Esto asegura que la fila del cliente quede bloqueada
-- mientras dura la transacción, forzando a la segunda pestaña a esperar.
-- De esta forma se evita el problema de doble gasto en alta concurrencia.

-- EJERCICIO 4

BEGIN;

SELECT saldo FROM billetera_clientes WHERE id_cliente = 2 FOR UPDATE;
SELECT saldo FROM billetera_clientes WHERE id_cliente = 5 FOR UPDATE;
UPDATE billetera_clientes SET saldo = saldo - 500 WHERE id_cliente = 5 ;
UPDATE billetera_clientes SET saldo = saldo + 500 WHERE id_cliente = 2;
INSERT INTO auditoria_log (accion, datos) VALUES ('TRANSFERENCIA', 'Transferencia de $500 de cliente 5 a cliente 2')

COMMIT;

-- Se utiliza bloqueo explícito (SELECT ... FOR UPDATE) para asegurar un orden consistente
-- de adquisición de locks (ID menor → mayor), evitando deadlocks en escenarios concurrentes.