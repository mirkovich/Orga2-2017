/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion fourCombine                                */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_fourCombine(uint8_t* src, uint32_t srcw, uint32_t srch,
                   uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
		
		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst; 
		
		int i,j;			   
		
		for(i = 0; i < srcw/2 ; i++)
		{
			for(j = 0; j < srch/2 ; j++)
			{
				RGBA* p11_src = (RGBA*) &src_matriz[2*i][2*(j*4)];
				RGBA* p21_src = (RGBA*) &src_matriz[2*i + 1][2*(j*4)];
				RGBA* p12_src = (RGBA*) &src_matriz[2*i][2*((j+1)*4)];
				RGBA* p22_src = (RGBA*) &src_matriz[2*i +1][2*((j+1)*4)];
					
				
				RGBA* p11 = (RGBA*) &dst_matriz[i][4*j];
				RGBA* p21 = (RGBA*) &dst_matriz[i + dsth/2][4*j];
				RGBA* p12 = (RGBA*) &dst_matriz[i][4*(j + dstw/2)];
				RGBA* p22 = (RGBA*) &dst_matriz[i + dsth/2][4*(j + dstw/2)];
				
				p11->a = p11_src->a;
				p11->r = p11_src->r;
				p11->g = p11_src->g;
				p11->b = p11_src->b;
				
				p21->a = p21_src->a;
				p21->r = p21_src->r;
				p21->g = p21_src->g;
				p21->b = p21_src->b;
				
				p12->a = p12_src->a;
				p12->r = p12_src->r;
				p12->g = p12_src->g;
				p12->b = p12_src->b;
				
				p22->a = p22_src->a;
				p22->r = p22_src->r;
				p22->g = p22_src->g;
				p22->b = p22_src->b;
			}
		}
}

                    
                    
                    
                    

                    
                    
                    
                    
