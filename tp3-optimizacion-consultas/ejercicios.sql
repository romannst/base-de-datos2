-- EJERCICIO 1
EXPLAIN ANALYZE
SELECT c.nombre, p.fecha, p.importe
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN provincias pr ON c.id_provincia = pr.id_provincia
WHERE pr.nombre = 'Santa Fe' AND (EXTRACT(YEAR FROM p.fecha) = 2024
OR EXTRACT(YEAR FROM p.fecha) = 2025);	
-- Tiempo -> 2961.089 ms
-- Escaneo secuencial masivo en la tabla pedidos.
-- EXTRACT(YEAR FROM fecha) no es sargable: dificulta el uso eficiente de índices sobre fecha.

CREATE INDEX idx_fecha_pedidos ON pedidos(fecha);

EXPLAIN ANALYZE
SELECT c.nombre, p.fecha, p.importe
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN provincias pr ON c.id_provincia = pr.id_provincia
WHERE pr.nombre = 'Santa Fe'
AND p.fecha >= '2024-01-01' AND p.fecha < '2026-01-01';
-- Nuevo Tiempo con optimización lógica (WHERE) -> 1532.323 ms
-- Nuevo Tiempo con optimización física (index) -> 1089.616 ms
-- Bitmap Index Scan en la tabla pedidos.
-- Con filtro por rango de fechas (>= y <) el plan puede aprovechar mejor idx_fecha_pedidos.
-- Mejora adicional sugerida: indexar columnas de join/filtro frecuentes (p.id_cliente, c.id_provincia, pr.nombre).

-- EJERCICIO 2
EXPLAIN ANALYZE
SELECT id_pedido, id_articulo, fecha, cantidad
FROM pedidos
WHERE id_sucursal = 15 AND estado = 'PENDIENTE'
ORDER BY fecha ASC;
-- Tiempo -> 1307.718 ms
-- Escaneo secuencial en la tabla pedidos.

CREATE INDEX idx_pedidos_pendiente ON pedidos(estado);
-- Nuevo Tiempo con optimización física (index) -> 273.208 ms
-- Bitmap Index Scan en la tabla pedidos.
-- Comentario: para este caso suele rendir mejor un índice compuesto por filtros + orden.
-- Ejemplo sugerido: CREATE INDEX idx_pedidos_sucursal_estado_fecha ON pedidos(id_sucursal, estado, fecha);

-- EJERCICIO 3
CREATE INDEX idx_pedidos_1 ON pedidos(id_cliente);
CREATE INDEX idx_pedidos_2 ON pedidos(id_articulo);
CREATE INDEX idx_pedidos_3 ON pedidos(fecha);
CREATE INDEX idx_pedidos_4 ON pedidos(cantidad);
CREATE INDEX idx_pedidos_5 ON pedidos(importe);
CREATE INDEX idx_pedidos_6 ON pedidos(estado);

EXPLAIN ANALYZE
INSERT INTO pedidos (id_cliente, id_articulo, id_sucursal, fecha, cantidad, importe, estado)
VALUES
(1, 1, 1, CURRENT_DATE, 1, 1000.00, 'PAGADO'),
(2, 2, 2, CURRENT_DATE, 1, 2000.00, 'PAGADO'),
(3, 3, 3, CURRENT_DATE, 1, 3000.00, 'PAGADO'),
(4, 4, 4, CURRENT_DATE, 1, 4000.00, 'PAGADO'),
(5, 5, 5, CURRENT_DATE, 1, 5000.00, 'PAGADO');

-- Tiempo con indexes -> 1.501 ms
-- Tiempo sin indexes -> 0.519 ms
-- Conclusión: más índices aceleran lecturas, pero encarecen INSERT/UPDATE/DELETE por mantenimiento de índices.
-- Evitar sobreindexar columnas de baja selectividad o con poco uso en filtros/joins.

-- EJERCICIO 4
SELECT s.nombre AS sucursal, a.categoria, SUM(p.importe) AS
total_recaudado
FROM pedidos p
JOIN sucursales s ON p.id_sucursal = s.id_sucursal
JOIN articulos a ON p.id_articulo = a.id_articulo
GROUP BY s.nombre, a.categoria;
-- Tiempo -> 2335 ms

CREATE VIEW vista_recaudo_articulo_sucursal AS
SELECT s.nombre AS sucursal, a.categoria, SUM(p.importe) AS
total_recaudado
FROM pedidos p
JOIN sucursales s ON p.id_sucursal = s.id_sucursal
JOIN articulos a ON p.id_articulo = a.id_articulo
GROUP BY s.nombre, a.categoria;

EXPLAIN ANALYZE
SELECT * FROM vista_recaudo_articulo_sucursal;
-- Tiempo -> 3696.035 ms
-- Nuevo Tiempo -> 3217.181 ms
-- Una VIEW común no materializa datos: se recalcula en cada consulta.
-- Por eso la mejora es marginal o nula frente a ejecutar el SELECT original.

DROP VIEW vista_recaudo_articulo_sucursal;

CREATE MATERIALIZED VIEW mat_recaudo_articulo_sucursal AS
SELECT s.nombre AS sucursal, a.categoria, SUM(p.importe) AS
total_recaudado
FROM pedidos p
JOIN sucursales s ON p.id_sucursal = s.id_sucursal
JOIN articulos a ON p.id_articulo = a.id_articulo
GROUP BY s.nombre, a.categoria;

EXPLAIN ANALYZE
SELECT * FROM mat_recaudo_articulo_sucursal;
-- Nuevo Tiempo -> 0.024 ms
-- La MATERIALIZED VIEW persiste resultados preagregados: lectura muy rápida.
-- Trade-off: puede quedar desactualizada; usar REFRESH MATERIALIZED VIEW para sincronizar.

INSERT INTO pedidos (id_cliente, id_articulo, id_sucursal, fecha, cantidad, importe)
VALUES (1, 1, 1, CURRENT_DATE, 1, 5000000.00);

REFRESH MATERIALIZED VIEW mat_recaudo_articulo_sucursal;
-- 135992266.25 + 5000000.00 = 140992266.2 <- resultado esperado