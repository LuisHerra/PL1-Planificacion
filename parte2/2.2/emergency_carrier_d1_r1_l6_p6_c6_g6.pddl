(define (problem emergency_carrier_d1_r1_l6_p6_c6_g6)
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
	crate1 - crate
	crate2 - crate
	crate3 - crate
	crate4 - crate
	crate5 - crate
	crate6 - crate
	food - content
	medicine - content
	person1 - person
	person2 - person
	person3 - person
	person4 - person
	person5 - person
	person6 - person
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(= (total-cost) 0)
	(= (fly-cost depot depot) 0)
	(= (fly-cost depot loc1) 129)
	(= (fly-cost depot loc2) 192)
	(= (fly-cost depot loc3) 224)
	(= (fly-cost depot loc4) 236)
	(= (fly-cost depot loc5) 255)
	(= (fly-cost depot loc6) 126)
	(= (fly-cost loc1 depot) 129)
	(= (fly-cost loc1 loc1) 0)
	(= (fly-cost loc1 loc2) 71)
	(= (fly-cost loc1 loc3) 95)
	(= (fly-cost loc1 loc4) 108)
	(= (fly-cost loc1 loc5) 134)
	(= (fly-cost loc1 loc6) 100)
	(= (fly-cost loc2 depot) 192)
	(= (fly-cost loc2 loc1) 71)
	(= (fly-cost loc2 loc2) 0)
	(= (fly-cost loc2 loc3) 69)
	(= (fly-cost loc2 loc4) 77)
	(= (fly-cost loc2 loc5) 124)
	(= (fly-cost loc2 loc6) 166)
	(= (fly-cost loc3 depot) 224)
	(= (fly-cost loc3 loc1) 95)
	(= (fly-cost loc3 loc2) 69)
	(= (fly-cost loc3 loc3) 0)
	(= (fly-cost loc3 loc4) 12)
	(= (fly-cost loc3 loc5) 55)
	(= (fly-cost loc3 loc6) 155)
	(= (fly-cost loc4 depot) 236)
	(= (fly-cost loc4 loc1) 108)
	(= (fly-cost loc4 loc2) 77)
	(= (fly-cost loc4 loc3) 12)
	(= (fly-cost loc4 loc4) 0)
	(= (fly-cost loc4 loc5) 50)
	(= (fly-cost loc4 loc6) 165)
	(= (fly-cost loc5 depot) 255)
	(= (fly-cost loc5 loc1) 134)
	(= (fly-cost loc5 loc2) 124)
	(= (fly-cost loc5 loc3) 55)
	(= (fly-cost loc5 loc4) 50)
	(= (fly-cost loc5 loc5) 0)
	(= (fly-cost loc5 loc6) 160)
	(= (fly-cost loc6 depot) 126)
	(= (fly-cost loc6 loc1) 100)
	(= (fly-cost loc6 loc2) 166)
	(= (fly-cost loc6 loc3) 155)
	(= (fly-cost loc6 loc4) 165)
	(= (fly-cost loc6 loc5) 160)
	(= (fly-cost loc6 loc6) 0)
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
	(at-crate crate6 depot)
	(crate-has crate1 food)
	(crate-has crate2 medicine)
	(crate-has crate3 medicine)
	(crate-has crate4 medicine)
	(crate-has crate5 medicine)
	(crate-has crate6 medicine)
	(at-person person1 loc1)
	(at-person person2 loc5)
	(at-person person3 loc6)
	(at-person person4 loc6)
	(at-person person5 loc5)
	(at-person person6 loc1)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person2 medicine)
	(person-has person3 medicine)
	(person-has person4 medicine)
	(person-has person5 medicine)
	(person-has person6 food)
	(person-has person6 medicine)
))
(:metric minimize (total-cost))
)
