(define (domain emergency-carrier)
    (:requirements :strips :typing :action-costs)

    (:types
        drone person crate location content carrier num
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

        ;; Transportador
        (carrying ?d - drone ?ca - carrier)

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

    (:functions
        (total-cost)
        (fly-cost ?from - location ?to - location)
    )

    ;; -----------------------------
    ;; COGER TRANSPORTADOR
    ;; -----------------------------
    (:action pick-up-carrier
        :parameters (?d - drone ?ca - carrier ?l - location)
        :precondition (and
            (at-drone ?d ?l)
            (at-carrier ?ca ?l)
        )
        :effect (and
            (not (at-carrier ?ca ?l))
            (carrying ?d ?ca)
            (increase (total-cost) 1)
        )
    )

    ;; -----------------------------
    ;; DEJAR TRANSPORTADOR
    ;; -----------------------------
    (:action drop-carrier
        :parameters (?d - drone ?ca - carrier ?l - location)
        :precondition (and
            (at-drone ?d ?l)
            (carrying ?d ?ca)
        )
        :effect (and
            (not (carrying ?d ?ca))
            (at-carrier ?ca ?l)
            (increase (total-cost) 1)
        )
    )

    ;; -----------------------------
    ;; MOVER SOLO DRON (coste variable)
    ;; -----------------------------
    (:action fly
        :parameters (?d - drone ?from - location ?to - location)
        :precondition (at-drone ?d ?from)
        :effect (and
            (not (at-drone ?d ?from))
            (at-drone ?d ?to)
            (increase (total-cost) (fly-cost ?from ?to))
        )
    )

    ;; -----------------------------
    ;; VOLAR CON TRANSPORTADOR (coste variable)
    ;; -----------------------------
    (:action fly-and-move-carrier
        :parameters (?d - drone ?ca - carrier ?from - location ?to - location)
        :precondition (and
            (at-drone ?d ?from)
            (carrying ?d ?ca)
        )
        :effect (and
            (not (at-drone ?d ?from))
            (at-drone ?d ?to)
            (increase (total-cost) (fly-cost ?from ?to))
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
            (increase (total-cost) 1)
        )
    )

    ;; -----------------------------
    ;; PONER CAJA EN TRANSPORTADOR
    ;; -----------------------------
    (:action put-in-carrier
        :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
        :precondition (and
            (at-drone ?d ?l)
            (carrying ?d ?ca)
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
            (increase (total-cost) 1)
        )
    )

    ;; -----------------------------
    ;; SACAR CAJA DEL TRANSPORTADOR
    ;; -----------------------------
    (:action take-from-carrier
        :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
        :precondition (and
            (at-drone ?d ?l)
            (carrying ?d ?ca)
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
            (increase (total-cost) 1)
        )
    )

    ;; -----------------------------
    ;; ENTREGAR
    ;; -----------------------------
    (:action deliver
        :parameters (?d - drone ?c - crate ?p - person ?l - location ?t - content)
        :precondition (and
            (at-drone ?d ?l)
            (holding ?d ?c)
            (at-person ?p ?l)
            (crate-has ?c ?t)
        )
        :effect (and
            (person-has ?p ?t)
            (not (holding ?d ?c))
            (drone-free ?d)
            (increase (total-cost) 1)
        )
    )
)