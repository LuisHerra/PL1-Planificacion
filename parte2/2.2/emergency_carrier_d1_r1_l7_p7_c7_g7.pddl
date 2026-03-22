(define (problem emergency_carrier_d1_r1_l7_p7_c7_g7)
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
	n0 - num
	n1 - num
	n2 - num
	n3 - num
	n4 - num
)
(:init
	(= (total-cost) 0)
	(= (fly-cost depot depot) 0)
	(= (fly-cost depot loc1) 63)
	(= (fly-cost depot loc2) 110)
	(= (fly-cost depot loc3) 197)
	(= (fly-cost depot loc4) 176)
	(= (fly-cost depot loc5) 224)
	(= (fly-cost depot loc6) 70)
	(= (fly-cost depot loc7) 137)
	(= (fly-cost loc1 depot) 63)
	(= (fly-cost loc1 loc1) 0)
	(= (fly-cost loc1 loc2) 60)
	(= (fly-cost loc1 loc3) 151)
	(= (fly-cost loc1 loc4) 116)
	(= (fly-cost loc1 loc5) 168)
	(= (fly-cost loc1 loc6) 29)
	(= (fly-cost loc1 loc7) 77)
	(= (fly-cost loc2 depot) 110)
	(= (fly-cost loc2 loc1) 60)
	(= (fly-cost loc2 loc2) 0)
	(= (fly-cost loc2 loc3) 91)
	(= (fly-cost loc2 loc4) 116)
	(= (fly-cost loc2 loc5) 114)
	(= (fly-cost loc2 loc6) 40)
	(= (fly-cost loc2 loc7) 86)
	(= (fly-cost loc3 depot) 197)
	(= (fly-cost loc3 loc1) 151)
	(= (fly-cost loc3 loc2) 91)
	(= (fly-cost loc3 loc3) 0)
	(= (fly-cost loc3 loc4) 165)
	(= (fly-cost loc3 loc5) 57)
	(= (fly-cost loc3 loc6) 129)
	(= (fly-cost loc3 loc7) 153)
	(= (fly-cost loc4 depot) 176)
	(= (fly-cost loc4 loc1) 116)
	(= (fly-cost loc4 loc2) 116)
	(= (fly-cost loc4 loc3) 165)
	(= (fly-cost loc4 loc4) 0)
	(= (fly-cost loc4 loc5) 139)
	(= (fly-cost loc4 loc6) 130)
	(= (fly-cost loc4 loc7) 39)
	(= (fly-cost loc5 depot) 224)
	(= (fly-cost loc5 loc1) 168)
	(= (fly-cost loc5 loc2) 114)
	(= (fly-cost loc5 loc3) 57)
	(= (fly-cost loc5 loc4) 139)
	(= (fly-cost loc5 loc5) 0)
	(= (fly-cost loc5 loc6) 153)
	(= (fly-cost loc5 loc7) 141)
	(= (fly-cost loc6 depot) 70)
	(= (fly-cost loc6 loc1) 29)
	(= (fly-cost loc6 loc2) 40)
	(= (fly-cost loc6 loc3) 129)
	(= (fly-cost loc6 loc4) 130)
	(= (fly-cost loc6 loc5) 153)
	(= (fly-cost loc6 loc6) 0)
	(= (fly-cost loc6 loc7) 93)
	(= (fly-cost loc7 depot) 137)
	(= (fly-cost loc7 loc1) 77)
	(= (fly-cost loc7 loc2) 86)
	(= (fly-cost loc7 loc3) 153)
	(= (fly-cost loc7 loc4) 39)
	(= (fly-cost loc7 loc5) 141)
	(= (fly-cost loc7 loc6) 93)
	(= (fly-cost loc7 loc7) 0)
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
	(at-crate crate7 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 food)
	(crate-has crate4 medicine)
	(crate-has crate5 medicine)
	(crate-has crate6 medicine)
	(crate-has crate7 medicine)
	(at-person person1 loc2)
	(at-person person2 loc5)
	(at-person person3 loc1)
	(at-person person4 loc4)
	(at-person person5 loc4)
	(at-person person6 loc6)
	(at-person person7 loc6)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person1 food)
	(person-has person1 medicine)
	(person-has person3 food)
	(person-has person4 medicine)
	(person-has person5 medicine)
	(person-has person7 food)
	(person-has person7 medicine)
))
(:metric minimize (total-cost))
)
