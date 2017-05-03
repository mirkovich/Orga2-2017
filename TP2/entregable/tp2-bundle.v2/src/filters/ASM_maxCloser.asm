global ASM_maxCloser

extern C_maxCloser
section .data
;seccion para constantes si las voy a usar
const_unos: db 	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
float_unos: dd 1.0, 1.0, 1.0, 1.0
filtro_A:       db 0  , 0  , 0  , 255 , 0  , 0  , 0  , 0, 0, 0, 0, 0, 0, 0, 0, 0
section .text
; Parámetros:
; 	rdi = src
; 	esi = srcw
; 	edx = srch
; 	rcx = dst
; 	r8d = dstw
; 	r9d = dsth
;   xmm0 = val

;si voy a querer procesar el pixel(4,4), voy a necesitar de sus vecinos que forman el siguiente kernel
;| pixel(7,1) | pixel(7,2) | pixel(7,3) | pixel(7,4) | pixel(7,5) | pixel(7,6) | pixel(7,7) |
;| pixel(6,1) | pixel(6,2) | pixel(6,3) | pixel(6,4) | pixel(6,5) | pixel(6,6) | pixel(6,7) |
;| pixel(5,1) | pixel(5,2) | pixel(5,3) | pixel(5,4) | pixel(5,5) | pixel(5,6) | pixel(5,7) |
;| pixel(4,1) | pixel(4,2) | pixel(4,3) | pixel(4,4) | pixel(4,5) | pixel(4,6) | pixel(4,7) |
;| pixel(3,1) | pixel(3,2) | pixel(3,3) | pixel(3,4) | pixel(3,5) | pixel(3,6) | pixel(3,7) |
;| pixel(2,1) | pixel(2,2) | pixel(2,3) | pixel(2,4) | pixel(2,5) | pixel(2,6) | pixel(2,7) |
;| pixel(1,1) | pixel(1,2) | pixel(1,3) | pixel(1,4) | pixel(1,5) | pixel(1,6) | pixel(1,7) |

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
	movdqu xmm9, [filtro_A]
	pxor xmm7, xmm7
	pxor xmm1, xmm1
ciclo_filas:
ciclo_columnas:
		movdqu xmm2, [rdi]		;xmm2 = | pixel(1,4) | pixel(1,3) | pixel(1,2) | pixel(1,1) |	fila1
		call traer_maximos
		;xmm1 = | max_componentes(1;j->(2,4))(a,r,g,b) | max_componentes(1,j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*4]	;xmm2 = | pixel(2,4) | pixel(2,3) | pixel(2,2) | pixel(2,1) |		fila 2
		call traer_maximos
		;xmm1 = | max_componentes(i->(1,2);j->(2,4))(a,r,g,b) | max_componentes(i->(1,2);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*8]	;xmm2 = | pixel(3,4) | pixel(3,3) | pixel(3,2) | pixel(3,1) |		fila 3
		call traer_maximos
		;xmm1 = | max_componentes(i->(1,2,3);j->(2,4))(a,r,g,b) | max_componentes(i->(1,2,3);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*16]	;xmm2 = | pixel(4,4) | pixel(4,3) | pixel(4,2) | pixel(4,1) |		fila 4
		movdqu xmm6, xmm2		;guardo la fila 4 (el pixel en xmm6)
		call traer_maximos
		;xmm1 = | max_componentes(i->(1..4);j->(2,4))(a,r,g,b) | max_componentes(i->(1..4);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*32]	;xmm2 = | pixel(5,4) | pixel(5,3) | pixel(5,2) | pixel(5,1) |		fila 5
		call traer_maximos
		;xmm1 = | max_componentes(i->(1..5);j->(2,4))(a,r,g,b) | max_componentes(i->(1..5);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*64]	;xmm2 = | pixel(6,4) | pixel(6,3) | pixel(6,2) | pixel(6,1) |		fila 6
		call traer_maximos
		;xmm1 = | max_componentes(i->(1..6);j->(2,4))(a,r,g,b) | max_componentes(i->(1..6);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi+esi*128]	;xmm2 = | pixel(7,4) | pixel(7,3) | pixel(7,2) | pixel(7,1) |		fila 7
		call traer_maximos
		;xmm1 = | max_componentes(i->(1..7);j->(2,4))(a,r,g,b) | max_componentes(i->(1..7);j->(1,3))(a,r,g,b) |
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(1,7) | pixel(1,6) | pixel(1,5) |	fila1
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(1,7) | pixel(1,6) | pixel(1,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(2,7) | pixel(2,6) | pixel(2,5) |	fila2
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(2,7) | pixel(2,6) | pixel(2,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(3,7) | pixel(3,6) | pixel(3,5) |	fila3
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(3,7) | pixel(3,6) | pixel(3,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(4,7) | pixel(4,6) | pixel(4,5) |	fila4
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(4,7) | pixel(4,6) | pixel(4,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(5,7) | pixel(5,6) | pixel(5,5) |	fila5
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(5,7) | pixel(5,6) | pixel(5,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(6,7) | pixel(6,6) | pixel(6,5) |	fila6
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(6,7) | pixel(6,6) | pixel(6,5) |
		call traer_maximos
		
		movdqu xmm2, [rdi]		;xmm2 = | ???? | pixel(7,7) | pixel(7,6) | pixel(7,5) |	fila7
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(7,7) | pixel(7,6) | pixel(7,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->(1..7);j->(2,4,6))(a,r,g,b) | max_componentes(i->(1..7);j->(1,3,5,7))(a,r,g,b) |
		movdqu xmm4, xmm1
		punpcklwd xmm4, xmm7
		psrldq xmm1, 8
		punpcklwd xmm1, xmm7
		movdqu xmm5, xmm4
		pcmpgtd xmm5, xmm1
		pand xmm4, xmm5
		pxor xmm5, xmm8			;invierto los bits del resultado
		pand xmm1, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(A..D)
		por	xmm1, xmm4
		;xmm1 = | max_componentes(i->(1..7);j->(1..7))(a,r,g,b) |
		psrldq xmm6, 12
		punpcklbw xmm6, xmm7 	;xmm6 = |0000|0000|0a0r|0g0b|
		punpcklwd xmm6, xmm7 	;xmm6 = |000a|000r|000g|000b|
		
		cvtdq2ps xmm6, xmm6 	; xmm6 = | float(pixel_comp_r) | float(pixel_comp_g) | float(pixel_comp_b) |
		mulps xmm6, xmm11
		cvtdq2ps xmm1, xmm1
		mulps xmm1, xmm0
		addps xmm1, xmm6
		cvtps2dq xmm1, xmm1 	; xmm1 = | r | g | b |
		packusdw xmm1, xmm7 	; xmm1 = |0000| 0000| 000r| 0g0b |
		packuswb xmm1, xmm7		; xmm1 = |0000|0000|0000|0rgb|
		paddb  xmm1, xmm9
		;movq rbx, xmm1
		movd [rsi], xmm1
fin:
pop rbx
pop r14
pop r13
pop r12
pop rbp
ret


traer_maximos:
	movdqu xmm4, xmm2		;xmm2 = |PixelD(a,r,g,b) | PixelC(a,r,g,b) |PixelB(a,r,g,b) | PixelA(a,r,g,b)|
	punpcklbw xmm4, xmm7	;xmm4 = |PixelB(a,r,g,b) | PixelA(a,r,g,b)|
	psrldq xmm2, 8			;xmm2 = | *** | *** | PixelD(a,r,g,b) | PixelC(a,r,g,b) |
	punpcklbw xmm2, xmm7	;xmm2 = | PixelD(a,r,g,b) | PixelC(a,r,g,b) |
	movdqu xmm5, xmm4
	pcmpgtw xmm5, xmm2		;xmm5 = el resultado de la comparacion xmm4, xmm2
	pand xmm4, xmm5
	pxor xmm5, xmm8			;invierto los bits del resultado
	pand xmm2, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(A..D)
	por	xmm2, xmm4			;xmm2 = |max_componentesBD(a,r,g,b) | max_componentesAC(a,r,g,b)|
	;xmm1 los máximos acumulados hasta este momento
	movdqu xmm5, xmm1
	pcmpgtw xmm5, xmm2		; xmm5 = el resultado de la comparacion
	pand xmm1, xmm5
	pxor xmm5, xmm8			;invierto los bits del resultado
	pand xmm2, xmm5			;el resultado de los componentes mayores de pixeles(i,j) con i->(1,2) y j->(1,2,3 y 4)
	por xmm1, xmm2
	ret
