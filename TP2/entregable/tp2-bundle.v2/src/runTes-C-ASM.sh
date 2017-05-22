#!/bin/bash
 
cantDeIteracion=200


for ((i=0 ; i< cantDeIteracion; i++)) 
do 
	./tp2 c $1 $2 $3
	./tp2 asm $1 $2 $3
done
