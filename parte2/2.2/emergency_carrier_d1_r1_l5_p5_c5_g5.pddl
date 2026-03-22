(define (problem emergency_carrier_d1_r1_l5_p5_c5_g5)
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
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
	crate5 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	person3 - person
	person4 - person
	person5 - person
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(= (total-cost) 0)
	(= (fly-cost depot depot) 0)
	(= (fly-cost depot loc1) 2058)
	(= (fly-cost depot loc2) 1723)
	(= (fly-cost depot loc3) 364)
	(= (fly-cost depot loc4) 1414)
	(= (fly-cost depot loc5) 1294)
	(= (fly-cost loc1 depot) 2058)
	(= (fly-cost loc1 loc1) 0)
	(= (fly-cost loc1 loc2) 820)
	(= (fly-cost loc1 loc3) 1694)
	(= (fly-cost loc1 loc4) 1366)
	(= (fly-cost loc1 loc5) 854)
	(= (fly-cost loc2 depot) 1723)
	(= (fly-cost loc2 loc1) 820)
	(= (fly-cost loc2 loc2) 0)
	(= (fly-cost loc2 loc3) 1405)
	(= (fly-cost loc2 loc4) 1690)
	(= (fly-cost loc2 loc5) 494)
	(= (fly-cost loc3 depot) 364)
	(= (fly-cost loc3 loc1) 1694)
	(= (fly-cost loc3 loc2) 1405)
	(= (fly-cost loc3 loc3) 0)
	(= (fly-cost loc3 loc4) 1151)
	(= (fly-cost loc3 loc5) 950)
	(= (fly-cost loc4 depot) 1414)
	(= (fly-cost loc4 loc1) 1366)
	(= (fly-cost loc4 loc2) 1690)
	(= (fly-cost loc4 loc3) 1151)
	(= (fly-cost loc4 loc4) 0)
	(= (fly-cost loc4 loc5) 1252)
	(= (fly-cost loc5 depot) 1294)
	(= (fly-cost loc5 loc1) 854)
	(= (fly-cost loc5 loc2) 494)
	(= (fly-cost loc5 loc3) 950)
	(= (fly-cost loc5 loc4) 1252)
	(= (fly-cost loc5 loc5) 0)
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
	(at-crate crate5 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 food)
	(crate-has crate4 medicine)
	(crate-has crate5 medicine)
	(at-person person1 loc1)
	(at-person person2 loc1)
	(at-person person3 loc1)
	(at-person person4 loc1)
	(at-person person5 loc2)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 food)
	(person-has person2 food)
	(person-has person2 medicine)
	(person-has person4 medicine)
	(person-has person5 food)
))
(:metric minimize (total-cost))
)
