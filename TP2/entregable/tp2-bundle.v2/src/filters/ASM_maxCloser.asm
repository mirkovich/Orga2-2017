global ASM_maxCloser

extern C_maxCloser
section .data
;seccion para constantes si las voy a usar
const_unos: db 	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
float_unos: dd 1.0, 1.0, 1.0, 1.0
section .text
; Parámetros:
; 	rdi = src
; 	esi = srcw
; 	edx = srch
; 	rcx = dst
; 	r8d = dstw
; 	r9d = dsth
;   xmm0 = val

ASM_maxCloser:
push rbp
mov rbp, rsp
push r12
push r13
push r14
push rbx
	mov r10, rdi	;matriz fuente
	mov r11, rcx	;matriz destino
	sub esi, 6
	sub edx, 6
	pshufd xmm0 , xmm0, 00x0  ; xmm0  = |val|val|val|val|
	movdqu xmm11, [float_unos]	;xmm11	=	|1.0|1.0|1.0|1.0|
	subps xmm11, xmm0	;	xmm11 =		|1.0-val|1.0-val|1.0-val|1.0-val|
	movdqu xmm8, [const_unos]
	pxor xmm7, xmm7 
ciclo_filas:
ciclo_columnas:
	; xmm0, xmm1 y xmm2 van a guardar las tres filas de la matriz que contienen los pixeles
		movdqu xmm1, [rdi]		;xmm1 = | pixel(1,4) | pixel(1,3) | pixel(1,2) | pixel(1,1) |	fila1
		movdqu xmm2, [rdi+esi*4]	;xmm2 = | pixel(2,4) | pixel(2,3) | pixel(2,2) | pixel(2,1) |		fila 2
		movdqu xmm3, [rdi+esi*8]	;xmm3 = | pixel(3,4) | pixel(3,3) | pixel(3,2) | pixel(3,1) |		fila 3
		;********+bloque 1: compara las componentes de fila 1 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm1
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(1,2)(a,r,g,b) | Pixel((1,1)(a,r,g,b)|
		;pslldq xmm1, 4			;	
		psrldq xmm1, 8			;xmm1 = | *** | *** | Pixel(1,4)(a,r,g,b) | Pixel(1,3)(a,r,g,b) |
		punpcklbw xmm1, xmm7	;xmm1 = | Pixel(1,4)(a,r,g,b) |	Pixel(1,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm1		;xmm5 = el resultado de la comparacion (máscara de la comparacion)
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm1, xmm5			;xmm1 y xmm4 el resultado de las componentes mayores de pixeles(1,j) con j -> (1,2,3 y 4)
		por	xmm1, xmm4			;xmm1 = | max_componentes(1,j->(2,4))(a,r,g,b) | max_componentes(1,j->(1,3))(a,r,g,b) |
		;********+bloque 2: compara las componentes de fila 2 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm2		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(2,2)(a,r,g,b) | Pixel((2,1)(a,r,g,b)|
		;pslldq xmm2, 4			;	
		psrldq xmm2, 8			;xmm2 = | *** | *** | Pixel(2,4)(a,r,g,b) | Pixel(2,3)(a,r,g,b) |
		punpcklbw xmm2, xmm7	;xmm2 = | Pixel(2,4)(a,r,g,b) | Pixel(2,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion xmm4, xmm2
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(2,j) con j -> (1,2,3 y 4)
		por	xmm2, xmm4			;xmm2 = | max_componentes(2,j->(2,4))(a,r,g,b) | max_componentes(2,j->(1,3))(a,r,g,b) |
		;*********ahora comparo ambos bloques y me quedo con los maximos de 1 a 4 y 8 a 11*********
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1,2) y j->(1,2,3 y 4)
		por xmm1, xmm2			;xmm1=| max_componentes(i->(1,2),j->(2,4))(a,r,g,b) | max_componentes(i->(1,2),j->(1,3))(a,r,g,b) |
		;********+bloque 3: compara las componentes de fila 3 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm3		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(3,2)(a,r,g,b) | Pixel((3,1)(a,r,g,b)|
		;pslldq xmm3, 4			;	
		psrldq xmm3, 8			;xmm3 = 
		punpcklbw xmm3, xmm7	;xmm3 = | Pixel(3,4)(a,r,g,b) | Pixel(3,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de las componentes mayores de pixeles(3,j) con j -> (1,2,3 y 4)
		por xmm3, xmm4			;xmm3 = | max_componentes(3,j->(2,4))(a,r,g,b) | max_componentes(3,j->(1,3))(a,r,g,b) |
		
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1..3) y j->(1..4)
		por xmm1, xmm3			;xmm1 =|max_componentes(i->(1,2,3),j->(2,4))(a,r,g,b) | max_componentes(i->(1,2,3),j->(1,3))(a,r,g,b) |
		;sigo con la fila 4 y 5
		movdqu xmm2, [rdi+esi*16]	;xmm2 = | pixel(4,4) | pixel(4,3) | pixel(4,2) | pixel(4,1) |		fila 4
		movdqu xmm3, [rdi+esi*32]	;xmm3 = | pixel(5,4) | pixel(5,3) | pixel(5,2) | pixel(5,1) |		fila 5
		movdqu xmm6, xmm2		;guardo la fila 4 (el pixel en xmm6)
		;********+bloque 4: compara las componentes de fila 4 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm2		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(4,2)(a,r,g,b) | Pixel((4,1)(a,r,g,b)|
		;pslldq xmm2, 4			;	
		psrldq xmm2, 8			;xmm2 = | *** | *** | Pixel(4,4)(a,r,g,b) | Pixel(4,3)(a,r,g,b) |
		punpcklbw xmm2, xmm7	;xmm2 = | Pixel(4,4)(a,r,g,b) | Pixel(4,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion xmm4, xmm2
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(4,j) con j -> (1..4)
		por	xmm2, xmm4			;xmm2 = | max_componentes(4,j->(2,4))(a,r,g,b) | max_componentes(4,j->(1,3))(a,r,g,b) |
		;*********ahora comparo ambos bloques y me quedo con los maximos de i->(1..4) j->(1..4))*********
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1..4) y j->(1,2,3 y 4)
		por xmm1, xmm2			;xmm1=| max_componentes(i->(1..4),j->(2,4))(a,r,g,b) | max_componentes(i->(1..4),j->(1,3))(a,r,g,b) |
		;********+bloque 5: compara las componentes de fila 5 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm3		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(5,2)(a,r,g,b) | Pixel((5,1)(a,r,g,b)|
		;pslldq xmm3, 4			;	
		psrldq xmm3, 8			;xmm3 = 
		punpcklbw xmm3, xmm7	;xmm3 = | Pixel(5,4)(a,r,g,b) | Pixel(5,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de las componentes mayores de pixeles(5,j) con j -> (1,2,3 y 4)
		por xmm3, xmm4			;xmm3 = | max_componentes(5,j->(2,4))(a,r,g,b) | max_componentes(5,j->(1,3))(a,r,g,b) |
		
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1..3) y j->(1..4)
		por xmm1, xmm3			;xmm1 =|max_componentes(i->(1..5),j->(2,4))(a,r,g,b) | max_componentes(i->(1,2,3),j->(1,3))(a,r,g,b) |
		
		;sigo con la fila 6 y 7
		movdqu xmm2, [rdi+esi*64]	;xmm2 = | pixel(6,4) | pixel(6,3) | pixel(6,2) | pixel(6,1) |		fila 6
		movdqu xmm3, [rdi+esi*128]	;xmm3 = | pixel(7,4) | pixel(7,3) | pixel(7,2) | pixel(7,1) |		fila 7
		;********+bloque 6: compara las componentes de fila 4 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm2		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(6,2)(a,r,g,b) | Pixel((6,1)(a,r,g,b)|
		;pslldq xmm2, 4			;	
		psrldq xmm2, 8			;xmm2 = | *** | *** | Pixel(6,4)(a,r,g,b) | Pixel(6,3)(a,r,g,b) |
		punpcklbw xmm2, xmm7	;xmm2 = | Pixel(6,4)(a,r,g,b) | Pixel(6,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion xmm4, xmm2
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(6,j) con j -> (1..4)
		por	xmm2, xmm4			;xmm2 = | max_componentes(6,j->(2,4))(a,r,g,b) | max_componentes(6,j->(1,3))(a,r,g,b) |
		;*********ahora comparo ambos bloques y me quedo con los maximos de i->(1..6) j->(1..4))*********
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm2, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1..6) y j->(1,2,3 y 4)
		por xmm1, xmm2			;xmm1=| max_componentes(i->(1..6),j->(2,4))(a,r,g,b) | max_componentes(i->(1..6),j->(1,3))(a,r,g,b) |
		;********+bloque 7: compara las componentes de fila 7 columnas j->(1-4)	*****************		
		movdqu xmm4, xmm3		;
		punpcklbw xmm4, xmm7	;xmm4 = |Pixel(7,2)(a,r,g,b) | Pixel((7,1)(a,r,g,b)|
		;pslldq xmm3, 4			;	
		psrldq xmm3, 8			;xmm3 = 
		punpcklbw xmm3, xmm7	;xmm3 = | Pixel(7,4)(a,r,g,b) | Pixel(7,3)(a,r,g,b) |
		movdqu xmm5, xmm4
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de las componentes mayores de pixeles(7,j) con j -> (1..4)
		por xmm3, xmm4			;xmm3 = | max_componentes(7,j->(2,4))(a,r,g,b) | max_componentes(7,j->(1,3))(a,r,g,b) |
		
		movdqu xmm5, xmm1
		pcmpgtw xmm5, xmm3		; xmm5 = el resultado de la comparacion
		pand xmm1, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm3, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1..7) y j->(1..4)
		por xmm1, xmm3			;xmm1 =|max_componentes(i->(1..7),j->(2,4))(a,r,g,b) | max_componentes(i->(1..7),j->(1,3))(a,r,g,b) |
	
		;falta las comparaciones de filas del 1 al 7 y columnas 5 a 7
fin:
pop rbx
pop r14
pop r13
pop r12
pop rbp
ret
