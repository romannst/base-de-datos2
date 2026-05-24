-- MISION 1
-- creo un backup de la tabla articulos con los datos actuales
docker exec -t practicos_db2 pg_dump -U admin -d practicos_db2 --data-only --inserts --column-inserts --table=articulos > articulos_backup.sql

-- cambio el precio de todos los articulos a 0.01 para simular una perdida de datos o un error en la base de datos
UPDATE articulos SET precio_unitario = 0.01;
-- verifico que todos los articulos tengan ese precio para confirmar que se ha producido el cambio
SELECT * FROM articulos;
-- vaciar tabla antes de restaurar para evitar claves duplicadas y asegurar que se restaura correctamente
TRUNCATE TABLE articulos CASCADE;
-- restauro la bd con el contenido de articulos_backup.sql para recuperar los datos originales
psql -U admin -d practicos_db2 -f articulos_backup.sql -- o se pega el contenido del backup directamente en pgAdmin en una query

-- Si la base de datos pesara 500 GB, ¿elegirías hacer este backup lógico (pg_dump) o un backup físico (pg_basebackup) en frío?
-- Para una base de datos de 500 GB, sería más eficiente realizar un backup físico utilizando pg_basebackup en frío. Esto se debe a que los backups físicos son generalmente más rápidos y ocupan menos espacio en comparación con los backups lógicos, especialmente para bases de datos grandes. Esto favorece los tiempos para el RTO (Recovery Time Objective) porque la restauración de un backup físico suele ser más rápida que la de un backup lógico, lo que es crucial para minimizar el tiempo de inactividad en caso de una recuperación.

-- MISION 2
1. [CHECKPOINT]
2. <T1, START>
3. <T1, UPDATE, billetera_clientes, id=1, viejo_saldo=500, nuevo_saldo=200>
4. <T2, START>
5. <T1, COMMIT>
6. <T2, UPDATE, pedidos, id_pedido=15, estado_viejo='PENDIENTE', estado_nuevo='PAGADO'>
7. --- CORTE DE ENERGÍA ---

-- redo undo
REDO: <T1, UPDATE, billetera_clientes, id=1, viejo_saldo=500, nuevo_saldo=200>
UNDO: <T2, UPDATE, pedidos, id_pedido=15, estado_viejo='PENDIENTE', estado_nuevo='PAGADO'>

-- Fase de REDO: ¿Qué valor exacto se asegurará el motor de escribir físicamente en el disco para el cliente 1? ¿Por qué lo hace si el corte de luz fue posterior al COMMIT?
-- El motor de la base de datos asegurará que el nuevo saldo de 200 para el cliente con id=1 se escriba físicamente en el disco. Esto se debe a que el corte de energía ocurrió después del COMMIT de la transacción T1, lo que significa que los cambios realizados por T1 (actualización del saldo) ya han sido confirmados y deben ser persistentes.
-- Fase de UNDO: ¿Qué valor final quedará en la columna estado del pedido 15 tras la recuperación?
-- El valor final en la columna estado del pedido 15 quedará como 'PENDIENTE' tras la recuperación. Esto se debe a que la transacción T2 no había hecho COMMIT antes del corte de energía, por lo que sus cambios no se considerarán permanentes y serán revertidos durante la fase de UNDO.

-- MISION 3
-- ¿Qué modificación estructural obligatoria exige PostgreSQL sobre la Primary Key para permitirnos particionar por la columna id_provincia?
-- Para particionar por la columna id_provincia, PostgreSQL exige que la columna id_provincia sea parte de la Primary Key. Esto se debe a que cada partición debe tener una clave única que incluya la columna por la cual se está particionando, lo que garantiza que los datos se distribuyan correctamente entre las particiones y se mantenga la integridad referencial.
-- Al hacer esa modificación, ¿Estamos rompiendo alguna forma normal de diseño de bases de datos relacionales en pos de la optimización? Explica brevemente.
-- Sí, al incluir la columna id_provincia en la Primary Key, estamos rompiendo la Tercera Forma Normal (3NF) del diseño de bases de datos relacionales. Sin embargo, esta modificación se hace en pos de la optimización para mejorar el rendimiento de las consultas que filtran por id_provincia, lo que puede ser beneficioso en escenarios con grandes volúmenes de datos.

-- MISION 4
-- recupero el sql de creacion de la tabla pedidos
docker exec -t practicos_db2 pg_dump -U admin -d practicos_db2 --table=pedidos > pedidos.sql  --schema-only
-- renombro la tabla pedidos para poder crear la nueva tabla con la estructura optimizada sin perder los datos originales
ALTER TABLE pedidos RENAME TO pedidos_old;
-- creo la nueva tabla pedidos con la estructura optimizada para particionar por fecha
CREATE TABLE public.pedidos (
    id_pedido bigint NOT NULL,
    id_cliente bigint NOT NULL,
    id_articulo bigint NOT NULL,
    id_sucursal integer NOT NULL,
    fecha date NOT NULL,
    cantidad integer NOT NULL,
    importe numeric(14,2) NOT NULL,
    estado character varying(20) DEFAULT 'PENDIENTE'::character varying NOT NULL,
	CONSTRAINT pedidos_pk PRIMARY KEY (id_pedido, fecha),
    CONSTRAINT pedidos_cantidad_check CHECK ((cantidad > 0)),
    CONSTRAINT pedidos_importe_check CHECK ((importe >= (0)::numeric))
) PARTITION BY RANGE(fecha);
-- creo las particiones hijas de la tabla pedidos para cada año desde 2021 hasta 2026
CREATE TABLE pedidos_2026 PARTITION OF pedidos
FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE pedidos_2025 PARTITION OF pedidos
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE pedidos_2024 PARTITION OF pedidos
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE pedidos_2023 PARTITION OF pedidos
FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');
CREATE TABLE pedidos_2022 PARTITION OF pedidos
FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');
CREATE TABLE pedidos_2021 PARTITION OF pedidos
FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
-- paso los datos de la tabla pedidos_old a la nueva tabla pedidos para que se distribuyan automáticamente en las particiones correspondientes según la fecha de cada pedido
INSERT INTO pedidos SELECT * FROM pedidos_old;
-- analizo los tiempos de consulta para verificar la mejora en el rendimiento tras la partición
EXPLAIN ANALYZE SELECT * FROM pedidos WHERE fecha = '2026-02-15'; -- Execution Time: 16.299 ms
EXPLAIN ANALYZE SELECT * FROM pedidos_old WHERE fecha = '2026-02-15'; -- Execution Time: 4684.471 ms
-- Al ejecutar el EXPLAIN del paso anterior, ¿Se observa el fenómeno de Partition Pruning? ¿Cómo te das cuenta de que el motor ignoró las particiones que no servían para la consulta?
-- Sí, se observa el fenómeno de Partition Pruning. Esto se puede deducir al comparar los tiempos de ejecución entre la consulta en la tabla particionada (pedidos) y la consulta en la tabla no particionada (pedidos_old). La consulta en la tabla particionada es significativamente más rápida, lo que indica que el motor de la base de datos ha ignorado las particiones que no contienen datos relevantes para la fecha especificada ('2026-02-15'), optimizando así el tiempo de respuesta.