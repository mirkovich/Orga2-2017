import pylab as pl  
import csv  
import sys
import matplotlib.pyplot as plt
import math
 
entrada = open(sys.argv[1])  
tabla = []  
 
for fila in csv.reader(entrada):  
	tabla.append(fila)  
entrada.close()  
x=[0]  
y=[0]  
promedioX =[0]
promedioY = [0]

for fila in range(1, len(tabla)):  
	x.append(int(tabla[fila][0]))  
	y.append(int(tabla[fila][1]))  
 
	#~ codigo para obtener el promedio 
aux = 0
count = 0

for i in range(0,len(tabla)):
	if i==0:
		aux += y[i]
		count+=1
	elif x[i] == x[i-1]:
		aux += y[i]
		count+=1
	else:
		promedioX.append(x[i-1])
		promedioY.append(float(aux/count))
		aux = y[i]
		count=1


entrada2 = open(sys.argv[2])  
tabla2 = []  
 
for fila2 in csv.reader(entrada2):  
	tabla2.append(fila2)  
entrada2.close()  
x2=[0]  
y2=[0]  
promedioX2 =[0]
promedioY2 = [0]

for fila2 in range(1, len(tabla2)):  
	x2.append(int(tabla2[fila2][0]))  
	y2.append(int(tabla2[fila2][1]))  
 
	#~ codigo para obtener el promedio 
aux2 = 0
count2 = 0

for i in range(0,len(tabla2)):
	if i==0:
		aux2 += y2[i]
		count2+=1
	elif x2[i] == x2[i-1]:
		aux2 += y2[i]
		count2 += 1
	else:
		promedioX2.append(x2[i-1])
		promedioY2.append(float(aux2/count2))
		aux2 = y2[i]
		count2 =1



minx = 0
maxx = 550
miny = 0
maxy = max(max(y), max(y2))

#Setea limites del ejeX y del ejeY
plt.xlim(minx, maxx)
#~ plt.ylim(miny, maxy)


#Setea el nombre del eje Y
plt.ylabel( '#ciclos cloks' )

#Setea el nombre del eje X
plt.xlabel( 'Tamanio de imagenes' )

plt.title( 'C vs ASM' )


#~ cambiamos x e y por promedioX y promedioY .... para graficar con o sin promedio. 

plt.plot(promedioX, promedioY, 'ro', label = "ASM1")
plt.plot(promedioX2, promedioY2, 'go', label = "ASM2")
plt.yscale('log')

plt.legend()

#Con esto muestra el grafico generado
plt.show()


#~ pl.scatter(promedioX,promedioY)  
#~ pl.xlabel('Tiempo[s]')  
#~ pl.ylabel('Tension[V]')  
#~ pl.title('Ejemplo de grafica de un archivo csv')  
#~ pl.savefig('imagen.png')  
#~ pl.show() 
