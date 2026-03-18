(define (problem emergency_carrier_d1_r1_l3_p2_c2_g1)
(:domain emergency-carrier)
(:objects
	drone1 - drone
	carrier1 - carrier
	depot - location
	loc1 - location
	loc2 - location
	loc3 - location
	crate1 - crate
	crate2 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(at-drone drone1 depot)
	(drone-free drone1)
	(available drone1)
	(at-carrier carrier1 depot)
	(carrier-load carrier1 n0)
	(carrier-capacity carrier1 n4)
	(siguiente n0 n1)
	(siguiente n1 n2)
	(siguiente n2 n3)
	(siguiente n3 n4)
	(at-crate crate1 depot)
	(at-crate crate2 depot)
	(crate-has crate1 food)
	(crate-has crate2 medicine)
	(at-person person1 loc3)
	(person-available person1)
	(at-person person2 loc1)
	(person-available person2)
	(= (fly-cost depot loc1) 66)
	(= (fly-cost depot loc2) 56)
	(= (fly-cost depot loc3) 30)
	(= (fly-cost loc1 depot) 66)
	(= (fly-cost loc1 loc2) 86)
	(= (fly-cost loc1 loc3) 40)
	(= (fly-cost loc2 depot) 56)
	(= (fly-cost loc2 loc1) 86)
	(= (fly-cost loc2 loc3) 52)
	(= (fly-cost loc3 depot) 30)
	(= (fly-cost loc3 loc1) 40)
	(= (fly-cost loc3 loc2) 52)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person2 medicine)
))

	(:metric minimize (total-time))
)
