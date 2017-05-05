/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

void C_linearZoom(uint8_t* src, uint32_t srcw, uint32_t srch,
                  uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
	
		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst; 
		
		int i,j;			   
		
		for(i = 0; i < srcw ; i++)
		{
			for(j = 0; j < srch ; j++)
			{
				if(i < srcw-1 || j < srch - 1)
				{
					RGBA* pA_src = (RGBA*) &src_matriz[i][j*4]; 
					RGBA* pB_src = (RGBA*) &src_matriz[i][(j+1)*4]; 
					RGBA* pC_src = (RGBA*) &src_matriz[i + 1][j*4];
					RGBA* pD_src = (RGBA*) &src_matriz[i + 1][(j+1)*4];
				
					RGBA* pA_dst = (RGBA*) &dst_matriz[2*i][2*(j*4)];
					RGBA* pAB_dst = (RGBA*) &dst_matriz[2*i][(2*j+1)*4];
					RGBA* pB_dst = (RGBA*) &dst_matriz[2*i][(2*j+2)*4];
					RGBA* pAC_dst = (RGBA*) &dst_matriz[2*i + 1][2*(j*4)];
					RGBA* pABCD_dst = (RGBA*) &dst_matriz[2*i + 1][(2*j+1)*4];
			//		RGBA* pBD_dst = (RGBA*) &dst_matriz[i][j*4];
					RGBA* pC_dst = (RGBA*) &dst_matriz[2*(i+1)][2*j*4];
			//		RGBA* pCD_dst = (RGBA*) &dst_matriz[i][j*4];
					RGBA* pD_dst = (RGBA*) &dst_matriz[2*(i+1)][(2*j+2)*4];
				
				
					pA_dst->a = pA_src->a; 
					pA_dst->r = pA_src->r; 
					pA_dst->g = pA_src->g; 
					pA_dst->b = pA_src->b; 
				
					pB_dst->a = pB_src->a; 
					pB_dst->r = pB_src->r; 
					pB_dst->g = pB_src->g; 
					pB_dst->b = pB_src->b; 
				
					pAB_dst->a = (pA_src->a + pB_src->a)/2; 
					pAB_dst->r = (pA_src->r + pB_src->r)/2; 
					pAB_dst->g = (pA_src->g + pB_src->g)/2; 
					pAB_dst->b = (pA_src->b + pB_src->b)/2; 
				
					pC_dst->a = pC_src->a; 
					pC_dst->r = pC_src->r; 
					pC_dst->g = pC_src->g; 
					pC_dst->b = pC_src->b;
				
					pAC_dst->a = (pA_src->a + pC_src->a)/2; 
					pAC_dst->r = (pA_src->r + pC_src->r)/2; 
					pAC_dst->g = (pA_src->g + pC_src->g)/2; 
					pAC_dst->b = (pA_src->b + pC_src->b)/2; 
				
					pD_dst->a = pD_src->a; 
					pD_dst->r = pD_src->r; 
					pD_dst->g = pD_src->g; 
					pD_dst->b = pD_src->b;
				
					pABCD_dst->a = (pA_src->a + pB_src->a + pC_src->a + pD_src->a)/4; 
					pABCD_dst->r = (pA_src->r + pB_src->r + pC_src->r + pD_src->r)/4; 
					pABCD_dst->g = (pA_src->g + pB_src->g + pC_src->g + pD_src->g)/4; 
					pABCD_dst->b = (pA_src->b + pB_src->b + pC_src->b + pD_src->b)/4; 
				}
			}
		}
}

