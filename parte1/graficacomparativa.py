import matplotlib.pyplot as plt

sizes = [5,10,20,30,35,40,41,42,43,44,45,46,47,48,49,50,51,52,55]
times = [0.00,0.00,0.23,3.18,6.12,10.95,12.98,35.07,32.64,56.31,
         31.01,46.46,100.72,101.51,88.79,64.70,260.63,109.04,498.76]

plt.figure(figsize=(10, 6)) # Un poco más grande para que se vea mejor
plt.plot(sizes, times, marker='o', label="Tiempo FF")

# --- ESTA ES LA PARTE NUEVA ---
plt.axhline(y=60, color='r', linestyle='--', linewidth=1.5, label="Límite 60s")
# ------------------------------

plt.xlabel("Tamaño del problema (l=p=c=g)")
plt.ylabel("Tiempo (segundos)")
plt.title("Tiempo de resolución con FF")

plt.legend() # Añadimos la leyenda para identificar la línea roja
plt.grid(True, linestyle=':', alpha=0.6) # Rejilla suave para facilitar la lectura

# Si estás en terminal, recuerda que savefig es lo más fiable:
plt.savefig("grafica_comparativa.png")
print("Imagen guardada como 'grafica_comparativa.png'")

plt.show()