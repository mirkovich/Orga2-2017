global ASM_linearZoom
extern C_linearZoom

ASM_linearZoom:			;RDI = src, ESI = srcw, EDX = srch
						;RCX = dst, R8d = dstw, R9d = dsth
	push rbp
	mov rbp, rsp
	sub rsp, 24
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	xor rax, rax
	mov rbx, rsi 
	mov r12, rdx
	mov r13, r8
	mov r14, r9
	
	mov rsi, rcx
	mov rax, rbx
	dec rax 
	mov r10, r12
	dec r10
	mul r10
	mov rcx, rax
	
	mov rdx, rsi


	lea rsi, [rsi + 4*r13]
	mov r8, rdi
	mov r9, rsi
	


	mov r11, r13
	shr r11, 1
	
	xor r15, r15	
	pxor xmm0, xmm0
			
.ciclo:							;avanza por fila tomando los cuadrantes de pixeles		
	cmp rcx, 0					;al mismo tiempo se fija si llega a la ultima columna 
	je .fin 					;con respecto al anterior deberia haber alguna mejora

	movq xmm2, [rdi]					;xmm1 = |   0   | D | C |
	movq xmm1, [rdi + 4*rbx] 			;xmm2 = |   0   | B | A | 
	
	;movemos cada pixel a un registro distinto 
	pshufd xmm3, xmm1, 0xa8				;xmm3 = |  0  |  0  |  0  |  A  | 
	pshufd xmm4, xmm1, 0xa9				;xmm4 = |  0  |  0  |  0  |  B  |
	
	pshufd xmm5, xmm2, 0xa8				;xmm5 = |  0  |  0  |  0  |  C  |
	pshufd xmm6, xmm2, 0xa9				;xmm6 = |  0  |  0  |  0  |  D  |
									
	punpcklbw xmm3, xmm0				;desempaquetamos los colores de cada pixel a word	
	punpcklbw xmm4, xmm0
	punpcklbw xmm5, xmm0
	punpcklbw xmm6, xmm0
	
	movups xmm7, xmm3					;xmm7 = xmm3
	movups xmm8, xmm5					;xmm8 = xmm5
	
	movups xmm9, xmm3					;xmm9 = xmm3
	movups xmm10, xmm4					;xmm10 = xmm4
	; realizamos las operaciones para obtenes los pixeles interpolados												
	paddusw xmm7, xmm4					;xmm7 = | 0 | 0 | 0 | A + B |
	paddusw xmm8, xmm6					;xmm8 = | 0 | 0 | 0 | C + D |
	
	paddusw xmm9, xmm5					;xmm9 = | 0 | 0 | 0 | A + C |
	paddusw xmm10, xmm6					;xmm10 = | 0 | 0 | 0 | B + D |
	
	psraw xmm7, 1						;xmm7 = | 0 | 0 | 0 | (A + B)/2 |
	psraw xmm8, 1						;xmm8 = | 0 | 0 | 0 | (C + D)/2 |
	
	psraw xmm9, 1						;xmm9 = | 0 | 0 | 0 | (A + C)/2 |
	psraw xmm10, 1						;xmm10 = | 0 | 0 | 0 | (B + D)/2 |
	
	paddusw xmm3, xmm4					;xmm3 = | 0 | 0 | 0 | A + B |
	paddusw xmm3, xmm5					;xmm3 = | 0 | 0 | 0 | A + B + C |
	paddusw xmm3, xmm6					;xmm3 = | 0 | 0 | 0 | A + B + C + D |
		
	psraw xmm3, 2						;;xmm3 = | 0 | 0 | 0 | (A + B + C + D)/4 |
	; empaquetamos de vuelta a byte
	packuswb xmm7, xmm0
	packuswb xmm8, xmm0
	packuswb xmm9, xmm0
	packuswb xmm10, xmm0
	packuswb xmm3, xmm0
	
	;usamos extractps para mandar algunos pixeles a cada columna con los offsets calculados antes de ciclo
	extractps [rsi], xmm2, 0x00
	extractps [rsi + 8], xmm2, 0x01 
	extractps [rsi + 8*r13], xmm1, 0x00
	extractps [rsi + 8*r13 + 8], xmm1, 0x01
	
	;aca tambien se puede usar extractps
		
	movd [rsi + 4], xmm8
	movd [rsi + 4*r13], xmm9
	movd [rsi + 8*r13 + 4], xmm7
	movd [rsi + 4*r13 + 4], xmm3
	movd [rsi + 4*r13 + 8], xmm10
	
	inc r15	
	add rdi, 4
	add rsi, 8

	cmp r15, r10							; nos fijamos si llegamos a la ultima columna
	jl .seguir
	xor r15, r15							
											; y copiamos el pixel anterior de 3 filas
	movd xmm15, [rsi] 					
	movd xmm14, [rsi + 4*r13]
	movd xmm13, [rsi + 8*r13]

	movd [rsi + 4], xmm15 
	movd [rsi + 4*r13 + 4], xmm14 
	movd [rsi + 8*r13  + 4], xmm13 

	lea rdi, [r8 + 4*rbx]
	lea rsi, [r9 + 8*r13]
	mov r8, rdi
	mov r9, rsi

.seguir	
	dec rcx
.cont:	
	jmp .ciclo
.fin:
	mov rsi, rdx
.ult_fila:						; al final recorremos la ultima fila, que resulto ser la primera
	cmp r11, 0
	je .exit
	movq xmm15, [rsi + 4*r13]	;copiamos cada 2 pixeles
	movq [rsi], xmm15
	dec r11
	add rsi, 8
	jmp .ult_fila
.exit:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	add rsp, 24
	pop rbp
	ret
