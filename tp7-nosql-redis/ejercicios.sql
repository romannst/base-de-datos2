-- MISION 1
-- Transacción SQL para realizar la operación de forma segura
BEGIN;
SELECT saldo FROM usuarios WHERE id_usuario = 1 FOR UPDATE;
UPDATE usuarios SET id_plan = (
SELECT id_plan FROM planes WHERE nombre = 'Premium'
), saldo = saldo - 2000 WHERE id_usuario = 1 AND saldo >= 2000;
COMMIT;
-- No recomendaría utilizar REDIS para almacenar y descontar el saldo del usuario en lugar de PostgreSQL, porque este cache se almacena en memoria y no garantiza las propiedades ACID, por ejemplo en caso de un corte de energía ,un fallo del sistema o transacciones concurrentes, los datos almacenados en Redis podrían perderse o corromperse. Por lo tanto, es más seguro y confiable utilizar PostgreSQL para manejar las transacciones y mantener la integridad de los datos.

-- MISION 2
-- Consulta SQL para obtener los 5 contenidos más vistos
SELECT c.titulo, SUM(hr.minutos_vistos) AS minutos_vistos FROM contenidos AS c
JOIN historial_reproducciones AS hr ON c.id_contenido = hr.id_contenido
GROUP BY c.titulo ORDER BY minutos_vistos DESC LIMIT 5;
-- Respuesta a la consulta SQL:
1 "Contenido 511"	198273
2 "Contenido 440"	197145
3 "Contenido 556"	194000
4 "Contenido 295"	193217
5 "Contenido 786"	193149
-- Implementación del patrón Cache-Aside con Redis:
-- Almacenar los resultados en Redis con una clave y tiempo de expiración
SET contenidos_mas_vistos "Contenido_440:197145, Contenido_556:194000, Contenido_295:193217, Contenido_786:193149" EX 600
-- Le asigne un TTL de 10 minutos (600 segundos), porque en este tipo de escenarios donde se presenta una masiva cantidad de usuarios accediendo a los mismos datos (al abrir la app) es importante mantener la información actualizada, pero también es necesario evitar consultas constantes a la base de datos, por lo que un TTL de 10 minutos es un buen equilibrio entre el rendimiento del sistema y la consistencia de los datos.
-- Implementacion con Sorted Set de Redis:
ZADD contenidos_mas_vistos 198273 "Contenido_511"
ZADD contenidos_mas_vistos 197145 "Contenido_440"
ZADD contenidos_mas_vistos 194000 "Contenido_556"
ZADD contenidos_mas_vistos 193217 "Contenido_295"
ZADD contenidos_mas_vistos 193149 "Contenido_786"
-- Asignar un TTL de 10 minutos (600 segundos) al Sorted Set
EXPIRE contenidos_mas_vistos 600
-- Obtener los 5 contenidos más vistos utilizando el Sorted Set
ZRANGE contenidos_mas_vistos 0 4 WITHSCORES

-- MISION 3