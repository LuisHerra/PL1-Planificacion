(define (problem emergency_carrier_d1_r1_l10_p10_c4_g4)
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
	loc9 - location
	loc10 - location
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
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
	person10 - person
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
	(carrier-capacity carrier1 n4)
	(siguiente n0 n1)
	(siguiente n1 n2)
	(siguiente n2 n3)
	(siguiente n3 n4)
	(at-crate crate1 depot)
	(at-crate crate2 depot)
	(at-crate crate3 depot)
	(at-crate crate4 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 medicine)
	(crate-has crate4 medicine)
	(at-person person1 loc1)
	(at-person person2 loc4)
	(at-person person3 loc1)
	(at-person person4 loc5)
	(at-person person5 loc2)
	(at-person person6 loc5)
	(at-person person7 loc9)
	(at-person person8 loc7)
	(at-person person9 loc10)
	(at-person person10 loc8)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person3 food)
	(person-has person7 food)
	(person-has person8 medicine)
	(person-has person9 medicine)
))
)
