(define (problem emergency_carrier_d1_r1_l4_p2_c2_g2)
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
	(at-person person1 loc1)
	(at-person person2 loc2)

	(= (total-cost) 0)
	(= (fly-cost depot loc1) 70)
	(= (fly-cost depot loc2) 70)
	(= (fly-cost depot loc3) 39)
	(= (fly-cost depot loc4) 60)
	(= (fly-cost loc1 depot) 70)
	(= (fly-cost loc1 loc2) 21)
	(= (fly-cost loc1 loc3) 89)
	(= (fly-cost loc1 loc4) 54)
	(= (fly-cost loc2 depot) 70)
	(= (fly-cost loc2 loc1) 21)
	(= (fly-cost loc2 loc3) 80)
	(= (fly-cost loc2 loc4) 37)
	(= (fly-cost loc3 depot) 39)
	(= (fly-cost loc3 loc1) 89)
	(= (fly-cost loc3 loc2) 80)
	(= (fly-cost loc3 loc4) 51)
	(= (fly-cost loc4 depot) 60)
	(= (fly-cost loc4 loc1) 54)
	(= (fly-cost loc4 loc2) 37)
	(= (fly-cost loc4 loc3) 51)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 food)
	(person-has person2 medicine)
))

	(:metric minimize (total-cost))
)
