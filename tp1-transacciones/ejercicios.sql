--- EJERCICIO 1
SELECT descripcion, precio_unitario,stock
FROM articulos WHERE id_articulo = 9;
SELECT saldo FROM billetera_clientes
WHERE id_cliente = 1;
SELECT COUNT(id_cliente) AS cant FROM pedidos
WHERE id_cliente = 1 AND id_articulo = 9;

BEGIN;
	-- se cobra el monto del pedido al cliente
	UPDATE billetera_clientes
	SET saldo = saldo - (2819.44)*5
	WHERE id_cliente = 1;
	-- se descuenta el stock del producto
	UPDATE articulos
	SET stock = stock - 5
	WHERE id_articulo = 9;
	-- se agrega el pedido en la lista de pedidos
	INSERT INTO pedidos (id_cliente, id_articulo, fecha, cantidad, importe, estado)
	VALUES (1, 9, CURRENT_DATE, 5, (2819.44)*5, 'PAGADO');
COMMIT;

--- EJERCICIO 2
SELECT descripcion, precio_unitario,stock
FROM articulos WHERE id_articulo = 3;
SELECT saldo FROM billetera_clientes
WHERE id_cliente = 7;
SELECT COUNT(id_cliente) AS cant FROM pedidos
WHERE id_cliente = 7 AND id_articulo = 3;

BEGIN;
	-- se agrega el pedido en la lista de pedidos
	INSERT INTO pedidos (id_cliente, id_articulo, fecha, cantidad, importe, estado)
	VALUES (7, 3, CURRENT_DATE, 4, (20180.60)*4, 'PAGADO');
	-- se descuenta el stock del producto
	UPDATE articulos
	SET stock = stock - 4
	WHERE id_articulo = 3;
	-- se cobra el monto del pedido al cliente
	UPDATE billetera_clientes
	SET saldo = saldo - (20180.60)*4
	WHERE id_cliente = 7;
COMMIT;
-- como no se puede completar la transaccion,
-- porque el saldo del cliente no alcanza para
-- el monto requerido del pedido, el proceso se 
-- bloquea por falta de saldo y se hace rollback
ROLLBACK;

--- EJERCICIO 3
SELECT descripcion, precio_unitario,stock
FROM articulos WHERE id_articulo = 3;
SELECT saldo FROM billetera_clientes
WHERE id_cliente = 7;
SELECT COUNT(id_cliente) AS cant FROM pedidos
WHERE id_cliente = 7 AND id_articulo = 3;

BEGIN;
	-- se agrega el pedido en la lista de pedidos
	INSERT INTO pedidos (id_cliente, id_articulo, fecha, cantidad, importe, estado)
	VALUES (7, 3, CURRENT_DATE, 4, (20180.60)*4, 'PAGADO');
	-- se descuenta el stock del producto
	UPDATE articulos
	SET stock = stock - 4
	WHERE id_articulo = 3;
	-- se cobra el monto del pedido al cliente
	UPDATE billetera_clientes
	SET saldo = saldo - (20180.60)*4
	WHERE id_cliente = 7;
COMMIT;

--- EJERCICIO 4
BEGIN;
	-- elimino todos los pedidos del cliente con id 5
	DELETE FROM pedidos
	WHERE id_cliente = 5 RETURNING *;
	-- elimino la billetera virtual del cliente con id 5
	DELETE FROM billetera_clientes
	WHERE id_cliente = 5 RETURNING *;
	-- elimino el cliente con id 5 de la lista clientes
	DELETE FROM clientes
	WHERE id_cliente = 5 RETURNING *;
COMMIT;

--- EJERCICIO 5
SELECT COUNT(id_articulo) FROM articulos
WHERE categoria = 'Electrónica';
SELECT categoria FROM articulos;

BEGIN;
	-- actualizo el precio un 20% de los articulos de la categoria Eletrónica
	UPDATE articulos
	SET precio_unitario = precio_unitario * 1.2
	WHERE categoria = 'Electrónica';
COMMIT;
-- no hace nada, porque no existen articulos de la categoria Eletrónica

--- EJERCICIO 6
-- venta 1
BEGIN;
	UPDATE articulos
	SET stock = stock - 1
	WHERE id_articulo = 5;
COMMIT;

-- al hacer el COMMIT de esta transaccion
-- la segunda que estaba en espera se completa
-- lanzando un error, porque no hay mas stock
-- para descontar

-- venta 2
UPDATE articulos
SET stock = stock - 1
WHERE id_articulo = 5;
-- la consulta se queda esperando
-- indefinidamente, porque se esta esperando
-- a que ejecute el COMMIT de la transaccion
-- en ejecucion