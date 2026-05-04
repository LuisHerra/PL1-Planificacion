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


def setup_content_types(n_crates, n_persons, n_goals):
    while True:
        num_per_type, left = [], n_crates
        for i in range(len(content_types) - 1):
            n = random.randint(1, left - (len(content_types) - i - 1))
            num_per_type.append(n)
            left -= n
        num_per_type.append(left)
        if sum(min(n, n_persons) for n in num_per_type) >= n_goals:
            break
    crates_by_type, counter = [], 1
    for i in range(len(content_types)):
        group = []
        for _ in range(num_per_type[i]):
            group.append("crate" + str(counter))
            counter += 1
        crates_by_type.append(group)
    return crates_by_type


def setup_needs(n_persons, crates_by_type, n_goals):
    need = [[False] * len(content_types) for _ in range(n_persons)]
    goals_per = [0] * len(content_types)
    for _ in range(n_goals):
        ok = False
        while not ok:
            rp = random.randint(0, n_persons - 1)
            rt = random.randint(0, len(content_types) - 1)
            if goals_per[rt] < len(crates_by_type[rt]) and not need[rp][rt]:
                need[rp][rt] = True
                goals_per[rt] += 1
                ok = True
    return need


def generate(drones, locations, persons, crates, goals, domain_name="emergency"):
    drones_l  = ["drone"  + str(i + 1) for i in range(drones)]
    persons_l = ["person" + str(i + 1) for i in range(persons)]
    crates_l  = ["crate"  + str(i + 1) for i in range(crates)]
    locs_l    = ["depot"] + ["loc" + str(i + 1) for i in range(locations)]

    cbt  = setup_content_types(crates, persons, goals)
    need = setup_needs(persons, cbt, goals)

    lines = []
    lines.append("(defproblem problem " + domain_name)

    # ── Estado inicial (primer argumento) ─────────────────────────────────────
    lines.append("(")
    for d in drones_l:
        lines.append("  (at-drone " + d + " depot)")
    for d in drones_l:
        for arm in [d + "_arm1", d + "_arm2"]:
            lines.append("  (arm-of " + arm + " " + d + ")")
            lines.append("  (free " + arm + ")")
    for c in crates_l:
        lines.append("  (at-crate " + c + " depot)")
    for ti, group in enumerate(cbt):
        for cn in group:
            lines.append("  (crate-has " + cn + " " + content_types[ti] + ")")
    for p in persons_l:
        lines.append("  (at-person " + p + " " + random.choice(locs_l[1:]) + ")")
    for pi in range(persons):
        for ti in range(len(content_types)):
            if need[pi][ti]:
                lines.append("  (needs " + persons_l[pi] + " " + content_types[ti] + ")")
    lines.append(")")

    # ── Lista de tareas (segundo argumento) ───────────────────────────────────
    # Igual que en el ejemplo basic: ((swap banjo kiwi))
    # El paréntesis externo es la lista, el interno es la tarea
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
