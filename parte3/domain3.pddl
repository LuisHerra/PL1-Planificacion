(define (domain emergency-carrier)
    (:requirements :strips :typing :durative-actions :numeric-fluents)

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
        (available ?d - drone)

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
        
        ;; Person lock
        (person-available ?p - person)
    )

    (:functions
        (fly-cost ?from - location ?to - location)
    )

    ;; -----------------------------
    ;; COGER TRANSPORTADOR
    ;; -----------------------------
    (:durative-action pick-up-carrier
        :parameters (?d - drone ?ca - carrier ?l - location)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (at start (at-carrier ?ca ?l))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (at-carrier ?ca ?l)))
            (at start (not (available ?d)))
            (at end (carrying ?d ?ca))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; DEJAR TRANSPORTADOR
    ;; -----------------------------
    (:durative-action drop-carrier
        :parameters (?d - drone ?ca - carrier ?l - location)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (at start (carrying ?d ?ca))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (carrying ?d ?ca)))
            (at start (not (available ?d)))
            (at end (at-carrier ?ca ?l))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; MOVER SOLO DRON
    ;; -----------------------------
    (:durative-action fly
        :parameters (?d - drone ?from - location ?to - location)
        :duration (= ?duration (fly-cost ?from ?to))
        :condition (and
            (at start (at-drone ?d ?from))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (at-drone ?d ?from)))
            (at start (not (available ?d)))
            (at end (at-drone ?d ?to))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; VOLAR CON TRANSPORTADOR
    ;; -----------------------------
    (:durative-action fly-and-move-carrier
        :parameters (?d - drone ?ca - carrier ?from - location ?to - location)
        :duration (= ?duration (fly-cost ?from ?to))
        :condition (and
            (at start (at-drone ?d ?from))
            (over all (carrying ?d ?ca))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (at-drone ?d ?from)))
            (at start (not (available ?d)))
            (at end (at-drone ?d ?to))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; COGER CAJA
    ;; -----------------------------
    (:durative-action pick-up
        :parameters (?d - drone ?c - crate ?l - location)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (at start (at-crate ?c ?l))
            (at start (drone-free ?d))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (at-crate ?c ?l)))
            (at start (not (available ?d)))
            (at start (not (drone-free ?d)))
            (at end (holding ?d ?c))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; PONER CAJA EN TRANSPORTADOR
    ;; -----------------------------
    (:durative-action put-in-carrier
        :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (over all (carrying ?d ?ca))
            (at start (holding ?d ?c))
            (at start (carrier-load ?ca ?n1))
            (over all (carrier-capacity ?ca ?n2))
            (over all (siguiente ?n1 ?n2))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (holding ?d ?c)))
            (at start (not (carrier-load ?ca ?n1)))
            (at start (not (available ?d)))
            (at end (drone-free ?d))
            (at end (in ?c ?ca))
            (at end (carrier-load ?ca ?n2))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; SACAR CAJA DEL TRANSPORTADOR
    ;; -----------------------------
    (:durative-action take-from-carrier
        :parameters (?d - drone ?c - crate ?ca - carrier ?l - location ?n1 ?n2 - num)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (over all (carrying ?d ?ca))
            (at start (in ?c ?ca))
            (at start (carrier-load ?ca ?n2))
            (over all (siguiente ?n1 ?n2))
            (at start (drone-free ?d))
            (at start (available ?d))
        )
        :effect (and
            (at start (not (in ?c ?ca)))
            (at start (not (carrier-load ?ca ?n2)))
            (at start (not (drone-free ?d)))
            (at start (not (available ?d)))
            (at end (holding ?d ?c))
            (at end (carrier-load ?ca ?n1))
            (at end (available ?d))
        )
    )

    ;; -----------------------------
    ;; ENTREGAR
    ;; -----------------------------
    (:durative-action deliver
        :parameters (?d - drone ?c - crate ?p - person ?l - location ?t - content)
        :duration (= ?duration 5)
        :condition (and
            (over all (at-drone ?d ?l))
            (at start (holding ?d ?c))
            (over all (at-person ?p ?l))
            (over all (crate-has ?c ?t))
            (at start (available ?d))
            (at start (person-available ?p))
        )
        :effect (and
            (at start (not (holding ?d ?c)))
            (at start (not (available ?d)))
            (at start (not (person-available ?p)))
            (at end (person-has ?p ?t))
            (at end (drone-free ?d))
            (at end (available ?d))
            (at end (person-available ?p))
        )
    )
)