(define (domain emergency-carrier)
  (:requirements :strips :typing)

  (:types
    drone
    person
    crate
    location
    content
    carrier
    num
  )

  (:predicates
    ;; Localización
    (at-drone ?d - drone ?l - location)
    (at-person ?p - person ?l - location)
    (at-crate ?c - crate ?l - location)
    (at-carrier ?ca - carrier ?l - location)

    ;; Estado del dron
    (holding ?d - drone ?c - crate)
    (drone-free ?d - drone)

    ;; Contenido
    (crate-has ?c - crate ?t - content)
    (person-has ?p - person ?t - content)

    ;; Cajas dentro del transportador
    (in ?c - crate ?ca - carrier)

    ;; Control numérico
    (carrier-load ?ca - carrier ?n - num)
    (carrier-capacity ?ca - carrier ?n - num)
    (siguiente ?n1 ?n2 - num)
  )

  ;; -----------------------------
  ;; MOVER DRON
  ;; -----------------------------

  (:action fly
    :parameters (?d - drone ?from - location ?to - location)
    :precondition (at-drone ?d ?from)
    :effect (and
      (not (at-drone ?d ?from))
      (at-drone ?d ?to)
    )
  )

  ;; -----------------------------
  ;; COGER CAJA
  ;; -----------------------------

  (:action pick-up
    :parameters (?d - drone ?c - crate ?l - location)
    :precondition (and
      (at-drone ?d ?l)
      (at-crate ?c ?l)
      (drone-free ?d)
    )
    :effect (and
      (not (at-crate ?c ?l))
      (not (drone-free ?d))
      (holding ?d ?c)
    )
  )

  ;; -----------------------------
  ;; PONER CAJA EN TRANSPORTADOR
  ;; -----------------------------

  (:action put-in-carrier
    :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
    :precondition (and
      (at-drone ?d ?l)
      (at-carrier ?ca ?l)
      (holding ?d ?c)
      (carrier-load ?ca ?n1)
      (carrier-capacity ?ca ?n2)
      (siguiente ?n1 ?n2)
    )
    :effect (and
      (not (holding ?d ?c))
      (drone-free ?d)
      (in ?c ?ca)
      (not (carrier-load ?ca ?n1))
      (carrier-load ?ca ?n2)
    )
  )

  ;; -----------------------------
  ;; SACAR CAJA DEL TRANSPORTADOR
  ;; -----------------------------

  (:action take-from-carrier
    :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
    :precondition (and
      (at-drone ?d ?l)
      (at-carrier ?ca ?l)
      (in ?c ?ca)
      (carrier-load ?ca ?n2)
      (siguiente ?n1 ?n2)
      (drone-free ?d)
    )
    :effect (and
      (holding ?d ?c)
      (not (drone-free ?d))
      (not (in ?c ?ca))
      (not (carrier-load ?ca ?n2))
      (carrier-load ?ca ?n1)
    )
  )

  ;; -----------------------------
  ;; ENTREGAR
  ;; -----------------------------

  (:action deliver
    :parameters (?d - drone ?c - crate ?p - person ?l - location ?t - content)
    :precondition (and
      (at-drone ?d ?l)
      (at-person ?p ?l)
      (holding ?d ?c)
      (crate-has ?c ?t)
    )
    :effect (and
      (person-has ?p ?t)
      (not (holding ?d ?c))
      (drone-free ?d)
    )
  )

)