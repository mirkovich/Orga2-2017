import matplotlib.pyplot as plt
import numpy as np
import csv, operator
import sys


tiempoTotalASM = 0
tiempoTotalC = 0
promedioTiempoASM = 0 
promedioTiempoC = 0
cantidadDeCorridas = 0
	
with open (sys.argv[1]) as cvsarchivo:
	entrada = csv.reader(cvsarchivo)
	

	for reg in entrada:		
		if ((str)(reg[0]) == "0"):
			tiempoTotalC = tiempoTotalC +(int)(reg[1])
			
		else:
			tiempoTotalASM = tiempoTotalASM + (int)(reg[1])
			cantidadDeCorridas = cantidadDeCorridas + 1
			
	promedioTiempoASM = tiempoTotalASM / cantidadDeCorridas
	promedioTiempoC = tiempoTotalC / cantidadDeCorridas
	
	lenguajes = ("C","ASM")
	tiempoPromedio = (promedioTiempoC,promedioTiempoASM)
	position_y = np.arange(len(lenguajes))
	plt.barh(position_y, tiempoPromedio,color = "br",align = "center")
	plt.yticks(position_y,lenguajes)
	plt.xlabel('cantidad de ciclos de clocks')
	plt.title("Promedio de ciclos de clocks C y ASM")
	plt.show()	
		
