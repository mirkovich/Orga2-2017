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


uint8_t suma2(uint8_t pa, uint8_t pb);
uint8_t suma4(uint8_t pa, uint8_t pb, uint8_t pc, uint8_t pd);

void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
				

		
		RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
		RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;
	//	src[fila][col]
		uint32_t i,j;					   

// completo los pixeles que no tienen que ser interpolados		
		for(i = 0; i < srch ; i++)
		{
			for(j = 0; j < srcw ; j++)
			{
				if(i < srch-1 && j < srcw-1)
				{	
					RGBA* pA_src = &matrix_src[srch-1 - i][j]; 
					RGBA* pB_src = &matrix_src[srch-1 - i][j+1]; 
					RGBA* pC_src = &matrix_src[srch-1 - (i+1)][j];
					RGBA* pD_src = &matrix_src[srch-1 - (i+1)][j+1];
					
					
					RGBA* pA_dst = &matrix_dst[(dsth-1) - 2*i][2*j];
					RGBA* pAB_dst = &matrix_dst[(dsth-1) - 2*i][2*j + 1];
					RGBA* pB_dst = &matrix_dst[(dsth-1) - 2*i][2*j + 2];
					RGBA* pAC_dst = &matrix_dst[(dsth-1)- (2*i + 1)][2*j];
					RGBA* pABCD_dst = &matrix_dst[(dsth-1) - (2*i + 1)][2*j + 1];
					RGBA* pBD_dst = &matrix_dst[(dsth-1) -(2*i + 1)][2*j + 2];
					RGBA* pC_dst = &matrix_dst[(dsth-1) - (2*i + 2)][2*j];
					RGBA* pCD_dst = &matrix_dst[(dsth-1) - (2*i + 2)][2*j + 1];
					RGBA* pD_dst = &matrix_dst[(dsth-1)-(2*i + 2)][2*j + 2];
					
					pA_dst->a = pA_src->a; 
					pA_dst->r = pA_src->r; 
					pA_dst->g = pA_src->g; 
					pA_dst->b = pA_src->b; 
					
					pB_dst->a = pB_src->a; 
					pB_dst->r = pB_src->r; 
					pB_dst->g = pB_src->g; 
					pB_dst->b = pB_src->b;
				
					pC_dst->a = pC_src->a; 
					pC_dst->r = pC_src->r; 
					pC_dst->g = pC_src->g; 
					pC_dst->b = pC_src->b;	
						
					pD_dst->a = pD_src->a; 
					pD_dst->r = pD_src->r; 
					pD_dst->g = pD_src->g; 
					pD_dst->b = pD_src->b; 
		
					pAB_dst->a = suma2(pA_src->a, pB_src->a); 
					pAB_dst->r = suma2(pA_src->r, pB_src->r); 
					pAB_dst->g = suma2(pA_src->g, pB_src->g); 
					pAB_dst->b = suma2(pA_src->b, pB_src->b); 
			
					pCD_dst->a = suma2(pC_src->a, pD_src->a); 
					pCD_dst->r = suma2(pC_src->r, pD_src->r); 
					pCD_dst->g = suma2(pC_src->g, pD_src->g); 
					pCD_dst->b = suma2(pC_src->b, pD_src->b);

					pAC_dst->a = suma2(pA_src->a, pC_src->a); 
					pAC_dst->r = suma2(pA_src->r, pC_src->r); 
					pAC_dst->g = suma2(pA_src->g, pC_src->g); 
					pAC_dst->b = suma2(pA_src->b, pC_src->b);
				
					pBD_dst->a = suma2(pB_src->a, pD_src->a); 
					pBD_dst->r = suma2(pB_src->r, pD_src->r); 
					pBD_dst->g = suma2(pB_src->g, pD_src->g); 
					pBD_dst->b = suma2(pB_src->b, pD_src->b);
					
					pABCD_dst->a = suma4(pA_src->a, pB_src->a, pC_src->a, pD_src->a); 
					pABCD_dst->r = suma4(pA_src->r, pB_src->r, pC_src->r, pD_src->r); 
					pABCD_dst->g = suma4(pA_src->g, pB_src->g, pC_src->g, pD_src->g); 
					pABCD_dst->b = suma4(pA_src->b, pB_src->b, pC_src->b, pD_src->b);
			
				}
				
				else if(j == srcw-1)
				{
					RGBA* p1 = (RGBA*) &matrix_dst[(dsth-1)-2*i][dstw-1];
					RGBA* p2 = (RGBA*) &matrix_dst[(dsth-1)-(2*i+1)][dstw-1];
					
					RGBA* pd1 = (RGBA*) &matrix_dst[(dsth-1)-2*i][dstw-2];
					RGBA* pd2 = (RGBA*) &matrix_dst[(dsth-1)-(2*i+1)][dstw-2];
					
					p1->a = pd1->a;
					p1->g = pd1->g;
					p1->b = pd1->b;
					p1->r = pd1->r;
					
					p2->a = pd2->a;
					p2->g = pd2->g;
					p2->b = pd2->b;
					p2->r = pd2->r;
				}
				else if(i == srch-1)
				{
					RGBA* p1 = (RGBA*) &matrix_dst[0][2*j];
					RGBA* p2 = (RGBA*) &matrix_dst[0][2*j+1];
					RGBA* p3 = (RGBA*) &matrix_dst[0][2*j+2];
					
					RGBA* pd1 = (RGBA*) &matrix_dst[1][2*j];
					RGBA* pd2 = (RGBA*) &matrix_dst[1][2*j+1];
					RGBA* pd3 = (RGBA*) &matrix_dst[1][2*j+2];
					
					p1->a = pd1->a;
					p1->g = pd1->g;
					p1->b = pd1->b;
					p1->r = pd1->r;
					
					p2->a = pd2->a;
					p2->g = pd2->g;
					p2->b = pd2->b;
					p2->r = pd2->r;
					
					p3->a = pd3->a;
					p3->g = pd3->g;
					p3->b = pd3->b;
					p3->r = pd3->r;

				}			
			}

		}
}


uint8_t suma2(uint8_t pa, uint8_t pb)
{
	uint16_t a = pa;
	uint16_t b = pb;
	uint8_t res = (a + b)/2;
	
	return res;
}
uint8_t suma4(uint8_t pa, uint8_t pb, uint8_t pc, uint8_t pd)
{
	uint16_t a = pa;
	uint16_t b = pb;
	uint16_t c = pc;
	uint16_t d = pd;
	uint8_t res = (a + b + c + d)/4;
	
	return res;
}

