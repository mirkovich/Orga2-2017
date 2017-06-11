/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>
void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch, uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {

		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst; 


		int f,c ;
		int i,j;
		int max_r, max_g, max_b, max_a;	
		int max_r_new, max_g_new, max_b_new, max_a_new;
		// vamos a hacer el centro luego vemos el caso de los bordes
	for ( f = 0; f < srcw; f++) 
		{
			for ( c = 0; c < srch; c++) 
				{
					RGBA* p_src = (RGBA*) &src_matriz[f][c*4];
					RGBA* p_dst = (RGBA*) &dst_matriz[f][c*4];

				if(f == 0 || f == 1 ||f == 2 ||c == 0 ||c == 1 || c == 2 || c == srch-1|| c == srch-2 || c == srch-3 || f == srcw-1 || f == srcw-2 || f == srcw-3){
					p_dst->a =	255; 
					p_dst->r =	255;		
					p_dst->g =	255;	
					p_dst->b =	255;
					
				}else {	
						max_r = 0;
						max_g = 0; 
						max_b = 0; 
						max_a = 0;
						// cuando estoy parado en un pixel veo los 7 pixeles que están a su alrededor
						for (i = -3; i < 4; i++)
						{
							for( j = -3 ; j < 4; j++)
							{

								RGBA* p00_src =	(RGBA*) &src_matriz[f + i][(c + j)*4];						
								 max_a_new = p00_src->a;
								 max_r_new = p00_src->r;
								 max_g_new = p00_src->g;
								 max_b_new = p00_src->b;

								
								if ( max_a < max_a_new){
									max_a = max_a_new;
								}
								if ( max_r < max_r_new){
									max_r = max_r_new;
								} 	

								if ( max_g < max_g_new){
									max_g = max_g_new;
								} 	
								if ( max_b < max_b_new){
									max_b = max_b_new;
								}
							}  
						}
					//printf("%i\n", max_g);

					// tengo los maximos..	
					p_dst->a =	((p_src->a * (1.0- val)) + (max_a * val)); 
					p_dst->r =	((p_src->r * (1.0- val)) + (max_r * val));
					p_dst->g =	((p_src->g * (1.0- val)) + (max_g * val));	
					p_dst->b =	((p_src->b * (1.0- val)) + (max_b * val));	
					
					}
				}

		}

}

