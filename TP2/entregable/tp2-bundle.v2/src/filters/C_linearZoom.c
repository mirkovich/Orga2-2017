/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>




uint8_t saturation(uint8_t num1, uint8_t num2){
	if(num1 < num2){
		 return num1;
		}
	return num2; 
	}

double timeval_diff(struct timeval *a, struct timeval *b)
{
  return
    (double)(a->tv_sec + (double)a->tv_usec/1000000) -
    (double)(b->tv_sec + (double)b->tv_usec/1000000);
}





void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
		
		// clock_t start = clock();		PARA MEDIDA EN MILISEGUNDOS
		// double secs;					PARA MEDIDDA EN MILISEGUNDOS
		
		struct timeval t_ini, t_fin;
  		double secs;

 	 	gettimeofday(&t_ini, NULL);

		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst; 
		
		int i,j;					   

// completo los pixeles que no tienen que ser interpolados		
		for(i = 0; i < srcw ; i++)
		{
			for(j = 0; j < srch  ; j++)
			{	
					RGBA* p_src = (RGBA*) &src_matriz[i][j*4];
					RGBA* p_dst = (RGBA*) &dst_matriz[2*i][(j*4)*2];

					p_dst->r =	p_src->r;		
					p_dst->g =	p_src->g;	
					p_dst->b =	p_src->b;

			}

		}
					
short val_b, val_g, val_r;
 //ahora calculamos los pixeles a interpolar
		
		for(i=0; i< srcw * 2 ;i++)
		{
			for(j=0; j< srch * 2 ;j++)
			{
					// si la fila es par y la columna impar ---- INTERPOLACIÓN HORIZONTAL

				val_b = 0;
				val_g = 0;  
				val_r = 0;
						
					if ((i%2 == 0) && (j%2 == 1))
						{
						 RGBA* p_dst_atras = (RGBA*) &dst_matriz[i][(j-1)*4];
						 RGBA* p_dst_adelante = (RGBA*) &dst_matriz[i][(j+1)*4];
						 RGBA* p_dst = (RGBA*) &dst_matriz[i][j*4];
						 
						 val_b = (short)(p_dst_atras->b) + (short)(p_dst_adelante->b);
						 val_b = val_b/2;
						 
						 val_g = (short)(p_dst_atras->g) + (short)(p_dst_adelante->g);
						 val_g = val_g/2;
						  
						 val_r = (short)(p_dst_atras->r) + (short)(p_dst_adelante->r);
						 val_r = val_r/2;
						 
						 p_dst->b = saturation((uint8_t)val_b, 255);
						 p_dst->g = saturation((uint8_t)val_g, 255);
						 p_dst->r = saturation((uint8_t)val_r, 255); 
						}else{
							// si la fila es impar y la columna es par
								if((i%2 == 1) && (j%2 == 0)){
										 RGBA* p_dst_abajo = (RGBA*) &dst_matriz[i-1][j*4];
										 RGBA* p_dst_arriba = (RGBA*) &dst_matriz[i+1][j*4];
										 RGBA* p_dst = (RGBA*) &dst_matriz[i][j*4];
										 
										 val_b = (short)(p_dst_abajo->b) + (short)(p_dst_arriba->b);
										 val_b = val_b/2;
										 
										 val_g = (short)(p_dst_abajo->g) + (short)(p_dst_arriba->g);
										 val_g = val_g/2;
										  
										 val_r = (short)(p_dst_abajo->r) + (short)(p_dst_arriba->r);
										 val_r = val_r/2;
										 
										 p_dst->b = saturation((uint8_t)val_b, 255);
										 p_dst->g = saturation((uint8_t)val_g, 255);
										 p_dst->r = saturation((uint8_t)val_r, 255); 
																					
										} else {
											// caso que estemos en una columna impar y fila impar
											if((i%2 == 1) && (j % 2 == 1)){
												 RGBA* p_dst_arriba_izq = (RGBA*) &dst_matriz[i+1][(j-1)*4];
												 RGBA* p_dst_arriba_der = (RGBA*) &dst_matriz[i+1][(j+1)*4];
												 RGBA* p_dst_abajo_izq = (RGBA*) &dst_matriz[i-1][(j-1)*4];
												 RGBA* p_dst_abajo_der = (RGBA*) &dst_matriz[i-1][(j+1)*4];
												 
												 RGBA* p_dst = (RGBA*) &dst_matriz[i][j*4];
												 
												 val_b = (short)(p_dst_arriba_izq->b) + (short)(p_dst_arriba_der->b) + (short)(p_dst_abajo_izq->b) + (short)(p_dst_abajo_der->b) ;
												 val_b = val_b/4;
												 
												 val_g = (short)(p_dst_arriba_izq->g) + (short)(p_dst_arriba_der->g) + (short)(p_dst_abajo_izq->g) + (short)(p_dst_abajo_der->g) ;
												 val_g = val_g/4;
												  
												 val_r = (short)(p_dst_arriba_izq->r) + (short)(p_dst_arriba_der->r) + (short)(p_dst_abajo_izq->r) + (short)(p_dst_abajo_der->r) ;
												 val_r = val_r/4;
												 
												 p_dst->b = saturation((uint8_t)val_b, 255);
												 p_dst->g = saturation((uint8_t)val_g, 255);
												 p_dst->r = saturation((uint8_t)val_r, 255); 
												}								
										} 
							
							
							
							} 
							
				
				
								
				}


		}

  gettimeofday(&t_fin, NULL);

  secs = timeval_diff(&t_fin, &t_ini);
  printf("%.16g milliseconds\n", secs * 1000.0);				//MEDIDA EN MICRO SEGUNDOS 
	
	/* tenemos el tiempo en milisegundos*/	
	//clock_t end = clock();									PARA MEDIDA EN MILISEGUNDOS
	//secs = (double)(end - start) / CLOCKS_PER_SEC;			PARA MEDIDA EN MILISEGUNDOS
	//printf("%.16g milisegundos\n", secs * 1000.0);			PARA MEDIDA EN MILISEGUNDOS
	//printf("El Tiempo es: %d\n",(end - start));
}
