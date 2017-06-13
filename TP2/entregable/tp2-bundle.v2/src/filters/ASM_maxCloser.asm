global ASM_maxCloser

extern C_maxCloser
section .data
;seccion para constantes si las voy a usar
const_unos: db 	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
float_unos: dd 1.0, 1.0, 1.0, 1.0	;
filtro_A:   db 0x00,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff,	0xff,0xff,0xff,0xff ;
filtro_A2:   db 0xff,0x00,0x00,0x00,	0x00,0x00,0x00,0x00,	0x00,0x00,0x00,0x00,	0x00,0x00,0x00,0x00 ;
section .text

;/////////////***********ejemplo gráfico de procesamiento******************//////////////////
;La siguiente grilla muestra un ejemplo de qué pixeles se debe tomar en cuenta si se quiere procesar
;en este caso el pixel(4,4) pero es análogo a cualquier posición válida de la imagen
;si voy a querer procesar el pixel(4,4), voy a necesitar de sus vecinos que forman el siguiente kernel:
;| pixel(7,1) | pixel(7,2) | pixel(7,3) | pixel(7,4) | pixel(7,5) | pixel(7,6) | pixel(7,7) |
;| pixel(6,1) | pixel(6,2) | pixel(6,3) | pixel(6,4) | pixel(6,5) | pixel(6,6) | pixel(6,7) |
;| pixel(5,1) | pixel(5,2) | pixel(5,3) | pixel(5,4) | pixel(5,5) | pixel(5,6) | pixel(5,7) |
;| pixel(4,1) | pixel(4,2) | pixel(4,3) | pixel(4,4) | pixel(4,5) | pixel(4,6) | pixel(4,7) |
;| pixel(3,1) | pixel(3,2) | pixel(3,3) | pixel(3,4) | pixel(3,5) | pixel(3,6) | pixel(3,7) |
;| pixel(2,1) | pixel(2,2) | pixel(2,3) | pixel(2,4) | pixel(2,5) | pixel(2,6) | pixel(2,7) |
;| pixel(1,1) | pixel(1,2) | pixel(1,3) | pixel(1,4) | pixel(1,5) | pixel(1,6) | pixel(1,7) |
;///////////////************************************************************//////////////////

; Parámetros:
;rdi = src, esi = srcw, edx = srch
;rcx = dst, r8d = dstw, r9d = dsth
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
	mov rax, rcx	;momentaneamente uso rax para recorrer las tres primeras filas
	lea rcx, [r9d * 3]	;cant de pixels en una fila * 3 filas
	shr rcx, 2			;divido entre 4 ya que voy a procesar de a 4 pixeles a la vez las tres primeras filas
	jmp pintar_borde_inferior
volver_de_pintar_inferior:
	xor rax, rax
	mov eax, edx
	shl rax, 2	;rax = cantidad de bytes por fila
	add r11, rax
	add r11, rax
	add r11, rax	;r11 = comienzo de direccion destino apartir de la cuarta fila
	sub esi, 6		;le resto 6 a la cant de filas y columnas (por los bordes en blanco)
	sub edx, 6
	pxor xmm7, xmm7
	mov r12, 0			;r12 iterador de las filas procesadas
	jmp .comienza_aqui
.ciclo_filas:
	add r10, rax	;avanzo a la sgte fila de matriz fuente
	add r11, rax	;avanzo a la sgte fila de matriz destino
	movdqu [rcx], xmm8	;pongo en blanco el borde derecho
	;movdqu [r11], xmm8	;pongo en blanco el borde derecho
.comienza_aqui:
	inc r12
	cmp r12d, esi
	jg .pintar_borde_superior
	mov rbx, 0		;pongo en cero el iterdor de columnas
	mov rdi, r10
	mov rcx, r11
	movdqu [rcx], xmm8	;pongo en blanco el borde izquierdo
	add rcx, 12
	
	.ciclo_columnas:
		pxor xmm1, xmm1		;xmm1 es el acumulador del resultado
		;****************proceso la fila 1 del kernel*******************************
		movdqu xmm2, [rdi]		;xmm2 = | pixel(1,4) | pixel(1,3) | pixel(1,2) | pixel(1,1) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(1;j->(2,4))(r,g,b,a) | max_componentes(1,j->(1,3))(r,g,b,a) |
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(1,7) | pixel(1,6) | pixel(1,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(1,7) | pixel(1,6) | pixel(1,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(1;j->(2,4,6))(r,g,b,a) | max_componentes(1,j->(1,3,5,7))(r,g,b,a) |
		;****************proceso la fila 2 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(2,4) | pixel(2,3) | pixel(2,2) | pixel(2,1) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(2,7) | pixel(2,6) | pixel(2,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(2,7) | pixel(2,6) | pixel(2,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1,2];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1,2];j->[1,3,5,7])(r,g,b,a) |
		;****************proceso la fila 3 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(3,4) | pixel(3,3) | pixel(3,2) | pixel(3,1) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(3,7) | pixel(3,6) | pixel(3,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(3,7) | pixel(3,6) | pixel(3,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1,2,3];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1,2,3];j->[1,3,5,7])(r,g,b,a) |
		;****************proceso la fila 4 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(4,4) | pixel(4,3) | pixel(4,2) | pixel(4,1) |
		movdqu xmm6, xmm2		;guardo la fila 4 en xmm6, me interesa el pixel(4,4) que es el pixel a procesar en img destino
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(4,7) | pixel(4,6) | pixel(4,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(4,7) | pixel(4,6) | pixel(4,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1,2,3,4];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1,2,3,4];j->[1,3,5,7])(r,g,b,a) |
		;****************proceso la fila 5 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(5,4) | pixel(5,3) | pixel(5,2) | pixel(5,1) |
		;***************************************************************************
		call traer_maximos
		;*************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(5,7) | pixel(5,6) | pixel(5,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(5,7) | pixel(5,6) | pixel(5,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1..5];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1..5];j->[1,3,5,7])(r,g,b,a) |
		;****************proceso la fila 6 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(6,4) | pixel(6,3) | pixel(6,2) | pixel(6,1) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(6,7) | pixel(6,6) | pixel(6,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(6,7) | pixel(6,6) | pixel(6,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1..6];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1..6];j->[1,3,5,7])(r,g,b,a) |
		;****************proceso la fila 7 del kernel*******************************
		add rdi, rax	;avanzo una fila
		movdqu xmm2, [rdi]	;xmm2 = | pixel(7,4) | pixel(7,3) | pixel(7,2) | pixel(7,1) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		movdqu xmm2, [rdi+16]		;xmm2 = | ???? | pixel(7,7) | pixel(7,6) | pixel(7,5) |
		pslldq xmm2, 4			;	
		psrldq xmm2, 4			;xmm2 = | 0000 | pixel(7,7) | pixel(7,6) | pixel(7,5) |
		;************************************************************************************
		call traer_maximos
		;************************************************************************************
		;xmm1 = | max_componentes(i->[1..7];j->[2,4,6])(r,g,b,a) | max_componentes(i->[1..7];j->[1,3,5,7])(r,g,b,a) |
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
		;xmm1 = | max_componentes(i->(1..7);j->(1..7))(r,g,b,a) | cada componente en dword
		psrldq xmm6, 12
		punpcklbw xmm6, xmm7 	;xmm6 = |0000|0000|0r0g|0b0a|
		punpcklwd xmm6, xmm7 	;xmm6 = |000r|000g|000b|000a|
		
		cvtdq2ps xmm6, xmm6 	; xmm6 = | float(pixel_comp_r) | float(pixel_comp_g) | float(pixel_comp_b) | float(pixel_comp_a) |
		mulps xmm6, xmm11		; xmm6 = | float(comp_r) * (1-val)| float(comp_g) * (1-val)| float(comp_b) * (1-val)| float(comp_a) * (1-val) |
		cvtdq2ps xmm1, xmm1
		mulps xmm1, xmm0
		addps xmm1, xmm6
		cvtps2dq xmm1, xmm1 	; xmm1 = | r | g | b | a |
		packusdw xmm1, xmm7 	; xmm1 = |0000| 0000| 0r0g| 0b0a |
		packuswb xmm1, xmm7		; xmm1 = |0000|0000|0000|rgba|
		pand  xmm1, xmm9
		;paddb xmm1, xmm3
		movd [rcx], xmm1
		
		add rcx, 4
		inc rbx	;incremento el iterados de columnas
		cmp ebx, edx
		jge .ciclo_filas
		lea rdi, [r10 + rbx * 4]
		jmp .ciclo_columnas

.pintar_borde_superior:
	lea rcx, [r8d * 3]	;cant de pixels en una fila * 3 filas
	shr rcx, 2			;divido entre 4 ya que voy a procesar de a 4 pixeles a la vez
	.ciclo_superior:
		movdqu [r11], xmm8
		add r11, 16
		loop .ciclo_superior
.fin:
pop rbx
pop r14
pop r13
pop r12
pop rbp
ret

traer_maximos:
	;en xmm2 hay 4 pixeles a los que llamaremos PixelD, PixelC, PixelB y Pixel A  en ese orden
	movdqu xmm4, xmm2		;xmm2 = |PixelD(r,g,b,a) | PixelC(r,g,b,a) |PixelB(r,g,b,a) | PixelA(r,g,b,a)|
	punpcklbw xmm4, xmm7	;xmm4 = |PixelB(r,g,b,a) | PixelA(r,g,b,a)|
	psrldq xmm2, 8			;xmm2 = | *** | *** | PixelD(r,g,b,a) | PixelC(r,g,b,a) |
	punpcklbw xmm2, xmm7	;xmm2 = | PixelD(r,g,b,a) | PixelC(r,g,b,a) |
	movdqu xmm5, xmm4
	pcmpgtw xmm5, xmm2		;xmm5 = el resultado de la comparacion xmm4, xmm2
	pand xmm4, xmm5
	pxor xmm5, xmm8			;invierto los bits del resultado
	pand xmm2, xmm5			;xmm2 y xmm4 el resultado de las componentes mayores de pixeles(A..D)
	por	xmm2, xmm4			;xmm2 = |max_componentesBD(r,g,b,a) | max_componentesAC(r,g,b,a)|
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
	movdqu [rax], xmm8
	add rax, 16
	loop .ciclo_inferior
jmp volver_de_pintar_inferior
