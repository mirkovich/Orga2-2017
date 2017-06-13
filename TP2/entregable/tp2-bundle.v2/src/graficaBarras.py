import matplotlib.pyplot as plt
import numpy as np
import csv, operator
import sys
import math


tiempoTotalASM = 0
tiempoTotalC = 0
promedioTiemposASM = 0 
promedioTiemposC = 0
cantidadDeCorridas = 0
tiemposC = []
tiemposASM = []
sumASM =[]
sumC = []
p90 = 0
p10 = 0

with open (sys.argv[1]) as cvsarchivo:
	entrada = csv.reader(cvsarchivo)

	for reg in entrada:		
		if ((str)(reg[0]) == "0"):
			tiempoTotalC = tiempoTotalC +(int)(reg[1])
			tiemposC.append((int)(reg[1]))
		else:
			tiempoTotalASM = tiempoTotalASM + (int)(reg[1])
			cantidadDeCorridas = cantidadDeCorridas + 1
			tiemposASM.append((int)(reg[1]))
			
	promedioTiemposASM = tiempoTotalASM / cantidadDeCorridas
	promedioTiemposC = tiempoTotalC / cantidadDeCorridas
	
	tiemposASMAux = tiemposASM
	tiemposCAux = tiemposC 
	
	tiemposASMAux1 = [(x - promedioTiemposASM)**2 for x in tiemposASMAux ] 
	tiemposCAux1 = [(x - promedioTiemposC)**2 for x in tiemposCAux]
	
	sumASM = 0
	for i in  tiemposASMAux1:
		sumASM = sumASM + i 
		
	sumC = 0
	for i in tiemposCAux1:
		sumC = sumC + i  
	
	varianzaASM = sumASM /cantidadDeCorridas
	varianzaC = sumC / cantidadDeCorridas
	
	dsASM = math.sqrt(varianzaASM)
	dsC = math.sqrt(varianzaC)
		
	p90asm = promedioTiemposASM + 1.282 * dsASM
	p10asm = promedioTiemposASM - 1.282 * dsASM
	
 	p90c = promedioTiemposC + 1.282 * dsC
	p10c = promedioTiemposC - 1.282 * dsC
	
	tiemposASMfiltrados = [x for x in tiemposASM if ( p90asm >=  (float)(x)) or ( (float)(x) >= p10asm)]
	tiemposCfiltrados = [x for x in tiemposASM if (p90c >= (float)(x)) or (((float)(x)) >= p10c )]
	
	sumASMfiltrado = 0
	sumCfiltrado = 0 
	for i in tiemposASMfiltrados:
		sumASMfiltrado = sumASMfiltrado + i

	for i in tiemposCfiltrados:
		sumCfiltrado = sumCfiltrado + i 	
	
	promedioTiemposASMfiltrado = sumASMfiltrado /len(tiemposASMfiltrados) 
	promedioTiemposCfiltrado = sumCfiltrado /len(tiemposCfiltrados) 


	lenguajes = ("C","ASM")
	tiempoPromedio = (promedioTiemposCfiltrado,promedioTiemposASMfiltrado)
	position_y = np.arange(len(lenguajes))
	plt.barh(position_y, tiempoPromedio,color = "br",align = "center")
	plt.yticks(position_y,lenguajes)
	plt.xlabel('cantidad de ciclos de clocks')
	plt.title("Promedio de ciclos de clocks C y ASM")
	plt.show()	
		
