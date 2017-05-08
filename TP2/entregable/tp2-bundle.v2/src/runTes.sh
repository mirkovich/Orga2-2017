#!/bin/bash
 
cantDeIteracion=200
tipoFiltro=c
nombreFiltro=linearZoom
imagenFuente=lena.bmp
imegenDestino=lena.sh.bmp

for ((i=0 ; i< cantDeIteracion; i++)) 
do 
	./tp2 c linearZoom lena.bmp lena.sh2.bmp
 	
done
