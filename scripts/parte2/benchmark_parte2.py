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
DOMAIN_NAME = "emergency_advanced"
CONSOLE_SH  = os.path.join(JSHOP2_ROOT, "jshop2-console.sh")
DOMAIN_DIR  = os.path.join(JSHOP2_ROOT, "domains", DOMAIN_NAME)
DOMAIN_SRC  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emergency_advanced")

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

def generate_problem(drones, locations, persons, crates, goals):
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

    lines = ["(defproblem problem emergency_advanced", "("]
    
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

def plot_advanced(labels, sizes, results, outfile, show_poincare=False):
    """
    Genera un dashboard con:
    1. Tiempo medio vs Tamaño (con banda de desviación)
    2. Esfuerzo relativo (Tiempo / n)
    3. Escalabilidad Log-Log
    4. Diagrama de Poincaré (solo si show_poincare=True)
    """
    import numpy as np
    import matplotlib.ticker as ticker

    # Filtrar datos válidos
    valid_labels = []
    valid_sizes = []
    means = []
    stds = []
    all_times = [] # Para Poincaré
    
    for label, size in zip(labels, sizes):
        times = [t for t in results[label] if t is not None]
        if times:
            valid_labels.append(label)
            valid_sizes.append(size)
            means.append(np.mean(times))
            stds.append(np.std(times))
            all_times.append(times)

    if not valid_sizes:
        print("Sin datos suficientes para graficar."); return

    n_rows = 2 if show_poincare else 1
    n_cols = 2
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(15, 6 * n_rows))
    fig.patch.set_facecolor("#F8F9FA")
    axes = axes.flatten()

    # ── 1. Tiempo Medio con Desviación ───────────────────────────────────────
    ax = axes[0]
    ax.set_facecolor("#FFFFFF")
    ax.errorbar(valid_sizes, means, yerr=stds, fmt='o-', color='#2B7EC1', 
                ecolor='#A0C4E4', capsize=4, elinewidth=1.5, markeredgecolor='white',
                label='Media ± σ')
    ax.fill_between(valid_sizes, np.array(means)-np.array(stds), np.array(means)+np.array(stds), 
                    alpha=0.1, color='#2B7EC1')
    ax.set_title("Tiempo de Resolución vs. Tamaño", fontweight='bold')
    ax.set_xlabel("Tamaño n (localizaciones/necesidades)")
    ax.set_ylabel("Segundos")
    ax.grid(True, linestyle='--', alpha=0.5)

    # ── 2. Esfuerzo Relativo (Tiempo / n) ────────────────────────────────────
    ax = axes[1]
    ax.set_facecolor("#FFFFFF")
    effort = [m / s for m, s in zip(means, valid_sizes)]
    ax.plot(valid_sizes, effort, 's-', color='#E67E22', markeredgecolor='white')
    ax.set_title("Esfuerzo Relativo (Segundos / n)", fontweight='bold')
    ax.set_xlabel("Tamaño n")
    ax.set_ylabel("Segundos por unidad de n")
    ax.grid(True, linestyle='--', alpha=0.5)
    # Si la línea es plana, la escalabilidad es lineal O(n)

    # ── 3. Escalabilidad Log-Log ─────────────────────────────────────────────
    ax = axes[2]
    ax.set_facecolor("#FFFFFF")
    ax.loglog(valid_sizes, means, 'o-', color='#27AE60', markeredgecolor='white')
    # Ajuste lineal en log-log para calcular la pendiente (complejidad)
    log_s = np.log(valid_sizes)
    log_m = np.log(means)
    slope, intercept = np.polyfit(log_s, log_m, 1)
    ax.set_title(f"Escalabilidad Log-Log (Complejidad ≈ O(n^{slope:.1f}))", fontweight='bold')
    ax.set_xlabel("log(n)")
    ax.set_ylabel("log(Segundos)")
    ax.grid(True, which="both", linestyle='--', alpha=0.4)

    # ── 4. Diagrama de Poincaré ──────────────────────────────────────────────
    if show_poincare:
        ax = axes[3]
        ax.set_facecolor("#FFFFFF")
        x_p, y_p = [], []
        for times in all_times:
            if len(times) > 1:
                for i in range(len(times)-1):
                    x_p.append(times[i])
                    y_p.append(times[i+1])
        ax.scatter(x_p, y_p, alpha=0.6, edgecolors='white', color='#8E44AD')
        # Línea identidad
        max_val = max(max(x_p), max(y_p)) if x_p else 1
        ax.plot([0, max_val], [0, max_val], '--', color='gray', alpha=0.5)
        ax.set_title("Diagrama de Poincaré (t_i vs t_{i+1})", fontweight='bold')
        ax.set_xlabel("Tiempo ejecución i")
        ax.set_ylabel("Tiempo ejecución i+1")
        ax.grid(True, linestyle='--', alpha=0.5)
    else:
        # Si no hay Poincaré, ocultamos el cuarto eje si existe
        if len(axes) > 3: axes[3].axis('off')

    plt.tight_layout()
    plt.savefig(outfile, dpi=160)
    print(f"\nDashboard de análisis guardado en: {outfile}")

# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', default='benchmark_parte2_analytics.png')
    parser.add_argument('--poincare_full', action='store_true', 
                        help='Ejecuta 5 veces cada tamaño para análisis de estabilidad')
    args = parser.parse_args()

    print("Preparando carpeta de dominio:", DOMAIN_DIR)
    prepare()
    print()

    iterations = 5 if args.poincare_full else 1
    results = { label: [] for _, _, _, _, _, label in CONFIGS }
    all_sizes = []
    all_labels = []

    for drones, locs, persons, crates, goals, label in CONFIGS:
        print("─" * 60)
        print(f"Problema: {label:<10} (n={locs})")
        all_sizes.append(locs)
        all_labels.append(label)
        
        for i in range(iterations):
            suffix = f" [Run {i+1}/{iterations}]" if iterations > 1 else ""
            write_problem(generate_problem(drones, locs, persons, crates, goals))
            print(f"  Ejecutando JSHOP2{suffix}...", end=" ", flush=True)
            t, out = run_jshop2()
            if t is not None:
                print(f"{t:.4f}s  ✓")
                results[label].append(t)
            else:
                print("FALLO")
                results[label].append(None)

    print("\n" + "=" * 55)
    print(f"{'Problema':<20} {'Media (s)':>12} {'Desv. σ':>10}")
    print("-" * 55)
    import numpy as np
    for label in all_labels:
        times = [t for t in results[label] if t is not None]
        if times:
            m = np.mean(times)
            s = np.std(times)
            print(f"{label:<20} {m:>12.4f} {s:>10.4f}")
        else:
            print(f"{label:<20} {'FALLO':>12} {'-':>10}")

    outfile = os.path.join(os.path.dirname(os.path.abspath(__file__)), args.output)
    plot_advanced(all_labels, all_sizes, results, outfile, show_poincare=args.poincare_full)

if __name__ == '__main__':
    main()
