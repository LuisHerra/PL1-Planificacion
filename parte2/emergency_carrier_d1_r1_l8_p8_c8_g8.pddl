(define (problem emergency_carrier_d1_r1_l8_p8_c8_g8)
(:domain emergency-carrier)
(:objects
	drone1 - drone
	carrier1 - carrier
	depot - location
	loc1 - location
	loc2 - location
	loc3 - location
	loc4 - location
	loc5 - location
	loc6 - location
	loc7 - location
	loc8 - location
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
	crate5 - crate
	crate6 - crate
	crate7 - crate
	crate8 - crate
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
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(at-drone drone1 depot)
	(drone-free drone1)
	(at-carrier carrier1 depot)
	(carrier-load carrier1 n0)
	(carrier-capacity carrier1 n1)
	(carrier-capacity carrier1 n2)
	(carrier-capacity carrier1 n3)
	(carrier-capacity carrier1 n4)
	(siguiente n0 n1)
	(siguiente n1 n2)
	(siguiente n2 n3)
	(siguiente n3 n4)
	(at-crate crate1 depot)
	(at-crate crate2 depot)
	(at-crate crate3 depot)
	(at-crate crate4 depot)
	(at-crate crate5 depot)
	(at-crate crate6 depot)
	(at-crate crate7 depot)
	(at-crate crate8 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 medicine)
	(crate-has crate4 medicine)
	(crate-has crate5 medicine)
	(crate-has crate6 medicine)
	(crate-has crate7 medicine)
	(crate-has crate8 medicine)
	(at-person person1 loc1)
	(at-person person2 loc7)
	(at-person person3 loc8)
	(at-person person4 loc3)
	(at-person person5 loc5)
	(at-person person6 loc2)
	(at-person person7 loc8)
	(at-person person8 loc7)
)
(:goal (and
	(person-has person1 medicine)
	(person-has person2 medicine)
	(person-has person4 food)
	(person-has person4 medicine)
	(person-has person5 medicine)
	(person-has person6 food)
	(person-has person6 medicine)
	(person-has person7 medicine)
))
)
