#!/usr/bin/env python3
"""
Benchmark de JSHOP2 – Ejercicio 1.1 - Práctica 2 - Planificación Automática 2025-26

Uso (desde la carpeta donde está este script, junto al fichero 'emergency'):
    python3 benchmark_shop2.py

Genera dos ficheros PNG en la misma carpeta que el script:
  - benchmark_comparativa.png  →  FF clásico vs. JSHOP2 (gráfica mejorada)
  - benchmark_jshop2.png       →  solo tiempos de JSHOP2

Requisitos:
  - JSHOP2 instalado en ~/JSHOP2/
  - Fichero 'emergency' (dominio sin extensión) en el mismo directorio que este script
"""

import subprocess, time, os, shutil, random, argparse
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.ticker as ticker

# ── Rutas ─────────────────────────────────────────────────────────────────────
JSHOP2_ROOT = os.path.expanduser("~/JSHOP2")
CONSOLE_SH  = os.path.join(JSHOP2_ROOT, "jshop2-console.sh")
DOMAIN_NAME = "emergency"
DOMAIN_DIR  = os.path.join(JSHOP2_ROOT, "domains", DOMAIN_NAME)
DOMAIN_SRC  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "emergency")

TIMEOUT = 120

# ── Configuraciones de tamaño creciente ──────────────────────────────────────
# Mismos parámetros que usaste: d=1, l=p=c=g=n
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

# Tiempos del planificador FF (Práctica 1), indexados por tamaño n
FF_TIMES = {
    5: 0.00, 10: 0.00, 20: 0.23, 30: 3.18, 35: 6.12,
    40: 10.95, 41: 12.98, 42: 35.07, 43: 32.64, 44: 56.31,
    45: 31.01, 46: 46.46, 47: 100.72, 48: 101.51, 49: 88.79,
    50: 64.70, 51: 260.63, 52: 109.04, 55: 498.76
}

content_types = ["food", "medicine"]

# ── Generador de problemas ────────────────────────────────────────────────────

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
        if "No plan" in out or out.strip() == "":
            return elapsed, out
        return None, "Sin plan reconocible:\n" + out[:600]

    except subprocess.TimeoutExpired:
        return None, f"TIMEOUT (>{TIMEOUT}s)"
    except FileNotFoundError as e:
        return None, str(e)

# ── Gráficas ──────────────────────────────────────────────────────────────────

def plot_comparison(sizes, times_shop2, outfile):
    """
    Gráfica comparativa FF vs JSHOP2.
    Panel izquierdo: escala logarítmica (muestra toda la diferencia).
    Panel derecho: barras de speedup (cuántas veces más rápido es JSHOP2).
    """
    times_ff = [FF_TIMES.get(s, None) for s in sizes]

    # Filtrar pares donde ambos tienen dato
    paired = [(s, sh, ff) for s, sh, ff in zip(sizes, times_shop2, times_ff)
              if sh is not None and ff is not None]
    if not paired:
        print("Sin datos para la gráfica comparativa.")
        return

    ps, psh, pff = zip(*paired)

    fig, axes = plt.subplots(1, 2, figsize=(16, 6))
    fig.patch.set_facecolor("#F7F9FC")

    # ── Panel 1: escala log ───────────────────────────────────────────────────
    ax = axes[0]
    ax.set_facecolor("#F0F4F8")

    ax.plot(ps, pff, 'o-', color='#E05C5C', lw=2.5, ms=8, zorder=3,
            label='Planificador clásico (FF)', markeredgecolor='white', markeredgewidth=1.2)
    ax.plot(ps, psh, 's-', color='#2B7EC1', lw=2.5, ms=8, zorder=3,
            label='JSHOP2 (HTN)', markeredgecolor='white', markeredgewidth=1.2)

    # Sombrear la zona entre ambas curvas
    ax.fill_between(ps, pff, psh, alpha=0.15, color='#E05C5C',
                    label='Diferencia de rendimiento')

    # Límite de 1 minuto
    ax.axhline(60, color='#FF9500', lw=1.8, linestyle='--', alpha=0.8, label='Límite 1 minuto')

    ax.set_yscale('log')
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f"{x:.2f}s"))
    ax.set_xlabel("Tamaño del problema (n)", fontsize=12, labelpad=8)
    ax.set_ylabel("Tiempo de resolución (segundos, escala log)", fontsize=11)
    ax.set_title("FF clásico vs. JSHOP2\n(escala logarítmica)", fontsize=13, fontweight='bold', pad=12)
    ax.legend(fontsize=10, framealpha=0.9)
    ax.grid(True, which='both', linestyle='--', alpha=0.4)
    ax.grid(True, which='major', linestyle='--', alpha=0.6)
    ax.set_xlim(min(ps) - 1, max(ps) + 1)

    # Anotaciones en los extremos más llamativos
    max_ff_idx = pff.index(max(pff))
    ax.annotate(f"{max(pff):.0f}s",
                xy=(ps[max_ff_idx], pff[max_ff_idx]),
                xytext=(ps[max_ff_idx] - 4, pff[max_ff_idx] * 1.8),
                fontsize=9, color='#E05C5C', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='#E05C5C', lw=1.2))

    # ── Panel 2: speedup en barras ────────────────────────────────────────────
    ax2 = axes[1]
    ax2.set_facecolor("#F0F4F8")

    speedups = [ff / sh if sh > 0 else 0 for ff, sh in zip(pff, psh)]
    # Colorear según magnitud del speedup
    colors = ['#2B7EC1' if sp < 10 else '#1A5C99' if sp < 50 else '#0D3A66'
              for sp in speedups]

    bars = ax2.bar(ps, speedups, color=colors, width=1.8, zorder=3,
                   edgecolor='white', linewidth=0.8)

    # Etiquetar cada barra con el valor de speedup
    for bar, sp in zip(bars, speedups):
        if sp > 0.5:
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
                     f"×{sp:.0f}" if sp >= 10 else f"×{sp:.1f}",
                     ha='center', va='bottom', fontsize=8.5, fontweight='bold',
                     color='#1A3A5C')

    ax2.axhline(1, color='#E05C5C', lw=1.8, linestyle='--', alpha=0.8,
                label='Mismo tiempo (speedup = 1×)')

    ax2.set_xlabel("Tamaño del problema (n)", fontsize=12, labelpad=8)
    ax2.set_ylabel("Speedup de JSHOP2 respecto a FF (veces más rápido)", fontsize=11)
    ax2.set_title("Aceleración de JSHOP2 sobre FF\n(speedup = t_FF / t_JSHOP2)", fontsize=13, fontweight='bold', pad=12)
    ax2.legend(fontsize=10, framealpha=0.9)
    ax2.grid(True, axis='y', linestyle='--', alpha=0.5)
    ax2.set_xlim(min(ps) - 2, max(ps) + 2)

    # Leyenda de colores
    patch_low  = mpatches.Patch(color='#2B7EC1',  label='Speedup < 10×')
    patch_mid  = mpatches.Patch(color='#1A5C99',  label='Speedup 10–50×')
    patch_high = mpatches.Patch(color='#0D3A66',  label='Speedup > 50×')
    ax2.legend(handles=[patch_low, patch_mid, patch_high,
                         mpatches.Patch(color='#E05C5C', label='Referencia 1×')],
               fontsize=9, framealpha=0.9, loc='upper left')

    fig.suptitle("Comparativa de Rendimiento: Planificación Clásica vs. Jerárquica\n"
                 "Ejercicio 1.1 – Logística de Emergencias",
                 fontsize=14, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig(outfile, dpi=180, bbox_inches='tight')
    print(f"Gráfica comparativa guardada en: {outfile}")


def plot_jshop2_only(sizes, times_shop2, outfile):
    """
    Gráfica exclusiva de JSHOP2: línea de tiempo + banda de variación + media.
    """
    paired = [(s, t) for s, t in zip(sizes, times_shop2) if t is not None]
    if not paired:
        print("Sin datos para la gráfica de JSHOP2.")
        return

    ps, pt = zip(*paired)
    mean_t  = np.mean(pt)
    std_t   = np.std(pt)

    fig, ax = plt.subplots(figsize=(13, 6))
    fig.patch.set_facecolor("#F7F9FC")
    ax.set_facecolor("#F0F4F8")

    # Banda ±1 desviación típica
    ax.fill_between(ps,
                    [mean_t - std_t] * len(ps),
                    [mean_t + std_t] * len(ps),
                    alpha=0.18, color='#2B7EC1', label=f'Banda ±1σ ({std_t:.3f}s)')

    # Línea de media
    ax.axhline(mean_t, color='#1A5C99', lw=2, linestyle='--', alpha=0.85,
               label=f'Media = {mean_t:.3f}s')

    # Curva principal
    ax.plot(ps, pt, 'o-', color='#2B7EC1', lw=2.5, ms=9, zorder=4,
            markeredgecolor='white', markeredgewidth=1.5, label='JSHOP2 (HTN)')

    # Marcar máximo y mínimo
    max_idx = pt.index(max(pt))
    min_idx = pt.index(min(pt))
    ax.annotate(f"máx: {max(pt):.2f}s",
                xy=(ps[max_idx], pt[max_idx]),
                xytext=(ps[max_idx] + 1.5, pt[max_idx] + 0.1),
                fontsize=9, color='#E05C5C', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='#E05C5C', lw=1.2))
    ax.annotate(f"mín: {min(pt):.2f}s",
                xy=(ps[min_idx], pt[min_idx]),
                xytext=(ps[min_idx] + 1.5, pt[min_idx] - 0.18),
                fontsize=9, color='#27AE60', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='#27AE60', lw=1.2))

    ax.set_xlabel("Tamaño del problema (n)", fontsize=12, labelpad=8)
    ax.set_ylabel("Tiempo de resolución (segundos)", fontsize=12)
    ax.set_title("Tiempo de resolución de JSHOP2 según el tamaño del problema\n"
                 "Ejercicio 1.1 – Logística de Emergencias (HTN)",
                 fontsize=13, fontweight='bold', pad=12)
    ax.legend(fontsize=10, framealpha=0.9)
    ax.grid(True, linestyle='--', alpha=0.5)
    ax.set_xlim(min(ps) - 1, max(ps) + 2)
    ax.set_ylim(0, max(pt) * 1.3)

    # Texto con estadísticas en la esquina
    stats_text = (f"n = {len(pt)} problemas\n"
                  f"Media: {mean_t:.3f}s\n"
                  f"σ: {std_t:.3f}s\n"
                  f"Rango: [{min(pt):.2f}, {max(pt):.2f}]s")
    ax.text(0.02, 0.97, stats_text, transform=ax.transAxes,
            fontsize=9.5, verticalalignment='top', color='#1A3A5C',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='white', alpha=0.85, edgecolor='#AAAAAA'))

    plt.tight_layout()
    plt.savefig(outfile, dpi=180, bbox_inches='tight')
    print(f"Gráfica JSHOP2 guardada en: {outfile}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output-comparison', default='benchmark_comparativa.png',
                        help='Nombre del PNG comparativo FF vs. JSHOP2')
    parser.add_argument('--output-jshop2', default='benchmark_jshop2.png',
                        help='Nombre del PNG solo con tiempos de JSHOP2')
    args = parser.parse_args()

    print("Preparando carpeta de dominio:", DOMAIN_DIR)
    prepare()
    print()

    labels, sizes, times = [], [], []

    for drones, locs, persons, crates, goals, label in CONFIGS:
        print("─" * 55)
        print("Problema:", label)
        write_problem(generate_problem(drones, locs, persons, crates, goals))
        print("  Ejecutando JSHOP2...", end=" ", flush=True)
        t, out = run_jshop2()
        labels.append(label)
        sizes.append(locs)   # n = locations = persons = crates = goals
        if t is not None:
            print(f"{t:.4f}s  ✓")
            times.append(t)
        else:
            print("FALLO")
            print("  →", out[:400])
            times.append(None)

    # ── Tabla resumen ─────────────────────────────────────────────────────────
    print("\n" + "=" * 55)
    print(f"{'Problema':<20} {'n':>4} {'JSHOP2 (s)':>12} {'FF (s)':>10} {'Speedup':>10}")
    print("-" * 55)
    for label, n, t in zip(labels, sizes, times):
        ff = FF_TIMES.get(n, None)
        if t is not None and ff is not None and t > 0:
            sp = f"×{ff/t:.1f}"
        else:
            sp = "-"
        t_str  = f"{t:.4f}" if t is not None else "FALLO"
        ff_str = f"{ff:.2f}" if ff is not None else "-"
        print(f"{label:<20} {n:>4} {t_str:>12} {ff_str:>10} {sp:>10}")

    # ── Gráficas ──────────────────────────────────────────────────────────────
    script_dir = os.path.dirname(os.path.abspath(__file__))
    out_comp   = os.path.join(script_dir, args.output_comparison)
    out_shop2  = os.path.join(script_dir, args.output_jshop2)

    plot_comparison(sizes, times, out_comp)
    plot_jshop2_only(sizes, times, out_shop2)


if __name__ == '__main__':
    main()