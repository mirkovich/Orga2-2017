#!/bin/bash
for n in $(seq 24 24 744)
do
	echo $n
		for ((i=0 ; i < $4; i++)) 
			do 
				./tp2 $1 $2 ../tests/data/imagenes_a_testear/lena.$n $3
			done
done

#~ for m in $(seq 24 24 1032)
#~ do
	#~ echo $m

		#~ for ((i=0 ; i < $3; i++)) 
			#~ do 
				#~ ./tp2 c $1 ../tests/data/imagenes_a_testear/lena.$m $2
			#~ done 
#~ done	

