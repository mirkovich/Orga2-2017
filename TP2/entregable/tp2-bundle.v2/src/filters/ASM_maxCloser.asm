global ASM_maxCloser

extern C_maxCloser
section .data
;seccion para constantes si las voy a usar
const_unos: db 	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
float_unos: dd 1.0, 1.0, 1.0, 1.0
filtro_A:   db 0x00,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
filtro_A2:   db 0xff,0x00,0x00,0x00,	0x00,0x00,0x00,0x00,	0x00,0x00,0x00,0x00,	0x00,0x00,0x00,0x00 ;
section .text

;si voy a querer procesar el pixel(4,4), voy a necesitar de sus vecinos que forman el siguiente kernel
;| pixel(7,1) | pixel(7,2) | pixel(7,3) | pixel(7,4) | pixel(7,5) | pixel(7,6) | pixel(7,7) |
;| pixel(6,1) | pixel(6,2) | pixel(6,3) | pixel(6,4) | pixel(6,5) | pixel(6,6) | pixel(6,7) |
;| pixel(5,1) | pixel(5,2) | pixel(5,3) | pixel(5,4) | pixel(5,5) | pixel(5,6) | pixel(5,7) |
;| pixel(4,1) | pixel(4,2) | pixel(4,3) | pixel(4,4) | pixel(4,5) | pixel(4,6) | pixel(4,7) |
;| pixel(3,1) | pixel(3,2) | pixel(3,3) | pixel(3,4) | pixel(3,5) | pixel(3,6) | pixel(3,7) |
;| pixel(2,1) | pixel(2,2) | pixel(2,3) | pixel(2,4) | pixel(2,5) | pixel(2,6) | pixel(2,7) |
;| pixel(1,1) | pixel(1,2) | pixel(1,3) | pixel(1,4) | pixel(1,5) | pixel(1,6) | pixel(1,7) |

; Parámetros:
;RDI = src, ESI = srcw, EDX = srch
;RCX = dst, R8d = dstw, R9d = dsth
;xmm0 = val
ASM_maxCloser:
push rbp
mov rbp, rsp
push r12
push r13
push r14
push rbx
	pshufd xmm0 , xmm0, 0x00  ; xmm0  = |val|val|val|val|
	movdqu xmm11, [float_unos]	;xmm11	=	|1.0|1.0|1.0|1.0|
	subps xmm11, xmm0	;	xmm11 =		|1.0-val|1.0-val|1.0-val|1.0-val|
	movdqu xmm8, [const_unos]
	movdqu xmm9, [filtro_A]
	movdqu xmm3, [filtro_A2]
	mov r10, rdi	;matriz fuente
	mov r11, rcx	;matriz destino
	lea rcx, [r8d * 3]	;cant de pixels en una fila * 3 filas
	shr rcx, 2			;divido entre 4 ya que voy a procesar de a 4 pixeles a la vez
	call pintar_borde_inferior
	lea rax, [r8d * 4]	;cantidad de bytes por columna
	;add rcx, rax
	;lea rcx, [rcx+rax * 2 + 12]	;ubico comienzo en matriz destino
	lea r11, [r11 + 12]	;ubico comienzo en matriz destino
	
	sub esi, 6
	sub edx, 6
	
	pxor xmm7, xmm7
	pxor xmm1, xmm1
	mov r12, 0 
.ciclo_filas:
	inc r12
	cmp r12d, edx
	jg .fin
	mov rbx, 0		;pongo en cero el iterdor de columnas
	mov rdi, r10
	mov rcx, r11
	lea r10, [r10 + rax]
	lea r11, [r11 + rax]
.ciclo_columnas:
		pxor xmm1, xmm1
		;****************proceso la fila 1 del kernel*******************************
		movdqu xmm2, [rdi]		;xmm2 = | pixel(1,4) | pixel(1,3) | pixel(1,2) | pixel(1,1) |
		call traer_maximos
		;xmm1 = | max_componentes(1;j->(2,4))(b,g,r,a) | max_componentes(1,j->(1,3))(b,g,r,a) |
		movdqu xmm2, [rdi + 16]		;xmm2 = | ???? | pixel(1,7) | pixel(1,6) | pixel(1,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(1,7) | pixel(1,6) | pixel(1,5) |
		call traer_maximos
		;xmm1 = | max_componentes(1;j->(2,4,6))(b,g,r,a) | max_componentes(1,j->(1,3,5,7))(b,g,r,a) |
		;****************proceso la fila 2 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(2,4) | pixel(2,3) | pixel(2,2) | pixel(2,1) |
		call traer_maximos
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(2,7) | pixel(2,6) | pixel(2,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(2,7) | pixel(2,6) | pixel(2,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1,2];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1,2];j->[1,3,5,7])(b,g,r,a) |
		;****************proceso la fila 3 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(3,4) | pixel(3,3) | pixel(3,2) | pixel(3,1) |
		call traer_maximos
		movdqu xmm2, [rdi + 16]		;xmm2 = | ???? | pixel(3,7) | pixel(3,6) | pixel(3,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(3,7) | pixel(3,6) | pixel(3,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1,2,3];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1,2,3];j->[1,3,5,7])(b,g,r,a) |
		;****************proceso la fila 4 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(4,4) | pixel(4,3) | pixel(4,2) | pixel(4,1) |
		movdqu xmm6, xmm2		;guardo la fila 4 en xmm6, me interesa el pixel(4,4) para después
		call traer_maximos
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(4,7) | pixel(4,6) | pixel(4,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(4,7) | pixel(4,6) | pixel(4,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1,2,3,4];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1,2,3,4];j->[1,3,5,7])(b,g,r,a) |
		;****************proceso la fila 5 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(5,4) | pixel(5,3) | pixel(5,2) | pixel(5,1) |
		call traer_maximos
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(5,7) | pixel(5,6) | pixel(5,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(5,7) | pixel(5,6) | pixel(5,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1..5];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1..5];j->[1,3,5,7])(b,g,r,a) |
		;****************proceso la fila 6 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(6,4) | pixel(6,3) | pixel(6,2) | pixel(6,1) |
		call traer_maximos
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(6,7) | pixel(6,6) | pixel(6,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(6,7) | pixel(6,6) | pixel(6,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1..6];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1..6];j->[1,3,5,7])(b,g,r,a) |
		;****************proceso la fila 7 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(7,4) | pixel(7,3) | pixel(7,2) | pixel(7,1) |
		call traer_maximos
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(7,7) | pixel(7,6) | pixel(7,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(7,7) | pixel(7,6) | pixel(7,5) |
		call traer_maximos
		;xmm1 = | max_componentes(i->[1..7];j->[2,4,6])(b,g,r,a) | max_componentes(i->[1..7];j->[1,3,5,7])(b,g,r,a) |
		;****************comparo los maximos que están en xmm1*******************************
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
		pand  xmm1, xmm9
		paddb xmm1, xmm3
		movd [rcx], xmm1
		cmp ebx, esi
		jge .ciclo_filas
		inc rbx	;incremento el iterados de columnas
		lea rdi, [r10 + rbx * 4]
		lea rcx, [r11 + rbx * 4]
		jmp .ciclo_columnas
.fin:
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

pintar_borde_inferior:
.ciclo_inferior:
	movdqu [r11], xmm8
	add r11, 16
	loop .ciclo_inferior
ret
