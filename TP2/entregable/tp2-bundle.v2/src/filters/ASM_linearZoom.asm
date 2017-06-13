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
	
.ciclo:
	cmp rcx, 0
	je .fin
	
	movq xmm2, [rdi]					;xmm2 = | 0 | 0 | D | C |
	movq xmm1, [rdi + 4*rbx] 			;xmm1 = | 0 | 0 | B | A | 
	
	movups xmm3, xmm1 					;xmm3 = xmm1
	movups xmm4, xmm2					;xmm4 = xmm2

	punpcklbw xmm3, xmm0				;xmm3 = |   B   |   A   |
	punpcklbw xmm4, xmm0 	 			;xmm4 = |   D   | 	C 	|

	movups xmm5, xmm3 					;xmm5 = xmm3
	movups xmm6, xmm3 					;xmm6 = xmm3
	movups xmm7, xmm4 					;xmm7 = xmm4

	shufpd xmm5, xmm4, 0x03  			;xmm5 = |   D   |   B   |
	shufpd xmm6, xmm7, 0x00				;xmm6 = |   C   |   A   | 
	
	paddusw xmm5, xmm3					;xmm5 = | B + D | A + B |
	paddusw xmm6, xmm4					;xmm6 = | C + D | A + C |
	
	movups xmm3, xmm5 					;xmm3 = | B + D | A + B |
	movups xmm4, xmm6       			;xmm4 = | C + D | A + C |
	psrldq xmm4, 8						;xmm4 = |   ?   | C + D |
	paddusw xmm3, xmm4 					;xmm3 = |   ?   |A+B+C+D|

	psraw xmm5, 1						;xmm5 = | (B + D)/2 | (A + B)/2 |
	psraw xmm6, 1						;xmm6 = | (C + D)/2 | (A + C)/2 |
	psraw xmm3, 2						;xmm3 = |     ?     |(A+B+C+D)/4|
	
	
	packuswb xmm5, xmm6					;xmm5 = |(C + D)/2|(A + C)/2|(B + D)/2|(A + B)/2|
	packuswb xmm3, xmm0
	
	
	extractps [rsi], xmm2, 0x00					;dst = | C  | ..  | ..  
	extractps [rsi + 8], xmm2, 0x01 			;dst = | C  | ..  |  D
	extractps [rsi + 8*r13], xmm1, 0x00 		;dst = | A  | ..  |  ..	
	extractps [rsi + 8*r13 + 8], xmm1, 0x01     ;dst = | A  | ..  |  B 
	
	extractps [rsi + 4], xmm5, 0x03 			;dst = |  C  |"(C+D)/2"|  D  |
	extractps [rsi + 4*r13], xmm5, 0x02			;dst = |"(C+A)/2"| ... | ... |
	extractps [rsi + 8*r13 + 4], xmm5, 0x00 	;dst = | A   |"(A+B)/2"|  B  |
	extractps [rsi + 4*r13 + 4], xmm3, 0x00		;dst = | (C+A)/2 |"(A+B+C+D)/4"| ... |
	extractps [rsi + 4*r13 + 8], xmm5, 0x01		;dst = | (C+A)/2 | (A+B+C+D)/4 | (B+D)/2 |	
	
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
.ult_fila:
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
