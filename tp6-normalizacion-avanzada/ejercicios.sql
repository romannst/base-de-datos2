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