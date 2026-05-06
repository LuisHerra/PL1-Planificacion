#!/usr/bin/env python3
"""
Generador de problemas JSHOP2 para el dominio de logística de emergencias.
Ejercicio 1.1 - Práctica 2 - Planificación Automática 2025-26

Uso:
    python3 generate_problem_shop2.py -d <drones> -l <locations> -p <persons>
                                      -c <crates> -g <goals> [-o <fichero>]
"""

from optparse import OptionParser
import random
import sys

content_types = ["food", "medicine"]


def generate(drones, locations, persons, crates, goals, domain_name="emergency-advanced"):
    drones_l  = ["drone"  + str(i+1) for i in range(drones)]
    locs_l    = ["loc" + str(i+1) for i in range(locations)]

    # Repartimos el total de cajas (crates) entre el stock de food y medicine en el depot
    food_stock = random.randint(0, crates)
    medicine_stock = crates - food_stock

    # Asignamos los 'goals' (necesidades) garantizando que no superen el stock
    food_need = 0
    medicine_need = 0
    for _ in range(goals):
        choices = []
        if food_need < food_stock: choices.append("food")
        if medicine_need < medicine_stock: choices.append("medicine")
        choice = random.choice(choices)
        if choice == "food": food_need += 1
        else: medicine_need += 1

    # Distribuimos las necesidades entre las localizaciones
    loc_needs = {l: {"food": 0, "medicine": 0} for l in locs_l}
    for _ in range(food_need):
        loc_needs[random.choice(locs_l)]["food"] += 1
    for _ in range(medicine_need):
        loc_needs[random.choice(locs_l)]["medicine"] += 1

    lines = [f"(defproblem problem {domain_name}", "("]
    
    # Drones
    for d in drones_l:
        lines.append("  (at-drone " + d + " depot)")
        lines.append("  (drone-free " + d + ")")

    # Carriers (por defecto añadimos dos con las capacidades del ejemplo)
    carriers = [("carrier-big", 8), ("carrier-small", 3)]
    for ca, cap in carriers:
        lines.append(f"  (at-carrier {ca} depot)")
        lines.append(f"  (carrier-capacity {ca} {cap})")
        lines.append(f"  (carrier-free-space {ca} {cap})")
        lines.append(f"  (carrier-stock {ca} food 0)")
        lines.append(f"  (carrier-stock {ca} medicine 0)")

    # Stock en el depot
    lines.append(f"  (location-stock depot food {food_stock})")
    lines.append(f"  (location-stock depot medicine {medicine_stock})")

    # Necesidades y stock por localización
    for l in locs_l:
        f_need = loc_needs[l]["food"]
        m_need = loc_needs[l]["medicine"]
        lines.append(f"  (location-need {l} food {f_need})")
        lines.append(f"  (location-need {l} medicine {m_need})")
        lines.append(f"  (location-total-need {l} {f_need + m_need})")
        lines.append(f"  (location-stock {l} food 0)")
        lines.append(f"  (location-stock {l} medicine 0)")

    lines.append(")")
    # Tarea principal
    lines.append("((enviar-todo))")
    lines.append(")")
    return "\n".join(lines)


def main():
    parser = OptionParser()
    parser.add_option('-d', '--drones',    dest='drones',    type=int)
    parser.add_option('-l', '--locations', dest='locations', type=int)
    parser.add_option('-p', '--persons',   dest='persons',   type=int)
    parser.add_option('-c', '--crates',    dest='crates',    type=int)
    parser.add_option('-g', '--goals',     dest='goals',     type=int)
    parser.add_option('-o', '--output',    dest='output',    default=None)

    (options, args) = parser.parse_args()

    if None in [options.drones, options.locations,
                options.persons, options.crates, options.goals]:
        print("Parámetros obligatorios: -d -l -p -c -g")
        sys.exit(1)

    if options.goals > options.crates:
        print("No puede haber más goals que cajas"); sys.exit(1)
    if len(content_types) > options.crates:
        print("No puede haber más tipos que cajas"); sys.exit(1)
    if options.goals > len(content_types) * options.persons:
        print("Demasiados goals para las personas"); sys.exit(1)

    text = generate(options.drones, options.locations,
                    options.persons, options.crates, options.goals)

    out = options.output or (
        "emergency_d" + str(options.drones) +
        "_l" + str(options.locations) +
        "_p" + str(options.persons) +
        "_c" + str(options.crates) +
        "_g" + str(options.goals)
    )
    with open(out, 'w') as f:
        f.write(text)
    print("Fichero generado: " + out)


if __name__ == '__main__':
    main()
