ALTER SYSTEM SET max_parallel_workers_per_gather = 2;
SELECT pg_reload_conf();
SHOW max_parallel_workers_per_gather;

-- EJERCICIO 1
CREATE ROLE rol_gerente;
CREATE USER gerente_ana WITH PASSWORD 'Directorio2026';
GRANT rol_gerente TO gerente_ana;

CREATE VIEW v_reporte_ingresos_sucursal AS
SELECT s.nombre AS Sucursal, SUM(p.IMPORTE) AS Importe_Total
FROM sucursales AS s JOIN pedidos AS p ON s.id_sucursal = p.id_sucursal GROUP BY Sucursal;

CREATE VIEW v_capital_invertido_categoria AS
SELECT categoria AS categoria_articulo, SUM(stock * precio_unitario) AS Capital_Invertido
FROM articulos GROUP BY categoria_articulo;

CREATE VIEW v_metricas_pedidos AS
SELECT estado, COUNT(*) AS cantidad
FROM pedidos GROUP BY estado;

GRANT SELECT ON v_reporte_ingresos_sucursal, v_capital_invertido_categoria, v_metricas_pedidos
TO rol_gerente;

SET ROLE gerente_ana;
SELECT * FROM pedidos; -- no tiene permisos de lectura sobre la tabla pedidos
SELECT * FROM v_reporte_ingresos_sucursal;

-- La creación de vistas con permisos RBAC se considera seguro, porque no se le dan permisos a los usuarios para acceder directamente a las tablas, sino que a través de las vistas solo pueden acceder a los datos que pide la consulta guardada en la vista. Esto hace que los usuarios no tengan privilegios de más, sólo lo necesario (principio de mínimo privilegio).

-- EJERCICIO 2
CREATE TABLE confidencial(
id_cliente BIGINT PRIMARY KEY,
telefono_emergencia_cifrado BYTEA,
pin_entrega_hash TEXT,
CONSTRAINT fk_id_cliente
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

INSERT INTO confidencial (id_cliente, telefono_emergencia_cifrado, pin_entrega_hash)
VALUES ()