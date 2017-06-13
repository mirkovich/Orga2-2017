# Orga2-2017
El siguiente trabajo es un trabajo práctico de la materia Organización del Computador II.

## Experimentación


Para la exerimentación se realizaron modificaciones en el archivo tp2.c (toda modificación está seguida de un pequeño comentario en el código mismo). 

Se agregó un archivo llamado runTest-C-ASM.sh, es un archivo bash que se ejecuta de la siguiente manera:

En el directorio donde se encuentra el archivo abrimos una terminal y escribimos .\runTest-C-ASM.sh (filtro) (imagen fuente) (imagen destino) (cantidad de ejecuciones)

Esto genera un archivo .cvs llamado "nombredelfiltro.resumendeTiempos.cvs"

con el siguiente formato:


+ 0,136549902
+ 1,50362122
+ 0,90641315
+ 1,51551641
+ 0,79705739
+ 1,27913742
+ 0,79957740
+ 1,45484656
+ 0,64804546
+ 1,30166855

Donde el 0 hace referencia a C y el 1 a ASM, y los números que continua a cada uno es la cantidad de clocks que tarda el filtro tanto en C como en ASM 

## Gráfica

Para poder tener estos datos de una forma más explicita se realizó un plot que realiza (dado un archivo.cvs) un gráfico de barras en el cual se observa una comparacion entre la media de correr el filtro en C y la media en ASM. 

Para el buen uso de la misma simplemente hay que correr:

python graficaBarras.py archivo.cvs (*)

(*) tambien funciona con python2, pero no funciona con python3.
