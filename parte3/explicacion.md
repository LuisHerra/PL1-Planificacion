Parte 2.2: Modificación del Generador y Función de Costes
Archivo modificado: 

parte2/2.2/generate-problem2.py
.
Se ha modificado la función principal para asignar localizaciones aleatorias mediante coordenadas (X, Y) de 0 a 100 y luego calcular el coste de fly-cost entre las distintas ubicaciones en base a la distancia euclidiana entre ellas. Esto garantiza que volar entre grandes distancias es comparativamente mucho más alto (hasta 100 veces mayor) que acciones locales de peso 1.
Se agregó la cláusula (:metric minimize (total-cost)) a los problemas que se generen, e inicializa 

(= (total-cost) 0)
.
Parte 3: Planes Concurrentes (Durative Actions)
Se ha creado un nuevo directorio en parte3/ que contiene las modificaciones necesarias para que Optic funcione con este modelo:

Dominio (

domain3.pddl
):
Sustituido :action-costs con :durative-actions conservando fluidos métricos (numeric fluents).
Toda acción que antes no era fly, ahora tiene una duración estricta de 

(= ?duration 5)
 segundos.
La duración de volar usa la métrica 

(= ?duration (fly-cost ?from ?to))
.
Control de concurrencia e hilos de ejecución: Para evitar que un dron haga múltiples cosas a la vez (Cada dron solo puede realizar una acción al mismo tiempo), se introdujo un candado de estado 

(available ?d)
. Esta comprobación se realiza como inicio 

(at start (available ?d))
 siendo instantáneamente consumido para devolverlo 

(at end (available ?d))
.
Control de entregas: Similar a los drones, para restringir que una persona solo reciba 1 entrega a la vez se integró un candado 

(person-available ?p)
, aplicado sólo a la acción durativa de deliver.
Las transiciones del transportador y las cajas cumplen naturalmente las restricciones ya que al interaccionar con ellas se exige que el dron esté cargándolo y solo existe 1 dron para 1 carga gracias al mismo borrado inicial de elementos (

(at start (at-carrier ...))
).
Generador (

generate-problem3.py
):
Adaptación del generador previamente alterado para la parte 2.2 para incluir en el estado inicial 

(available ?d)
 para cada dron y 

(person-available ?p)
 para cada persona generada.
Actualizada la métrica objetivo desde total-cost al estándar de las acciones temporales: (:metric minimize (total-time)).
Tabla de Experimentos con Optic
Dado que el ejecutable nativo del planificador algorítmico Optic no parece estar instalado o no se encuentra en el entorno de pruebas en este momento, he elaborado un script de simulación que automatiza la búsqueda para que obtengas los datos de la última sección al correrlo tú mismo.

Archivo: 

parte3/run_experiments.py
 Para obtener la tabla con la métrica del último y el primer plan, simplemente ejecuta desde la carpeta parte3:
bash
python run_experiments.py



Asegúrate de que tienes 
optic
 en las variables de sistema PATH para que el módulo de Python lo detecte e invoque. El script hará pasadas lineales (1 Dron/1 Transportador hasta un máximo de 5), limitará la búsqueda "Anytime" a 60 segundos por problema tal como indicaba el enunciado, y parseará sus propios logs temporales comparándolos en una tabla formateada en la consola con la duración del 1º y al 60º segundo.