# A=1000, B=500 y C=0

# I. EN SERIE
PLANIFICACION A
T1
A = 1000
A = 1000 * 2
A = 2000

T2
C = 100
B = 500
B = 500 - 100
B = 400
A = 2000 (lee el valor de A escrito durante T1)
A = 2000 + 400
A = 2400

Resulta A = 2400, B = 400 y C = 100

PLANIFICACION B
T1
A = 1000
A = 1000 * 2
A = 2000

T2
C = 100
B = 500
B = 500 - 100
B = 400
A = 2000 (lee el calor de A escrito durante T1)
A = 2000 + 400
A = 2400

Resulta A = 2400, B = 400 y C = 100

# II. EN SERIE
PLANIFICACION A
T2
C = 100
B = 500
B = 500 - 100
B = 400
A = 1000
A = 1000 + 400
A = 1400

T1
A = 1400
A = 1400 * 2
A = 2800

Resulta A = 2800, B = 400 y C = 100

PLANIFICACION B
T2
C = 100
B = 500
B = 500 - 100
B = 400
A = 1000
A = 1000 + 400
A = 1400

T1
A = 1400
A = 1400 * 2
A = 2800

Resulta A = 2800, B = 400 y C = 100

# III. CONCURRENTE
PLANIFICACION A
T1
A = 1000
T2
C = 100
B = 500
B = 500 - 100
B = 400
A = 1000
A = 1000 + 400
A = 1400 (se pierde este valor porque T1 lee A al principio y cuando vuelve en ejecucion no vuelve a leer el valor actualizado por T2 por lo que mantiene un valor de A viejo)
T1
A = 1000 * 2
A = 2000

Resulta A = 2000, B = 400 y C = 100

# IV. CONCURRENTE
PLANIFICACION B
T1
A = 1000
T2
C = 100
B = 500
B = 500 - 100
B = 400
T1
A = 1000 * 2
A = 2000
T2
A = 2000
A = 2000 + 400
A = 2400

Resulta A = 2400, B = 400 y C = 100

# V
- La planificacion A no es serializable, porque no coincide con ninguna ejecucion en serie
- La planificacion B es serializable, porque coincide con la ejecucion en serie T1 -> T2