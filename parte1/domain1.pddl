(define (domain emergency)
  (:requirements :strips :typing)

  (:types
    drone
    person
    crate
    location
    content
    arm
  )

  (:predicates
    (at-drone ?d - drone ?l - location)
    (at-person ?p - person ?l - location)
    (at-crate ?c - crate ?l - location)

    (arm-of ?a - arm ?d - drone)
    (free ?a - arm)
    (holding ?a - arm ?c - crate)

    (crate-has ?c - crate ?t - content)
    (person-has ?p - person ?t - content)
  )

  (:action fly
    :parameters (?d - drone ?from - location ?to - location)
    :precondition (at-drone ?d ?from)
    :effect (and
      (not (at-drone ?d ?from))
      (at-drone ?d ?to)
    )
  )

  (:action pick-up
    :parameters (?d - drone ?a - arm ?c - crate ?l - location)
    :precondition (and
      (at-drone ?d ?l)
      (at-crate ?c ?l)
      (arm-of ?a ?d)
      (free ?a)
    )
    :effect (and
      (not (at-crate ?c ?l))
      (not (free ?a))
      (holding ?a ?c)
    )
  )

  (:action deliver
    :parameters (?d - drone ?a - arm ?c - crate ?p - person ?l - location ?t - content)
    :precondition (and
      (at-drone ?d ?l)
      (at-person ?p ?l)
      (arm-of ?a ?d)
      (holding ?a ?c)
      (crate-has ?c ?t)
    )
    :effect (and
      (person-has ?p ?t)
      (free ?a)
      (not (holding ?a ?c))
    )
  )

)