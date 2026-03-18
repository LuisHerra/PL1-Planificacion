(define (problem emergency_carrier_d1_r1_l4_p4_c4_g4)
(:domain emergency-carrier)
(:objects
	drone1 - drone
	carrier1 - carrier
	depot - location
	loc1 - location
	loc2 - location
	loc3 - location
	loc4 - location
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
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(= (total-cost) 0)
	(= (fly-cost depot depot) 0)
	(= (fly-cost depot loc1) 203)
	(= (fly-cost depot loc2) 107)
	(= (fly-cost depot loc3) 225)
	(= (fly-cost depot loc4) 116)
	(= (fly-cost loc1 depot) 203)
	(= (fly-cost loc1 loc1) 0)
	(= (fly-cost loc1 loc2) 110)
	(= (fly-cost loc1 loc3) 98)
	(= (fly-cost loc1 loc4) 88)
	(= (fly-cost loc2 depot) 107)
	(= (fly-cost loc2 loc1) 110)
	(= (fly-cost loc2 loc2) 0)
	(= (fly-cost loc2 loc3) 117)
	(= (fly-cost loc2 loc4) 30)
	(= (fly-cost loc3 depot) 225)
	(= (fly-cost loc3 loc1) 98)
	(= (fly-cost loc3 loc2) 117)
	(= (fly-cost loc3 loc3) 0)
	(= (fly-cost loc3 loc4) 120)
	(= (fly-cost loc4 depot) 116)
	(= (fly-cost loc4 loc1) 88)
	(= (fly-cost loc4 loc2) 30)
	(= (fly-cost loc4 loc3) 120)
	(= (fly-cost loc4 loc4) 0)
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
	(crate-has crate2 medicine)
	(crate-has crate3 medicine)
	(crate-has crate4 medicine)
	(at-person person1 loc3)
	(at-person person2 loc2)
	(at-person person3 loc3)
	(at-person person4 loc1)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person2 medicine)
	(person-has person3 medicine)
	(person-has person4 food)
	(person-has person4 medicine)
))
(:metric minimize (total-cost))
)
