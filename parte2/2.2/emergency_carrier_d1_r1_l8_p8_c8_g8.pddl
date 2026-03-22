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
	(= (total-cost) 0)
	(= (fly-cost depot depot) 0)
	(= (fly-cost depot loc1) 1110)
	(= (fly-cost depot loc2) 838)
	(= (fly-cost depot loc3) 1657)
	(= (fly-cost depot loc4) 1592)
	(= (fly-cost depot loc5) 676)
	(= (fly-cost depot loc6) 830)
	(= (fly-cost depot loc7) 1456)
	(= (fly-cost depot loc8) 2166)
	(= (fly-cost loc1 depot) 1110)
	(= (fly-cost loc1 loc1) 0)
	(= (fly-cost loc1 loc2) 679)
	(= (fly-cost loc1 loc3) 856)
	(= (fly-cost loc1 loc4) 943)
	(= (fly-cost loc1 loc5) 902)
	(= (fly-cost loc1 loc6) 280)
	(= (fly-cost loc1 loc7) 1454)
	(= (fly-cost loc1 loc8) 1387)
	(= (fly-cost loc2 depot) 838)
	(= (fly-cost loc2 loc1) 679)
	(= (fly-cost loc2 loc2) 0)
	(= (fly-cost loc2 loc3) 841)
	(= (fly-cost loc2 loc4) 754)
	(= (fly-cost loc2 loc5) 271)
	(= (fly-cost loc2 loc6) 540)
	(= (fly-cost loc2 loc7) 840)
	(= (fly-cost loc2 loc8) 1331)
	(= (fly-cost loc3 depot) 1657)
	(= (fly-cost loc3 loc1) 856)
	(= (fly-cost loc3 loc2) 841)
	(= (fly-cost loc3 loc3) 0)
	(= (fly-cost loc3 loc4) 220)
	(= (fly-cost loc3 loc5) 1091)
	(= (fly-cost loc3 loc6) 1006)
	(= (fly-cost loc3 loc7) 1066)
	(= (fly-cost loc3 loc8) 542)
	(= (fly-cost loc4 depot) 1592)
	(= (fly-cost loc4 loc1) 943)
	(= (fly-cost loc4 loc2) 754)
	(= (fly-cost loc4 loc3) 220)
	(= (fly-cost loc4 loc4) 0)
	(= (fly-cost loc4 loc5) 975)
	(= (fly-cost loc4 loc6) 1037)
	(= (fly-cost loc4 loc7) 850)
	(= (fly-cost loc4 loc8) 578)
	(= (fly-cost loc5 depot) 676)
	(= (fly-cost loc5 loc1) 902)
	(= (fly-cost loc5 loc2) 271)
	(= (fly-cost loc5 loc3) 1091)
	(= (fly-cost loc5 loc4) 975)
	(= (fly-cost loc5 loc5) 0)
	(= (fly-cost loc5 loc6) 702)
	(= (fly-cost loc5 loc7) 812)
	(= (fly-cost loc5 loc8) 1551)
	(= (fly-cost loc6 depot) 830)
	(= (fly-cost loc6 loc1) 280)
	(= (fly-cost loc6 loc2) 540)
	(= (fly-cost loc6 loc3) 1006)
	(= (fly-cost loc6 loc4) 1037)
	(= (fly-cost loc6 loc5) 702)
	(= (fly-cost loc6 loc6) 0)
	(= (fly-cost loc6 loc7) 1375)
	(= (fly-cost loc6 loc8) 1548)
	(= (fly-cost loc7 depot) 1456)
	(= (fly-cost loc7 loc1) 1454)
	(= (fly-cost loc7 loc2) 840)
	(= (fly-cost loc7 loc3) 1066)
	(= (fly-cost loc7 loc4) 850)
	(= (fly-cost loc7 loc5) 812)
	(= (fly-cost loc7 loc6) 1375)
	(= (fly-cost loc7 loc7) 0)
	(= (fly-cost loc7 loc8) 1254)
	(= (fly-cost loc8 depot) 2166)
	(= (fly-cost loc8 loc1) 1387)
	(= (fly-cost loc8 loc2) 1331)
	(= (fly-cost loc8 loc3) 542)
	(= (fly-cost loc8 loc4) 578)
	(= (fly-cost loc8 loc5) 1551)
	(= (fly-cost loc8 loc6) 1548)
	(= (fly-cost loc8 loc7) 1254)
	(= (fly-cost loc8 loc8) 0)
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
	(at-crate crate8 depot)
	(crate-has crate1 food)
	(crate-has crate2 food)
	(crate-has crate3 food)
	(crate-has crate4 food)
	(crate-has crate5 food)
	(crate-has crate6 food)
	(crate-has crate7 food)
	(crate-has crate8 medicine)
	(at-person person1 loc1)
	(at-person person2 loc3)
	(at-person person3 loc1)
	(at-person person4 loc1)
	(at-person person5 loc3)
	(at-person person6 loc2)
	(at-person person7 loc2)
	(at-person person8 loc2)
)
(:goal (and
	(at-drone drone1 depot)
	(person-has person2 food)
	(person-has person3 food)
	(person-has person4 food)
	(person-has person5 food)
	(person-has person6 food)
	(person-has person6 medicine)
	(person-has person7 food)
	(person-has person8 food)
))
(:metric minimize (total-cost))
)
