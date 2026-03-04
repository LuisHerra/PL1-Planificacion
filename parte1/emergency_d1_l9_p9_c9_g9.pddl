(define (problem emergency_d1_l9_p9_c9_g9)
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
	loc8 - location
	loc9 - location
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
	crate5 - crate
	crate6 - crate
	crate7 - crate
	crate8 - crate
	crate9 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	person3 - person
	person4 - person
	person5 - person
	person6 - person
	person7 - person
	person8 - person
	person9 - person
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
	(at-crate crate8 depot)
	(at-crate crate9 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 food)
	(crate-has crate4 food)
	(crate-has crate5 food)
	(crate-has crate6 food)
	(crate-has crate7 food)
	(crate-has crate8 food)
	(crate-has crate9 medicine)
	(at-person person1 loc6)
	(at-person person2 loc7)
	(at-person person3 loc6)
	(at-person person4 loc8)
	(at-person person5 loc2)
	(at-person person6 loc7)
	(at-person person7 loc2)
	(at-person person8 loc2)
	(at-person person9 loc8)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 food)
	(person-has person2 food)
	(person-has person3 food)
	(person-has person4 food)
	(person-has person5 food)
	(person-has person6 food)
	(person-has person7 food)
	(person-has person9 food)
	(person-has person9 medicine)
))
)
