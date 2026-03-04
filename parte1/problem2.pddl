(define (problem emergency-problem2)
  (:domain emergency)

  (:objects
    d1 - drone
    a1 a2 - arm

    p1 p2 - person

    c1 c2 c3 - crate

    depot l1 l2 - location

    food medicine - content
  )

  (:init
    (at-drone d1 depot)

    (arm-of a1 d1)
    (arm-of a2 d1)
    (free a1)
    (free a2)

    (at-person p1 l1)
    (at-person p2 l2)

    (at-crate c1 depot)
    (at-crate c2 depot)
    (at-crate c3 depot)

    (crate-has c1 food)
    (crate-has c2 medicine)
    (crate-has c3 food)
  )

  (:goal
    (and
      (person-has p1 food)
      (person-has p2 medicine)
    )
  )
)