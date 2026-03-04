(define (problem emergency-problem1)
  (:domain emergency)

  (:objects
    d1 - drone
    a1 a2 - arm
    p1 - person
    c1 - crate
    depot l1 - location
    food - content
  )

  (:init
    (at-drone d1 depot)

    (arm-of a1 d1)
    (arm-of a2 d1)
    (free a1)
    (free a2)

    (at-person p1 l1)

    (at-crate c1 depot)
    (crate-has c1 food)
  )

  (:goal
    (and
      (person-has p1 food)
    )
  )
)