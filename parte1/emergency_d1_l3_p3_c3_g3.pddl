(define (problem emergency_d1_l3_p3_c3_g3)
(:domain emergency)
(:objects
	drone1 - drone
	drone1_arm1 - arm
	drone1_arm2 - arm
	depot - location
	loc1 - location
	loc2 - location
	loc3 - location
	crate1 - crate
	crate2 - crate
	crate3 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	person3 - person
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
	(crate-has crate1 food)
	(crate-has crate2 medicine)
	(crate-has crate3 medicine)
	(at-person person1 loc2)
	(at-person person2 loc2)
	(at-person person3 loc1)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 medicine)
	(person-has person2 medicine)
	(person-has person3 food)
))
)
