-- MISION 1
-- creo la tabla de licencias temporales e inserto datos
CREATE TABLE licencias_temporales (
id_contenido INT,
estudio_productor VARCHAR(100),
pais_licencia VARCHAR(50),
email_contacto_estudio VARCHAR(150),
PRIMARY KEY (id_contenido, pais_licencia)
);
INSERT INTO licencias_temporales VALUES
(1, 'Warner', 'Argentina', 'legal@warner.com'),
(1, 'Warner', 'Brasil', 'legal@warner.com'),
(2, 'Warner', 'Chile', 'legal@warner.com'),
(3, 'Universal', 'Argentina', 'rights@uni.com');
-- Basándote en la teoría de la Forma Normal de Boyce-Codd, explica por qué esta tabla viola BCNF. Identifica cuál es el "Determinante" y por qué no es una Clave Candidata.
-- La tabla "licencias_temporales" rompe BCNF porque el determinante "estudio_productor" no es una clave candidata. Esto se debe a que "estudio_productor" no puede identificar de manera única cada fila en la tabla, ya que un mismo estudio puede tener múltiples licencias en diferentes países.
-- Escribe el código SQL para descomponer esta tabla en dos tablas nuevas correctamente normalizadas (ej: estudios y licencias_contenidos)
-- Creo la tabla de estudios
CREATE TABLE estudios (
	estudio_productor VARCHAR(100) PRIMARY KEY,
	email_contacto_estudio VARCHAR(150)
);
-- Creo la tabla de licencias_contenidos
CREATE TABLE licencias_contenidos (
	id_contenido INT,
	estudio_productor VARCHAR(100),
	pais_licencia VARCHAR(50),
	PRIMARY KEY (id_contenido, estudio_productor),
    FOREIGN KEY (estudio_productor) REFERENCES estudios(estudio_productor)
);
-- Inserto los datos en la tabla de estudios
INSERT INTO estudios VALUES
('Warner', 'legal@warner.com'),
('Universal', 'rights@uni.com');
-- Inserto los datos en la tabla de licencias_contenidos
INSERT INTO licencias_contenidos VALUES
(1, 'Warner', 'Argentina'),
(1, 'Warner', 'Brasil'),
(2, 'Warner', 'Chile'),
(3, 'Universal', 'Argentina');

-- MISION 2
-- Escenario:
CREATE TABLE actor_info (
id_actor INT,
nombre VARCHAR(100),
pelicula_actuada VARCHAR(100),
idioma_hablado VARCHAR(50),
PRIMARY KEY (id_actor, pelicula_actuada, idioma_hablado)
);
-- Pedro Pascal actúa en 2 películas y habla 2 idiomas. (Resultado: 4 filas)
INSERT INTO actor_info VALUES
(1, 'Pedro Pascal', 'The Last of Us', 'Ingles'),
(1, 'Pedro Pascal', 'The Last of Us', 'Español'),
(1, 'Pedro Pascal', 'Narcos', 'Ingles'),
(1, 'Pedro Pascal', 'Narcos', 'Español');
-- Una dependencia multivaluada (MVD) es una relación de una entidad con múltiples conjuntos de datos, en este caso ocurre que un actor actúa en varias películas y habla varios idiomas, lo que hace que se generen filas repetidas para cada combinación de película e idioma.
-- Diseño respetando la cuarta forma normal (4NF)
CREATE TABLE actor (
	id_actor INT PRIMARY KEY,
	nombre_actor VARCHAR(100)
);
CREATE TABLE actor_peliculas (
	id_actor INT,
	pelicula_actuada VARCHAR(100),
	PRIMARY KEY (id_actor, pelicula_actuada),
	FOREIGN KEY (id_actor) REFERENCES actor(id_actor)
);
CREATE TABLE actor_idiomas (
	id_actor INT,
	idioma_hablado VARCHAR(50),
	PRIMARY KEY (id_actor, idioma_hablado),
	FOREIGN KEY (id_actor) REFERENCES actor(id_actor)
);
-- Inserto los datos en las tablas normalizadas
INSERT INTO actor VALUES
(1, 'Pedro Pascal');
INSERT INTO actor_peliculas VALUES
(1, 'The Last of Us'), (1, 'Narcos');
INSERT INTO actor_idiomas VALUES
(1, 'Español'), (1, 'Ingles');
-- Se insertan en total 5 filas, una en la tabla "actor" para Pedro Pascal, dos en la tabla "actor_peliculas" para las películas en las que actúa, y dos en la tabla "actor_idiomas" para los idiomas que habla.

-- MISION 3
DELETE FROM usuarios WHERE id_usuario = 1;
-- Si se ejecuta ese comando, el motor de base de datos lanza un error de integridad referencial, porque la tabla "usuarios" tiene una relacion FK con la tabla "historial_reporducciones" por lo cual dejaría las filas relacionadas sin un usuario asociado, lo que viola la integridad de los datos.
-- Si se busca limpiar los datos de un usuario eliminado se debería utilizar ON DELETE CASCADE en la definición de la clave foránea en la tabla "historial_reporducciones", de esta manera al eliminar un usuario, automáticamente se eliminarían todas las filas relacionadas en el historial de reproducciones, manteniendo la integridad referencial.
-- Por otro lado, si se quieren mantener los datos del historial de reproducción de un usuario eliminado para análisis o estadísticas se debería utilizar ON DELETE SET NULL, lo que dejaría un valor nulo en la columna de id_usuario en el historial de reproducciones, indicando que el usuario ya no existe pero manteniendo los datos para su análisis.
-- Vamos a aplicar esta última opcion:
-- la constraint actual en la tabla "historial_reporducciones" es: historial_reproducciones_id_usuario_fkey
-- primero eliminamos la constraint actual
ALTER TABLE historial_reporducciones
DROP CONSTRAINT historial_reproducciones_id_usuario_fkey;
-- luego agregamos la nueva constraint con ON DELETE SET NULL
ALTER TABLE historial_reporducciones
ADD CONSTRAINT historial_reproducciones_id_usuario_fkey
FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
ON DELETE SET NULL;

-- MISION 4
--El área de gerencia quiere un Dashboard en tiempo real que muestre: Email del Usuario, Nombre del Plan que posee, y la Suma total de minutos vistos en su vida.
-- Indices para optimizar las consultas
CREATE INDEX idx_usuario ON usuarios(id_usuario);
CREATE INDEX idx_usuario_plan ON usuarios (id_plan);
CREATE INDEX idx_plan ON planes(id_plan);
CREATE INDEX idx_historial_repr_usuario ON historial_reproducciones(id_usuario);
-- Vista materializada para optimizar la consulta del dashboard
CREATE MATERIALIZED VIEW email_plan_totalmins AS
SELECT u.email AS usuario_email,
p.nombre AS nombre_plan,
SUM(hr.minutos_vistos) AS total_minutos
FROM usuarios AS u JOIN planes AS p ON u.id_plan = p.id_plan
JOIN historial_reproducciones AS hr ON u.id_usuario = hr.id_usuario
GROUP BY u.email, p.nombre;
-- Actualizamos la vista materializada para que refleje los datos actuales
REFRESH MATERIALIZED VIEW email_plan_totalmins;
-- Consulta para el dashboard
SELECT * FROM email_plan_totalmins;
-- ¿Por qué en un entorno transaccional (OLTP) es preferible usar una Vista Materializada en lugar de agregarle una columna minutos_totales_historicos a la tabla usuarios y actualizarla cada vez que el usuario ve una película?
-- En un entorno transaccional (OLTP), es preferible usar una Vista Materializada en lugar de agregar una columna "minutos_totales_historicos" a la tabla "usuarios", porque ofrece un mejor rendimiento, mantiene la integridad de los datos y proporciona mayor flexibilidad en comparación con agregar una columna de minutos totales a la tabla "usuarios", la cual generaría problemas de rendimiento y consistencia debido a la necesidad de actualizar constantemente esa columna cada vez que un usuario ve una película.