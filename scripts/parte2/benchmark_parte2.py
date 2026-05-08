#!/usr/bin/env python3
"""
Benchmark de JSHOP2 – Ejercicio 1.1 - Práctica 2 - Planificación Automática 2025-26

Uso (desde la carpeta donde está este script, junto al fichero 'emergency'):
    python3 benchmark_shop2.py

Requisitos:
  - JSHOP2 instalado en ~/JSHOP2/
  - Fichero 'emergency' (dominio sin extensión) en el mismo directorio que este script
"""

import subprocess, time, os, shutil, random, argparse
import matplotlib.pyplot as plt

# ── Rutas ─────────────────────────────────────────────────────────────────────
JSHOP2_ROOT = os.path.expanduser("~/JSHOP2")
CONSOLE_SH  = os.path.join(JSHOP2_ROOT, "jshop2-console.sh")
DOMAIN_NAME = "emergency2"
DOMAIN_DIR  = os.path.join(JSHOP2_ROOT, "domains", DOMAIN_NAME)
DOMAIN_SRC  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emergency2")

TIMEOUT = 120

# ── Tamaños crecientes ────────────────────────────────────────────────────────
CONFIGS = [
    (1,  5,  5,  5,  5, "size5"),
    (1, 10, 10, 10, 10, "size10"),
    (1, 20, 20, 20, 20, "size20"),
    (1, 30, 30, 30, 30, "size30"),
    (1, 35, 35, 35, 35, "size35"),
    (1, 40, 40, 40, 40, "size40"),
    (1, 41, 41, 41, 41, "size41"),
    (1, 42, 42, 42, 42, "size42"),
    (1, 43, 43, 43, 43, "size43"),
    (1, 44, 44, 44, 44, "size44"),
    (1, 45, 45, 45, 45, "size45"),
    (1, 46, 46, 46, 46, "size46"),
    (1, 47, 47, 47, 47, "size47"),
    (1, 48, 48, 48, 48, "size48"),
    (1, 49, 49, 49, 49, "size49"),
    (1, 50, 50, 50, 50, "size50"),
    (1, 51, 51, 51, 51, "size51"),
    (1, 52, 52, 52, 52, "size52"),
    (1, 55, 55, 55, 55, "size55"),
]

content_types = ["food", "medicine"]

# ── Generador ─────────────────────────────────────────────────────────────────

def setup_content_types(n_crates, n_persons, n_goals):
    while True:
        num_per_type, left = [], n_crates
        for i in range(len(content_types) - 1):
            n = random.randint(1, left - (len(content_types) - i - 1))
            num_per_type.append(n); left -= n
        num_per_type.append(left)
        if sum(min(n, n_persons) for n in num_per_type) >= n_goals:
            break
    crates_by_type, counter = [], 1
    for i in range(len(content_types)):
        group = []
        for _ in range(num_per_type[i]):
            group.append("crate" + str(counter)); counter += 1
        crates_by_type.append(group)
    return crates_by_type

def setup_needs(n_persons, crates_by_type, n_goals):
    need = [[False]*len(content_types) for _ in range(n_persons)]
    goals_per = [0]*len(content_types)
    for _ in range(n_goals):
        ok = False
        while not ok:
            rp = random.randint(0, n_persons-1)
            rt = random.randint(0, len(content_types)-1)
            if goals_per[rt] < len(crates_by_type[rt]) and not need[rp][rt]:
                need[rp][rt] = True; goals_per[rt] += 1; ok = True
    return need

def generate_problem(drones, locations, persons, crates, goals):
    drones_l  = ["drone"  + str(i+1) for i in range(drones)]
    persons_l = ["person" + str(i+1) for i in range(persons)]
    crates_l  = ["crate"  + str(i+1) for i in range(crates)]
    locs_l    = ["depot"] + ["loc" + str(i+1) for i in range(locations)]

    cbt  = setup_content_types(crates, persons, goals)
    need = setup_needs(persons, cbt, goals)

    lines = ["(defproblem problem " + DOMAIN_NAME, "("]
    for d in drones_l:
        lines.append("  (at-drone " + d + " depot)")
    for d in drones_l:
        for arm in [d+"_arm1", d+"_arm2"]:
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
    # Doble paréntesis: externo = lista de tareas, interno = la tarea
    lines.append("((enviar-todo))")
    lines.append(")")
    return "\n".join(lines)

# ── JSHOP2 ────────────────────────────────────────────────────────────────────

def prepare():
    os.makedirs(DOMAIN_DIR, exist_ok=True)
    dest = os.path.join(DOMAIN_DIR, DOMAIN_NAME)
    if os.path.exists(DOMAIN_SRC):
        shutil.copy2(DOMAIN_SRC, dest)
        print("  Dominio copiado a:", dest)
    else:
        print("[AVISO] No se encontró el fichero de dominio:", DOMAIN_SRC)

def write_problem(text):
    with open(os.path.join(DOMAIN_DIR, "problem"), "w") as f:
        f.write(text)

def run_jshop2():
    """Devuelve (segundos, salida) o (None, mensaje_error)."""
    start = time.perf_counter()
    try:
        proc = subprocess.run(
            ["bash", CONSOLE_SH, DOMAIN_NAME],
            cwd=JSHOP2_ROOT,
            capture_output=True, text=True, timeout=TIMEOUT
        )
        elapsed = time.perf_counter() - start
        out = proc.stdout + proc.stderr

        if proc.returncode != 0:
            return None, f"Código {proc.returncode}:\n{out[:600]}"

        if "Plan" in out or "plan" in out or "!fly" in out or "!pick" in out or "!deliver" in out:
            return elapsed, out

        # Si no hay error pero tampoco plan, puede ser problema vacío (0 needs)
        if "No plan" in out or out.strip() == "":
            return elapsed, out   # plan vacío es válido

        return None, "Sin plan reconocible en la salida:\n" + out[:600]

    except subprocess.TimeoutExpired:
        return None, f"TIMEOUT (>{TIMEOUT}s)"
    except FileNotFoundError as e:
        return None, str(e)

# ── Gráfica ───────────────────────────────────────────────────────────────────

def plot(labels, times, outfile):
    vl = [l for l, t in zip(labels, times) if t is not None]
    vt = [t for t in times if t is not None]
    if not vt:
        print("Sin datos para graficar."); return

    fig, ax = plt.subplots(figsize=(13, 6))
    ax.plot(range(len(vl)), vt, 'o-', color='steelblue', lw=2.2, ms=8,
            label='JSHOP2 (HTN)')
    ax.set_xticks(range(len(vl)))
    ax.set_xticklabels(vl, rotation=28, ha='right', fontsize=9)
    ax.set_xlabel("Configuración del problema (tamaño creciente)", fontsize=11)
    ax.set_ylabel("Tiempo de resolución (segundos)", fontsize=11)
    ax.set_title("Tiempo de resolución vs. Tamaño del problema\n"
                 "Ejercicio 1.1 – JSHOP2 logística de emergencias", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, linestyle='--', alpha=0.55)
    plt.tight_layout()
    plt.savefig(outfile, dpi=160)
    print("\nGráfica guardada en:", outfile)

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', default='benchmark_shop2.png')
    args = parser.parse_args()

    print("Preparando carpeta de dominio:", DOMAIN_DIR)
    prepare()
    print()

    labels, times = [], []

    for drones, locs, persons, crates, goals, label in CONFIGS:
        print("─" * 55)
        print("Problema:", label)
        write_problem(generate_problem(drones, locs, persons, crates, goals))
        print("  Ejecutando JSHOP2...", end=" ", flush=True)
        t, out = run_jshop2()
        labels.append(label)
        if t is not None:
            print(f"{t:.4f}s  ✓")
            times.append(t)
        else:
            print("FALLO")
            print("  →", out[:400])
            times.append(None)

    print("\n" + "=" * 45)
    print(f"{'Problema':<28} {'Tiempo (s)':>15}")
    print("-" * 45)
    for l, t in zip(labels, times):
        print(f"{l:<28} {f'{t:.4f}' if t is not None else 'FALLO/TIMEOUT':>15}")

    outfile = os.path.join(os.path.dirname(os.path.abspath(__file__)), args.output)
    plot(labels, times, outfile)

if __name__ == '__main__':
    main()
