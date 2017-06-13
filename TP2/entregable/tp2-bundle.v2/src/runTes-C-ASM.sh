#!/bin/bash
 
for ((i=0 ; i< $4; i++)) 
do 
	./tp2 asm $1 $2 $3 
done

for ((i=0 ; i< $4; i++)) 
do 
	./tp2 c $1 $2 $3

done 
	

