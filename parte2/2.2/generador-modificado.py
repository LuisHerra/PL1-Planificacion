#!/usr/bin/env python3

from optparse import OptionParser
import random
import math
import sys

content_types = ["food", "medicine"]

MAX_CAPACITY = 4


# -----------------------------
# DISTANCIA Y COSTE (🔥 MODIFICADO)
# -----------------------------

def distance(location_coords, l1, l2):
    x1, y1 = location_coords[l1]
    x2, y2 = location_coords[l2]
    return math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)


def flight_cost(location_coords, l1, l2):
    # 🔥 COSTE MUCHO MAYOR → favorece carrier
    return int(distance(location_coords, l1, l2) * 10)


# -----------------------------
# COORDENADAS
# -----------------------------

def setup_location_coords(options):
    coords = {}
    coords["depot"] = (0, 0)

    for i in range(1, options.locations + 1):
        coords["loc" + str(i)] = (random.randint(1, 200),
                                 random.randint(1, 200))
    return coords


# -----------------------------
# CONTENIDO
# -----------------------------

def setup_content_types(options):
    while True:
        num_crates_with_contents = []
        crates_left = options.crates

        for x in range(len(content_types) - 1):
            types_after_this = len(content_types) - x - 1
            max_now = crates_left - types_after_this
            num = random.randint(1, max_now)
            num_crates_with_contents.append(num)
            crates_left -= num

        num_crates_with_contents.append(crates_left)

        maxgoals = sum(min(num_crates, options.persons)
                       for num_crates in num_crates_with_contents)

        if options.goals <= maxgoals:
            break

    crates_with_contents = []
    counter = 1

    for x in range(len(content_types)):
        crates = []
        for y in range(num_crates_with_contents[x]):
            crates.append("crate" + str(counter))
            counter += 1
        crates_with_contents.append(crates)

    return crates_with_contents


# -----------------------------
# NECESIDADES (🔥 AGRUPADAS)
# -----------------------------

def setup_person_needs(options, crates_with_contents):
    need = [[False for i in range(len(content_types))]
            for j in range(options.persons)]

    goals_per_contents = [0 for i in range(len(content_types))]

    for goalnum in range(options.goals):
        generated = False
        while not generated:
            rand_person = random.randint(0, options.persons - 1)
            rand_content = random.randint(0, len(content_types) - 1)

            if (goals_per_contents[rand_content] <
                    len(crates_with_contents[rand_content])
                    and not need[rand_person][rand_content]):

                need[rand_person][rand_content] = True
                goals_per_contents[rand_content] += 1
                generated = True

    return need


# -----------------------------
# MAIN
# -----------------------------

def main():

    parser = OptionParser()
    parser.add_option('-d', '--drones', dest='drones', type=int)
    parser.add_option('-r', '--carriers', dest='carriers', type=int)
    parser.add_option('-l', '--locations', dest='locations', type=int)
    parser.add_option('-p', '--persons', dest='persons', type=int)
    parser.add_option('-c', '--crates', dest='crates', type=int)
    parser.add_option('-g', '--goals', dest='goals', type=int)

    (options, args) = parser.parse_args()

    if None in [options.drones, options.carriers, options.locations,
                options.persons, options.crates, options.goals]:
        print("Missing parameters")
        sys.exit(1)

    drone = ["drone" + str(x + 1) for x in range(options.drones)]
    carrier = ["carrier" + str(x + 1) for x in range(options.carriers)]
    person = ["person" + str(x + 1) for x in range(options.persons)]
    crate = ["crate" + str(x + 1) for x in range(options.crates)]
    location = ["depot"] + ["loc" + str(x + 1)
                           for x in range(options.locations)]

    nums = ["n" + str(i) for i in range(MAX_CAPACITY + 1)]

    crates_with_contents = setup_content_types(options)
    need = setup_person_needs(options, crates_with_contents)

    location_coords = setup_location_coords(options)

    problem_name = "emergency_carrier_d" + str(options.drones) + \
                   "_r" + str(options.carriers) + \
                   "_l" + str(options.locations) + \
                   "_p" + str(options.persons) + \
                   "_c" + str(options.crates) + \
                   "_g" + str(options.goals)

    with open(problem_name + ".pddl", 'w') as f:

        f.write("(define (problem " + problem_name + ")\n")
        f.write("(:domain emergency-carrier)\n")

        # OBJETOS
        f.write("(:objects\n")
        for x in drone:
            f.write("\t" + x + " - drone\n")
        for x in carrier:
            f.write("\t" + x + " - carrier\n")
        for x in location:
            f.write("\t" + x + " - location\n")
        for x in crate:
            f.write("\t" + x + " - crate\n")
        for x in content_types:
            f.write("\t" + x + " - content\n")
        for x in person:
            f.write("\t" + x + " - person\n")
        for x in nums:
            f.write("\t" + x + " - num\n")
        f.write(")\n")

        # INIT
        f.write("(:init\n")

        f.write("\t(= (total-cost) 0)\n")

        # 🔥 COSTES DE VUELO ALTOS
        for l1 in location:
            for l2 in location:
                cost = flight_cost(location_coords, l1, l2)
                f.write(f"\t(= (fly-cost {l1} {l2}) {cost})\n")

        # drones
        for x in drone:
            f.write("\t(at-drone " + x + " depot)\n")
            f.write("\t(drone-free " + x + ")\n")

        # carriers
        for x in carrier:
            f.write("\t(at-carrier " + x + " depot)\n")
            f.write("\t(carrier-load " + x + " n0)\n")
            f.write("\t(carrier-capacity " + x +
                    " n" + str(MAX_CAPACITY) + ")\n")

        # números
        for i in range(MAX_CAPACITY):
            f.write("\t(siguiente n" + str(i) +
                    " n" + str(i + 1) + ")\n")

        # crates
        for x in crate:
            f.write("\t(at-crate " + x + " depot)\n")

        # contenido
        for content_index in range(len(content_types)):
            for crate_name in crates_with_contents[content_index]:
                f.write("\t(crate-has " + crate_name + " " +
                        content_types[content_index] + ")\n")

        # 🔥 PERSONAS AGRUPADAS (clave)
        common_locations = location[1: max(2, len(location)//2)]

        for x in person:
            loc = random.choice(common_locations)
            f.write("\t(at-person " + x + " " + loc + ")\n")

        f.write(")\n")

        # GOAL
        f.write("(:goal (and\n")

        for x in drone:
            f.write("\t(at-drone " + x + " depot)\n")

        for x in range(options.persons):
            for y in range(len(content_types)):
                if need[x][y]:
                    f.write("\t(person-has " + person[x] + " " +
                            content_types[y] + ")\n")

        f.write("))\n")

        f.write("(:metric minimize (total-cost))\n")

        f.write(")\n")


if __name__ == '__main__':
    main()