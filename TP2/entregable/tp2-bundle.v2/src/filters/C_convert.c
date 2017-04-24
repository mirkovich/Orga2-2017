/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion convertRGBtoYUV y convertYUVtoRGB          */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>


void C_convertRGBtoYUV(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
		
		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst;
		
		int i,j;
		
		for(i = 0; i < srcw; i++)
		{
			for(j = 0; j < srch; j++)
			{
				RGBA* p_s = (RGBA*) &src_matriz[i][4*j];
				YUVA* p_d = (YUVA*) &dst_matriz[i][4*j];
				
				p_d->y = ((66*p_s->r + 129*p_s->g + 25*p_s->b + 128) >> 8) + 16; 
				p_d->u = (((-38)*p_s->r - 74*p_s->g + 112*p_s->b + 128) >> 8) + 128; 
				p_d->v = ((112*p_s->r - 94*p_s->g - 18*p_s->b + 128) >> 8) + 128; 
				p_d->a = p_s->a;
			}
		}
		 
}

void C_convertYUVtoRGB(uint8_t* src, uint32_t srcw, uint32_t srch,
                       uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused))) {
		uint8_t (*src_matriz)[srcw * 4] = (uint8_t (*)[srcw * 4])src; 
		uint8_t (*dst_matriz)[dstw * 4] = (uint8_t (*)[dstw * 4])dst;
		
		int i,j;
		
		for(i = 0; i < srcw; i++)
		{
			for(j = 0; j < srch; j++)
			{
				YUVA* p_s = (YUVA*) &src_matriz[i][4*j];
				RGBA* p_d = (RGBA*) &dst_matriz[i][4*j];
				
				p_d->r = ((298*(p_s->y - 16) + 409*(p_s->v - 128) + 128) >> 8); 
				p_d->g = ((298*(p_s->y - 16) - 100*(p_s->u - 128) - 208*(p_s->v - 128) +128) >> 8); 
				p_d->b = ((298*(p_s->y - 16) + 516*(p_s->u -128) + 128) >> 8); 
				p_d->a = p_s->a;
			}
		}
}
