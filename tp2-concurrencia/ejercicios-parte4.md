# PROTOCOLO DE BLOQUEO EN 2 FASES (B2F)

TRANSACCION

T1
Bloquear_Exclusivo(A)
Leer(A)
A := A - 50
Escribir(A)
Desbloquear(A)
Bloquear_Exclusivo(B) <=== no cumple
Leer(B)
B := B + 50
Escribir(B)
Desbloquear(B)

No cumple con el Protocolo de Bloqueo en Dos Fases (B2F), porque todas las operaciones de bloqueo no preceden a la primera operación de desbloqueo. Al comienzo de la transacción T1 se bloquea A, se actualiza y se desbloquea, pero luego se bloquea B lo cual no cumple con la condición.

Por lo tanto, la fase de expansión y contracción no se respetan al no bloquear todos los datos a modificar (1F) para después desbloquearlos (2F).

TRANSACCION QUE CUMPLE EL PROTOCOLO DE BLOQUEO EN 2 FASES (B2F):

T1
// fase de expansión
Bloquear_Exclusivo(A)
Bloquear_Exclusivo(B)
Leer(A)
A := A - 50
Escribir(A)
Leer(B)
B := B + 50
Escribir(B)
// fase de contracción
Desbloquear(A)
Desbloquear(B)

La T1 es B2F conservador, porque declara y bloquea todos los elementos a modificar antes de ejecutarse.