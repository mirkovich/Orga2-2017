/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*   Implementacion de la funcion Zoom                                       */
/*                                                                           */
/* ************************************************************************* */

#include "filters.h"
#include <math.h>

int maxR(uint8_t* src, uint32_t srcw, int i, int j, int f, int c);
int maxG(uint8_t* src, uint32_t srcw, int i, int j, int f, int c);
int maxB(uint8_t* src, uint32_t srcw, int i, int j, int f, int c);

void C_maxCloser(uint8_t* src, uint32_t srcw, uint32_t srch, uint8_t* dst, uint32_t dstw, uint32_t dsth __attribute__((unused)), float val) {

		RGBA (*matrix_src)[srcw] = (RGBA (*)[srcw]) src;
		RGBA (*matrix_dst)[dstw] = (RGBA (*)[dstw]) dst;


		int f,c ;
		
		int max_r, max_g, max_b;	
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
					
					max_r = maxR(src,srcw,f-3,c-3,f+3,c+3);
					max_g = maxG(src,srcw,f-3,c-3,f+3,c+3);
					max_b = maxB(src,srcw,f-3,c-3,f+3,c+3);
				//	max_b = maxB(matrix_src,f-3,c-3,f+3,c+3);	

					// tengo los maximos..	
					p_dst->a =	p_src->a; 
					p_dst->r =	(p_src->r *(1.0 - val)) + (max_r * val);
					p_dst->g =	(p_src->g *(1.0 - val)) + (max_g * val);	
					p_dst->b =	(p_src->b *(1.0 - val)) + (max_b * val);		
					
					
				}
			}

		}

}

int maxR(uint8_t* src, uint32_t srcw, int i, int j, int f, int c)
{
	int max = 0;
	if(f-i <= 1 && c-j <= 1)
	{
		RGBA (*m_src)[srcw] = (RGBA (*)[srcw]) src;

		if(c-j == 0 && f-i == 0)
		{
			return (&m_src[i][j])->r;
		}
		if(c-j == 1 && f-i == 0)
		{ 	
			int m_a = (&m_src[i][j])->r;
			int m_b = (&m_src[i][j+1])->r;
		
			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
		if(c-j == 0 && f-i == 1)
		{
			int m_a = (&m_src[i][j])->r;
			int m_b = (&m_src[i+1][j])->r;

			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
	}
	
	


	int a = (i+f)/2; 
	int b = (j+c)/2;

	int m1 = maxR(src,srcw,i,j,a,b);
	int m2 = maxR(src,srcw,i,b+1,a,c);
	int m3 = maxR(src,srcw,a+1,j,f,b);
	int m4 = maxR(src,srcw,a+1,b+1,f,c);

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

int maxG(uint8_t* src, uint32_t srcw, int i, int j, int f, int c)
{
	int max = 0;
	if(f-i <= 1 && c-j <= 1)
	{
		RGBA (*m_src)[srcw] = (RGBA (*)[srcw]) src;

		if(c-j == 0 && f-i == 0)
		{
			return (&m_src[i][j])->g;
		}
		if(c-j == 1 && f-i == 0)
		{ 	
			int m_a = (&m_src[i][j])->g;
			int m_b = (&m_src[i][j+1])->g;
		
			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
		if(c-j == 0 && f-i == 1)
		{
			int m_a = (&m_src[i][j])->g;
			int m_b = (&m_src[i+1][j])->g;

			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
	}

	int a = (i+f)/2; 
	int b = (j+c)/2;

	int m1 = maxG(src,srcw,i,j,a,b);
	int m2 = maxG(src,srcw,i,b+1,a,c);
	int m3 = maxG(src,srcw,a+1,j,f,b);
	int m4 = maxG(src,srcw,a+1,b+1,f,c);

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

int maxB(uint8_t* src, uint32_t srcw, int i, int j, int f, int c)
{
	int max = 0;
	if(f-i <= 1 && c-j <= 1)
	{
		RGBA (*m_src)[srcw] = (RGBA (*)[srcw]) src;

		if(c-j == 0 && f-i == 0)
		{
			return (&m_src[i][j])->b;
		}
		if(c-j == 1 && f-i == 0)
		{ 	
			int m_a = (&m_src[i][j])->b;
			int m_b = (&m_src[i][j+1])->b;
		
			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
		if(c-j == 0 && f-i == 1)
		{
			int m_a = (&m_src[i][j])->b;
			int m_b = (&m_src[i+1][j])->b;

			if(m_a >m_b)
			{
				return m_a;
			}
		
			return m_b;
		}
	}

	int a = (i+f)/2; 
	int b = (j+c)/2;

	int m1 = maxB(src,srcw,i,j,a,b);
	int m2 = maxB(src,srcw,i,b+1,a,c);
	int m3 = maxB(src,srcw,a+1,j,f,b);
	int m4 = maxB(src,srcw,a+1,b+1,f,c);

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


