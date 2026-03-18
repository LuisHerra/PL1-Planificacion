import subprocess
import time
import re
import os

def run_optic(domain, problem, timeout=60):
    """
    Ejecuta el planificador Optic en modo anytime durante 'timeout' segundos.
    Devuelve la métrica del primer paso temporal y del último paso encontrado.
    """
    # Se añade tee o simplemente se procesa el output de stdout de subprocess.
    # Dado que Optic lo hace de modo continuo ("anytime"), puede ir sacando varios planes.
    
    # Asume que optic es ejecutable en el PATH
    cmd = ["optic", "-N", domain, problem]
    
    start_time = time.time()
    try:
        # Se lanza con un timeout
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        output = result.stdout
    except subprocess.TimeoutExpired as e:
        # Recuperamos la salida de lo que haya procesado hasta el timeout
        if e.stdout is not None:
            if isinstance(e.stdout, bytes):
                output = e.stdout.decode('utf-8', errors='ignore')
            else:
                output = e.stdout
        else:
            output = ""

    # Parsear los planes de Optic.
    # Optic va haciendo output de "Found plan ... with cost (or makespan) X" o genera ficheros con los planes.
    # Si usamos la salida estándar, buscaremos el makespan de cada iteración.
    makespans = []
    steps = []
    
    # En Optic los planes suelen ir guardados como plan.pddl.1, plan.pddl.2, etc. o muestra makespan en pantalla.
    # Vamos a buscar patrones de log estilo "Plan found with objective: X" o buscaremos los archivos de plan directamente si es necesario.
    for line in output.split('\n'):
        # Optic output details?
        if "Plan found with metric" in line:
            m = re.search(r'Plan found with metric\s+([0-9.]+)', line)
            if m:
                makespans.append(float(m.group(1)))
        
        # En la salida podría salir el número de pasos o similar, dependiendo del log verboso.
        
    return makespans, output

def generate_problem(drones, carriers, locations, persons, crates, goals):
    cmd = [
        "python", "generate-problem3.py",
        "-d", str(drones),
        "-r", str(carriers),
        "-l", str(locations),
        "-p", str(persons),
        "-c", str(crates),
        "-g", str(goals)
    ]
    subprocess.run(cmd)
    
    problem_name = f"emergency_carrier_d{drones}_r{carriers}_l{locations}_p{persons}_c{crates}_g{goals}.pddl"
    return problem_name

def main():
    print("Iniciando pruebas de rendimiento con planificador Optic...")
    print(f"{'Drones':^8} | {'Carriers':^10} | {'1º Plan (Dur)':^15} | {'Ultimo Plan (Dur)':^20}")
    print("-" * 65)
    
    max_drones = 5
    for size in range(1, max_drones + 1):
        drones = size
        carriers = size
        # Fijamos cierta complejidad pequeña para el resto de variables
        # Incrementando el problema linealmente con el numero de drones
        locations = size + 2
        persons = size + 1
        crates = size + 1
        goals = size
        
        prob_file = generate_problem(drones, carriers, locations, persons, crates, goals)
        
        try:
            print(f"Probando {prob_file} durante 60 segundos...")
            makespans, output = run_optic("domain3.pddl", prob_file, timeout=60)
            
            if len(makespans) == 0:
                print(f"{drones:^8} | {carriers:^10} | {'Sin Solucion':^15} | {'Sin solucion':^20}")
            else:
                first_plan_dur = makespans[0]
                last_plan_dur = makespans[-1]
                print(f"{drones:^8} | {carriers:^10} | {first_plan_dur:^15} | {last_plan_dur:^20}")
        except FileNotFoundError:
            print("\nError: No se ha encontrado el ejecutable 'optic' en el sistema.")
            print("Por favor, instala Optic (o ponlo en el PATH de entorno) y vuelve a intentarlo.")
            break

if __name__ == '__main__':
    main()
