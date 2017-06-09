/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

uint8_t maxR(RGBA** src, int i, int j, int f, int c);
uint8_t maxG(RGBA** src, int i, int j, int f, int c);
uint8_t maxB(RGBA** src, int i, int j, int f, int c);


void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch, uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {

		RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
		RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;


		int f,c ;
		int max_r, max_g, max_b;
	//	int max_r, max_g, max_b, max_a;	
//		int max_r_new, max_g_new, max_b_new, max_a_new;
		// vamos a hacer el centro luego vemos el caso de los bordes
		for ( f = 0; f < srch; f++) 
		{
			for ( c = 0; c < srcw; c++) 
			{
					RGBA* p_src = &matrix_src[f][c];
					RGBA* p_dst = &matrix_dst[f][c];

				if((c < 3 || c > srcw-4) || (f < 3 || f > srch-4)) {
					p_dst->a =	p_src->a; 
					p_dst->r =	255;		
					p_dst->g =	255;	
					p_dst->b =	255;
					
				}
				else {	
					
					max_r = maxR(src,f-3,c-3,f+3,c+3);
					max_g = maxG(src,f-3,c-3,f+3,c+3);	
					max_b = maxB(src,f-3,c-3,f+3,c+3);	

					// tengo los maximos..	
					p_dst->a =	p_src->a; 
					p_dst->r =	((p_src->r * (1 - val)) + (max_r * val));
					p_dst->g =	((p_src->g * (1 - val)) + (max_g * val));	
					p_dst->b =	((p_src->b * (1 - val)) + (max_b * val));	
					
				}
			}

		}

}

uint8_t maxR(RGBA** src, int i, int j, int f, int c)
{
	uint8_t max = 0;
	if(f-i == 0 && c-j == 0)
	{
		return (&src[i][j])->r;
	}
	else
	{ 	
		uint8_t m_a;
		uint8_t m_b;

		RGBA* p_A;
		RGBA* p_B;
		if(c-j == 1 && f-i == 0)
		{
			p_A = &src[i][j];
			p_B = &src[i][j+1];

			m_a = p_A->r;
			m_b = p_B->r;
		}
		else if(c-j == 0 && f-i == 1)
		{
			p_A = &src[i][j];
			p_B = &src[i+1][j];

			m_a = p_A->r;
			m_b = p_B->r;
		}
		if(m_a >m_b)
		{
			return m_a;
		}
		
		return m_b;
	}

	int a = (i+f)/2; 
	int b = (j+c)/2;

	uint8_t m1 = maxR(src,i,j,a,b);
	uint8_t m2 = maxR(src,i,b+1,a,c);
	uint8_t m3 = maxR(src,a+1,j,f,b);
	uint8_t m4 = maxR(src,a+1,b+1,f,c);

	max = m1;
	if(m2 > max)
	{
		max = m2; 
	}
	if(m3 > max)
	{
		max = m3;
	}
	if(m4 > max)
	{
		max = m4;
	} 


	return max;
	
}

uint8_t maxG(RGBA** src, int i, int j, int f, int c)
{
	uint8_t max = 0;
	if(f-i == 0 && c-j == 0)
	{
		return (&src[i][j])->g;
	}
	else
	{ 	
		uint8_t m_a;
		uint8_t m_b;

		RGBA* p_A;
		RGBA* p_B;
		if(c-j == 1 && f-i == 0)
		{
			p_A = &src[i][j];
			p_B = &src[i][j+1];

			m_a = p_A->g;
			m_b = p_B->g;
		}
		else if(c-j == 0 && f-i == 1)
		{
			p_A = &src[i][j];
			p_B = &src[i+1][j];

			m_a = p_A->g;
			m_b = p_B->g;
		}
		if(m_a >m_b)
		{
			return m_a;
		}
		
		return m_b;
	}

	int a = (i+f)/2; 
	int b = (j+c)/2;

	uint8_t m1 = maxR(src,i,j,a,b);
	uint8_t m2 = maxR(src,i,b+1,a,c);
	uint8_t m3 = maxR(src,a+1,j,f,b);
	uint8_t m4 = maxR(src,a+1,b+1,f,c);

	max = m1;
	if(m2 > max)
	{
		max = m2; 
	}
	if(m3 > max)
	{
		max = m3;
	}
	if(m4 > max)
	{
		max = m4;
	} 


	return max;
	
}

uint8_t maxB(RGBA** src, int i, int j, int f, int c)
{
	uint8_t max = 0;
	if(f-i == 0 && c-j == 0)
	{
		return (&src[i][j])->b;
	}
	else
	{ 	
		uint8_t m_a;
		uint8_t m_b;

		RGBA* p_A;
		RGBA* p_B;
		if(c-j == 1 && f-i == 0)
		{
			p_A = &src[i][j];
			p_B = &src[i][j+1];

			m_a = p_A->b;
			m_b = p_B->b;
		}
		else if(c-j == 0 && f-i == 1)
		{
			p_A = &src[i][j];
			p_B = &src[i+1][j];

			m_a = p_A->b;
			m_b = p_B->b;
		}
		if(m_a >m_b)
		{
			return m_a;
		}
		
		return m_b;
	}

	int a = (i+f)/2; 
	int b = (j+c)/2;

	uint8_t m1 = maxR(src,i,j,a,b);
	uint8_t m2 = maxR(src,i,b+1,a,c);
	uint8_t m3 = maxR(src,a+1,j,f,b);
	uint8_t m4 = maxR(src,a+1,b+1,f,c);

	max = m1;
	if(m2 > max)
	{
		max = m2; 
	}
	if(m3 > max)
	{
		max = m3;
	}
	if(m4 > max)
	{
		max = m4;
	} 


	return max;
	
}
