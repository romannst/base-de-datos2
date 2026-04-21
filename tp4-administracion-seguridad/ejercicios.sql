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
VALUES (1, pgp_sym_encrypt('555-0199','secreto_empresa'), crypt('4092', gen_salt('bf')));

--verificar pin correcto
SELECT (pin_entrega_hash = crypt('4092', pin_entrega_hash))
FROM confidencial WHERE id_cliente = 1;
--recuperar el telefono cifrado
SELECT (pgp_sym_decrypt(telefono_emergencia_cifrado,'secreto_empresa')) AS telefono_emg_decrypt
FROM confidencial WHERE id_cliente = 1;

-- Si un empleado con permisos de lectura general hace una copia de la base de datos y se la lleva, no podrá tener acceso a los teléfonos de emergencia ni a los pines de cada cliente, porque su contenido se encuentra cifrado y no tiene la clave de cifrado ni el hash para poder descifrarlo o verificarlo. Esto hace que la información confidencial esté protegida incluso si se accede a la base de datos sin autorización.

-- EJERCICIO 3
CREATE ROLE rol_vendedor;
GRANT SELECT,INSERT ON pedidos TO rol_vendedor;
GRANT UPDATE (estado) ON pedidos TO rol_vendedor;

-- EJERCICIO 4
REVOKE rol_gerente FROM gerente_ana;
DROP USER gerente_ana;

-- Si intentamos hacer un DROP USER gerente_ana; directamente sin revocar sus permisos previamente, PostgreSQL lanza un error.
-- El motor de base de datos tiene este comportamiento defensivo para evitar inconsistencias y problemas de seguridad en la base de datos. Si se permitiera eliminar un usuario sin revocar sus permisos, se podrían generar situaciones donde los permisos otorgados a ese usuario quedarían huérfanos, es decir, sin un propietario válido. Esto podría llevar a que otros usuarios o roles hereden esos permisos de manera no intencionada, lo que podría resultar en accesos no autorizados a datos sensibles o en la ejecución de acciones que el usuario eliminado tenía permitido realizar.
-- En resumen, el motor de base de datos protege la integridad y la seguridad de la matriz de acceso (DAC) al requerir que se revoquen los permisos antes de eliminar un usuario, asegurando que no queden permisos huérfanos y que la gestión de la seguridad se mantenga clara y consistente.