(defdomain emergency-advanced
  (

   ;; ================================================================
   ;; OPERADORES PRIMITIVOS
   ;; ================================================================
   ;; Los operadores reflejan directamente las acciones del dominio
   ;; PDDL de referencia, adaptados a fluents numéricos de SHOP2.
   ;; Formato: (:operator (nombre args) precondiciones delete add)
   ;; El coste se declara como quinto elemento opcional.
   ;; ================================================================

   ;; ---------------------------------------------------------------
   ;; !FLY  — mover el dron (sin transportador)
   ;; Coste base 50. No hay coste adicional por capacidad porque
   ;; el dron no lleva transportador.
   ;; ---------------------------------------------------------------
   (:operator (!fly ?d ?from ?to)
              ((at-drone ?d ?from)
               (different ?from ?to))
              ((at-drone ?d ?from))
              ((at-drone ?d ?to))
              50)

   ;; ---------------------------------------------------------------
   ;; !FLY-CARRIER  — mover el dron llevando un transportador
   ;; Coste = 50 + capacidad(?ca) / 10
   ;; En SHOP2 el coste es una expresión numérica evaluada en tiempo
   ;; de planificación: (+ 50 (/ (call capacity ?ca) 10))
   ;; Usamos el fluent (carrier-capacity ?ca) directamente.
   ;; ---------------------------------------------------------------
   (:operator (!fly-carrier ?d ?ca ?from ?to)
              ((at-drone ?d ?from)
               (carrying ?d ?ca)
               (different ?from ?to))
              ((at-drone ?d ?from))
              ((at-drone ?d ?to))
              (+ 50 (/ (carrier-capacity ?ca) 10)))

   ;; ---------------------------------------------------------------
   ;; !PICK-UP-CARRIER  — el dron coge un transportador del suelo
   ;; ---------------------------------------------------------------
   (:operator (!pick-up-carrier ?d ?ca ?l)
              ((at-drone ?d ?l)
               (at-carrier ?ca ?l)
               (drone-free ?d))
              ((at-carrier ?ca ?l))
              ((carrying ?d ?ca)))

   ;; ---------------------------------------------------------------
   ;; !DROP-CARRIER  — el dron suelta el transportador en el suelo
   ;; ---------------------------------------------------------------
   (:operator (!drop-carrier ?d ?ca ?l)
              ((at-drone ?d ?l)
               (carrying ?d ?ca))
              ((carrying ?d ?ca))
              ((at-carrier ?ca ?l)))

   ;; ---------------------------------------------------------------
   ;; !LOAD-CRATES  — cargar N cajas de tipo ?t en el transportador
   ;; Reduce (location-stock ?l ?t) y (carrier-free-space ?ca)
   ;; en ?n unidades simultáneamente.
   ;; Precondición: hay suficiente stock y suficiente espacio libre.
   ;; ---------------------------------------------------------------
   (:operator (!load-crates ?d ?ca ?l ?t ?n)
              ((at-drone ?d ?l)
               (carrying ?d ?ca)
               (>= (location-stock ?l ?t) ?n)
               (>= (carrier-free-space ?ca) ?n)
               (> ?n 0))
              ()
              ((location-stock ?l ?t) (- (location-stock ?l ?t) ?n)
               (carrier-stock ?ca ?t) (+ (carrier-stock ?ca ?t) ?n)
               (carrier-free-space ?ca) (- (carrier-free-space ?ca) ?n)))

   ;; ---------------------------------------------------------------
   ;; !DELIVER-FROM-CARRIER  — entregar ?n cajas de tipo ?t a loc ?l
   ;; Reduce (location-need ?l ?t) y (carrier-stock ?ca ?t)
   ;; ---------------------------------------------------------------
   (:operator (!deliver-from-carrier ?d ?ca ?l ?t ?n)
              ((at-drone ?d ?l)
               (carrying ?d ?ca)
               (>= (carrier-stock ?ca ?t) ?n)
               (>= (location-need ?l ?t) ?n)
               (> ?n 0))
              ()
              ((carrier-stock ?ca ?t) (- (carrier-stock ?ca ?t) ?n)
               (carrier-free-space ?ca) (+ (carrier-free-space ?ca) ?n)
               (location-need ?l ?t) (- (location-need ?l ?t) ?n)))

   ;; ---------------------------------------------------------------
   ;; !PICK-UP-LOOSE  — recoger una caja suelta del suelo (sin carrier)
   ;; ---------------------------------------------------------------
   (:operator (!pick-up-loose ?d ?l ?t)
              ((at-drone ?d ?l)
               (drone-free ?d)
               (> (location-stock ?l ?t) 0))
              ()
              ((location-stock ?l ?t) (- (location-stock ?l ?t) 1)
               (drone-holding-type ?d) ?t
               (drone-holding-count ?d) 1)
              ;; quitamos drone-free vía assign implícito:
              ;; usamos (drone-free ?d) en delete explícito
              )

   ;; SHOP2 no tiene delete list en operadores con assign; la
   ;; marcamos como predicado aparte para (drone-free):
   (:operator (!set-drone-busy ?d)
              ((drone-free ?d))
              ((drone-free ?d))
              ())

   (:operator (!set-drone-free ?d)
              ()
              ()
              ((drone-free ?d)))

   ;; ---------------------------------------------------------------
   ;; !DELIVER-LOOSE  — entregar la caja suelta que el dron lleva
   ;; ---------------------------------------------------------------
   (:operator (!deliver-loose ?d ?l ?t)
              ((at-drone ?d ?l)
               (drone-holding-type ?d ?t)
               (> (drone-holding-count ?d) 0)
               (> (location-need ?l ?t) 0))
              ()
              ((drone-holding-count ?d) (- (drone-holding-count ?d) 1)
               (location-need ?l ?t) (- (location-need ?l ?t) 1)))


   ;; ================================================================
   ;; MÉTODOS AUXILIARES
   ;; ================================================================

   ;; ---------------------------------------------------------------
   ;; (volver-a-depot ?d ?ca-or-none)
   ;; Versión con transportador y sin transportador.
   ;; ---------------------------------------------------------------
   (:method (volver-a-depot ?d)
            ya-en-depot
            ((at-drone ?d depot))
            ())

   (:method (volver-a-depot ?d)
            con-carrier
            ((at-drone ?d ?loc)
             (different ?loc depot)
             (carrying ?d ?ca))
            ((!fly-carrier ?d ?ca ?loc depot)))

   (:method (volver-a-depot ?d)
            sin-carrier
            ((at-drone ?d ?loc)
             (different ?loc depot))
            ((!fly ?d ?loc depot)))

   ;; ---------------------------------------------------------------
   ;; (total-need ?l)  — suma de necesidades de una localización
   ;; Usada para comparar prioridades. SHOP2 permite call a funciones
   ;; externas; aquí lo expresamos como fluent precomputado
   ;; (location-total-need ?l) que se actualiza con cada entrega.
   ;; ---------------------------------------------------------------

   ;; ---------------------------------------------------------------
   ;; (elegir-carrier ?d ?l)
   ;; Selecciona el transportador óptimo para atender ?l.
   ;; Jerarquía de decisión (orden de métodos = prioridad):
   ;;   1. Varios carriers: existe uno que cubre exactamente o supera
   ;;      la necesidad → elegir el MENOR que cubra.
   ;;   2. Varios carriers: ninguno cubre → elegir el MAYOR.
   ;;   3. Un único carrier disponible → usarlo.
   ;;   4. No hay carriers → no hacer nada (modo suelto).
   ;; ---------------------------------------------------------------

   ;; Caso 1: hay carrier que cubre la necesidad total de ?l;
   ;; entre los que cubren, elegimos el de menor capacidad.
   ;; La condición (best-covering-carrier ?l ?ca) se resuelve
   ;; por el método (seleccionar-carrier-minimo-suficiente).
   (:method (elegir-carrier ?d ?l)
            carrier-cubre-necesidad
            ((at-drone ?d depot)
             (at-carrier ?ca depot)
             (drone-free ?d)
             (>= (carrier-capacity ?ca) (location-total-need ?l))
             ;; no existe otro carrier con menor capacidad que también cubra
             (not (and (at-carrier ?ca2 depot)
                       (different ?ca2 ?ca)
                       (>= (carrier-capacity ?ca2) (location-total-need ?l))
                       (< (carrier-capacity ?ca2) (carrier-capacity ?ca)))))
            ((!pick-up-carrier ?d ?ca depot)))

   ;; Caso 2: ningún carrier individual cubre la necesidad → el mayor
   (:method (elegir-carrier ?d ?l)
            carrier-no-cubre-usar-mayor
            ((at-drone ?d depot)
             (at-carrier ?ca depot)
             (drone-free ?d)
             (< (carrier-capacity ?ca) (location-total-need ?l))
             ;; no existe otro carrier con mayor capacidad en depot
             (not (and (at-carrier ?ca2 depot)
                       (different ?ca2 ?ca)
                       (> (carrier-capacity ?ca2) (carrier-capacity ?ca)))))
            ((!pick-up-carrier ?d ?ca depot)))

   ;; Caso 3: no hay carriers disponibles → el dron trabajará en modo suelto
   (:method (elegir-carrier ?d ?l)
            sin-carriers
            ((at-drone ?d depot)
             (not (at-carrier ?ca depot)))
            ())

   ;; ---------------------------------------------------------------
   ;; (cargar-para-loc ?d ?ca ?l)
   ;; Carga en ?ca todas las cajas necesarias para ?l,
   ;; respetando el espacio libre del carrier.
   ;; Itera sobre tipos de contenido (food, medicine).
   ;; ---------------------------------------------------------------

   ;; Hay necesidad de tipo ?t y caben cajas: cargar min(need, space, stock)
   (:method (cargar-para-loc ?d ?ca ?l ?t)
            cargar-tipo
            ((at-drone ?d depot)
             (carrying ?d ?ca)
             (> (location-need ?l ?t) 0)
             (> (carrier-free-space ?ca) 0)
             (> (location-stock depot ?t) 0))
            ;; cargamos el mínimo entre necesidad, espacio y stock
            ((!load-crates ?d ?ca depot ?t
               (min (location-need ?l ?t)
                    (min (carrier-free-space ?ca)
                         (location-stock depot ?t)))))
            )

   ;; No hay necesidad o no hay espacio: fin de carga para este tipo
   (:method (cargar-para-loc ?d ?ca ?l ?t)
            carga-completa
            ()
            ())

   ;; Wrapper que itera sobre todos los tipos
   (:method (cargar-todo-para-loc ?d ?ca ?l)
            cargar-ambos-tipos
            ()
            ((cargar-para-loc ?d ?ca ?l food)
             (cargar-para-loc ?d ?ca ?l medicine)))

   ;; ---------------------------------------------------------------
   ;; (entregar-en-loc ?d ?ca ?l)
   ;; Entrega todas las cajas cargadas para ?l.
   ;; Si queda algo después del carrier, lo entrega suelto.
   ;; ---------------------------------------------------------------
   (:method (entregar-en-loc ?d ?ca ?l)
            entregar-con-carrier
            ((at-drone ?d ?l)
             (carrying ?d ?ca)
             (> (+ (carrier-stock ?ca food) (carrier-stock ?ca medicine)) 0))
            ((entregar-tipo-carrier ?d ?ca ?l food)
             (entregar-tipo-carrier ?d ?ca ?l medicine)))

   (:method (entregar-en-loc ?d ?ca ?l)
            nada-que-entregar
            ()
            ())

   (:method (entregar-tipo-carrier ?d ?ca ?l ?t)
            hay-stock-tipo
            ((at-drone ?d ?l)
             (carrying ?d ?ca)
             (> (carrier-stock ?ca ?t) 0)
             (> (location-need ?l ?t) 0))
            ((!deliver-from-carrier ?d ?ca ?l ?t
               (min (carrier-stock ?ca ?t) (location-need ?l ?t)))))

   (:method (entregar-tipo-carrier ?d ?ca ?l ?t)
            sin-stock-tipo
            ()
            ())

   ;; ---------------------------------------------------------------
   ;; (entregar-suelto-en-loc ?d ?l)
   ;; Para el caso sin carrier o para restos post-carrier.
   ;; ---------------------------------------------------------------
   (:method (entregar-suelto-en-loc ?d ?l ?t)
            hay-necesidad-y-stock
            ((at-drone ?d ?l)
             (> (location-need ?l ?t) 0)
             (> (location-stock depot ?t) 0))
            ;; volver a depot, coger una caja suelta, volver, entregar
            ((volver-a-depot ?d)
             (!pick-up-loose ?d depot ?t)
             (!set-drone-busy ?d)
             (!fly ?d depot ?l)
             (!deliver-loose ?d ?l ?t)
             (!set-drone-free ?d)
             (entregar-suelto-en-loc ?d ?l ?t)))

   (:method (entregar-suelto-en-loc ?d ?l ?t)
            necesidad-cubierta
            ()
            ())

   ;; ---------------------------------------------------------------
   ;; (atender-localizacion ?d ?l)
   ;; Orquesta el ciclo completo para una localización:
   ;;   1. Elegir carrier (o modo suelto)
   ;;   2. Cargar para ?l (y posiblemente más localizaciones)
   ;;   3. Volar a ?l
   ;;   4. Entregar
   ;;   5. Si sobran cajas sueltas de restos, entregarlas
   ;; ---------------------------------------------------------------

   ;; Con carrier: carga, vuela, entrega, gestiona restos sueltos
   (:method (atender-localizacion ?d ?l)
            con-carrier-disponible
            ((at-drone ?d depot)
             (at-carrier ?ca depot)
             (> (location-total-need ?l) 0))
            ((elegir-carrier ?d ?l)
             (cargar-todo-para-loc ?d ?ca ?l)
             (!fly-carrier ?d ?ca depot ?l)
             (entregar-en-loc ?d ?ca ?l)
             (volver-a-depot ?d)
             (!drop-carrier ?d ?ca depot)))

   ;; Sin carrier: modo suelto caja a caja
   (:method (atender-localizacion ?d ?l)
            sin-carrier-disponible
            ((at-drone ?d depot)
             (not (at-carrier ?ca depot))
             (> (location-total-need ?l) 0))
            ((entregar-suelto-en-loc ?d ?l food)
             (entregar-suelto-en-loc ?d ?l medicine)))

   ;; ---------------------------------------------------------------
   ;; (atender-multi-loc ?d ?ca ?locs)
   ;; Si el carrier tiene capacidad para varias localizaciones,
   ;; carga para todas y las atiende en un mismo viaje (sin volver
   ;; al depot entre localizaciones).
   ;; Se activa cuando la necesidad total de ?l1 + ?l2 <= capacidad carrier.
   ;; ---------------------------------------------------------------
   (:method (atender-multi-loc ?d ?ca ?l1 ?l2)
            carrier-cubre-ambas
            ((at-drone ?d depot)
             (carrying ?d ?ca)
             (>= (carrier-capacity ?ca)
                 (+ (location-total-need ?l1) (location-total-need ?l2)))
             (> (location-total-need ?l1) 0)
             (> (location-total-need ?l2) 0))
            ((cargar-todo-para-loc ?d ?ca ?l1)
             (cargar-todo-para-loc ?d ?ca ?l2)
             (!fly-carrier ?d ?ca depot ?l1)
             (entregar-en-loc ?d ?ca ?l1)
             (!fly-carrier ?d ?ca ?l1 ?l2)
             (entregar-en-loc ?d ?ca ?l2)
             (volver-a-depot ?d)
             (!drop-carrier ?d ?ca depot)))

   ;; ================================================================
   ;; MÉTODO RAÍZ: (enviar-todo)
   ;; Lógica de priorización:
   ;;   1. Si hay dos localizaciones y un carrier que cubre ambas →
   ;;      multi-loc en un viaje.
   ;;   2. Si hay una o más localizaciones → atender la de MAYOR
   ;;      necesidad total primero.
   ;;   3. Base: no quedan necesidades.
   ;; ================================================================

   ;; Caso multi-loc: dos locs con carrier que las cubre juntas.
   ;; ?l1 tiene mayor o igual necesidad que ?l2.
   (:method (enviar-todo)
            multi-loc-posible
            ((at-drone ?d depot)
             (drone-free ?d)
             (location-total-need ?l1)
             (location-total-need ?l2)
             (different ?l1 ?l2)
             (different ?l1 depot)
             (different ?l2 depot)
             (> (location-total-need ?l1) 0)
             (> (location-total-need ?l2) 0)
             (>= (location-total-need ?l1) (location-total-need ?l2))
             (at-carrier ?ca depot)
             (>= (carrier-capacity ?ca)
                 (+ (location-total-need ?l1) (location-total-need ?l2))))
            ((elegir-carrier ?d ?l1)
             (atender-multi-loc ?d ?ca ?l1 ?l2)
             (enviar-todo)))

   ;; Caso normal: atender la localización con mayor necesidad.
   ;; Garantizamos que ?l es la de mayor necesidad usando NOT EXISTS
   ;; de otra loc con mayor need.
   (:method (enviar-todo)
            hay-necesidades
            ((at-drone ?d depot)
             (drone-free ?d)
             (> (location-total-need ?l) 0)
             (different ?l depot)
             ;; no existe otra loc con mayor necesidad
             (not (and (location-total-need ?l2)
                       (different ?l2 ?l)
                       (different ?l2 depot)
                       (> (location-total-need ?l2) (location-total-need ?l)))))
            ((atender-localizacion ?d ?l)
             (enviar-todo)))

   ;; Caso base: no quedan necesidades
   (:method (enviar-todo)
            no-hay-necesidades
            ()
            ())

  ))
