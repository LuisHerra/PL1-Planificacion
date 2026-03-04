(define (problem emergency_d1_l7_p7_c7_g7)
(:domain emergency)
(:objects
	drone1 - drone
	drone1_arm1 - arm
	drone1_arm2 - arm
	depot - location
	loc1 - location
	loc2 - location
	loc3 - location
	loc4 - location
	loc5 - location
	loc6 - location
	loc7 - location
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
	crate5 - crate
	crate6 - crate
	crate7 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	person3 - person
	person4 - person
	person5 - person
	person6 - person
	person7 - person
)
(:init
	(at-drone drone1 depot)
	(arm-of drone1_arm1 drone1)
	(arm-of drone1_arm2 drone1)
	(free drone1_arm1)
	(free drone1_arm2)
	(at-crate crate1 depot)
	(at-crate crate2 depot)
	(at-crate crate3 depot)
	(at-crate crate4 depot)
	(at-crate crate5 depot)
	(at-crate crate6 depot)
	(at-crate crate7 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 food)
	(crate-has crate4 medicine)
	(crate-has crate5 medicine)
	(crate-has crate6 medicine)
	(crate-has crate7 medicine)
	(at-person person1 loc6)
	(at-person person2 loc1)
	(at-person person3 loc3)
	(at-person person4 loc3)
	(at-person person5 loc4)
	(at-person person6 loc5)
	(at-person person7 loc5)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 medicine)
	(person-has person2 food)
	(person-has person2 medicine)
	(person-has person3 food)
	(person-has person3 medicine)
	(person-has person6 food)
	(person-has person6 medicine)
))
)
