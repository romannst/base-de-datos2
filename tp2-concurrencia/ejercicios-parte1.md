# 1
Transacción: secuencia de instrucciones (sentencias SQL) relacionadas, que deben ser tratadas como una unidad indivisible.
# 2
Para asegurar la integridad de los datos se necesita que el sistema de base de datos mantenga las propiedades ACID de las transacciones: atomicidad, consistencia, aislamiento (isolation), durabilidad.
● Atomicidad: se ejecutan todas las operaciones que contiene la transacción o no se ejecuta ninguna.
● Consistencia: la ejecución aislada de la transacción (es decir, sin otra transacción que se ejecute concurrentemente) conserva la consistencia de la base de datos.
● Aislamiento (isolation): Aunque se ejecuten varias transacciones concurrentemente, el sistema garantiza que para cada par de transacciones Ti y Tj, se cumple que para los efectos de Ti, o bien Tj ha terminado su ejecución antes de que comience Ti, o bien que Tj ha comenzado su ejecución después de que Ti termine. De este modo, cada transacción ignora al resto de las transacciones que se ejecuten concurrentemente en el sistema.
○ T no muestra los cambios hasta que finaliza
○ Ti nunca debe ver las fases intermedias de otra Tj
● Durabilidad: Tras la finalización con éxito de una transacción, los cambios realizados en la base de datos permanecen, incluso si hay fallos en el sistema.
# 3
Planificación: Son secuencias de ejecución y representan el orden cronológico en el que se ejecutan las instrucciones de transacciones concurrentes en el sistema.
Planificación en serie: Una planificación en serie es aquella donde una transacción se ejecuta completamente antes que la otra.
Planificación en serializable: Una planificación que produce el mismo resultado que alguna planificación en serie.
Equivalencia entre planificaciones: Dos planificaciones son equivalentes si producen el mismo resultado final sobre los datos.