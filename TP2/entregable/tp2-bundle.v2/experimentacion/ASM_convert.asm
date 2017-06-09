global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV


section .data
	
	m_128: dd 0, 128, 128, 128
	
	;usables para rgb2yuv

	m_Y: dd 0, 25, 129, 66
	
	m_U: dd 0, 112, -74, -38
	
	m_V: dd 0, -18, -94, 112

	aux_1: dd 0, 128, 128, 16
	
	;usables para yuv2rgb
	
	m_R: dd 0, 409, 0, 298
	
	m_G: dd 0, -208, -100, 298
	
	m_B: dd 0, 0, 516, 298
	
	s_1: dd 0, 128, 0, 16 

	s_2: dd 0, 128, 128, 16

	s_3: dd 0, 0, 128, 16

section .text


ASM_convertYUVtoRGB:			;RDI = src, ESI = srcw, EDX = srch
								;RCX = dst, R8d = dstw, R9d = dsth
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	
	xor rax, rax
	mov rbx, rsi
	mov r12, rdx
	mov r13, r8
	mov r14, r9
	
	mov rsi, rcx
	mov eax, r8d
	mul r9d
	
	mov ecx, eax
	shr ecx, 1
	pxor xmm0, xmm0
	
	movups xmm9, [m_128]

	movups xmm10, [m_R]
	movups xmm11, [m_G]
	movups xmm12, [m_B]

	movups xmm13, [s_1]
	movups xmm14, [s_2]
	movups xmm15, [s_3]

.ciclo:					; funciona igual al anterior, solo que este no reacomoda los colores para hacer las operaciones en 
	cmp ecx, 0			; de forma vertical. Hace las operaciones anteriores de forma horizontal, literalmente como se ve
	je .fin 			; en el enunciado. Como es esta version me salto la parte de reacomodar (usar pshufd)
						; deberia ser un poco mas optima
	movq xmm1, [rdi]
	
	punpcklbw xmm1, xmm0				;xmm1 = | 0 | 0 | 0 | 0 | ext0 Y | ext0 U | ext0 V | ext0 A |
	
	movups xmm4, xmm1
	
	punpckhwd xmm4, xmm0
	punpcklwd xmm1, xmm0				;xmm1 = | ext Y | ext U | ext V | ext A |
		
	movups xmm2, xmm1 					;xmm2 = xmm1
	movups xmm3, xmm1 					;xmm3 = xmm1 

	movups xmm5, xmm4
	movups xmm6, xmm4

	psubd xmm1, xmm15
	psubd xmm2, xmm14
	psubd xmm3, xmm13

	psubd xmm4, xmm15
	psubd xmm5, xmm14
 	psubd xmm6, xmm13

	pmulld xmm1, xmm12
	pmulld xmm2, xmm11
	pmulld xmm3, xmm10

	pmulld xmm4, xmm12
	pmulld xmm5, xmm11
	pmulld xmm6, xmm10 

	phaddd xmm1, xmm0
	pslldq xmm1, 8
	phaddd xmm2, xmm3
	phaddd xmm1, xmm2

	phaddd xmm4, xmm0
	pslldq xmm4, 8
	phaddd xmm5, xmm6
	phaddd xmm4, xmm5


	paddd xmm1, xmm9
	paddd xmm4, xmm9

	psrad xmm1, 8	
	psrad xmm4, 8

	packssdw xmm1, xmm4					
	packuswb xmm1, xmm0
	
	movq [rsi], xmm1
	
	add rdi, 8
	add rsi, 8
	
	dec ecx
	jmp .ciclo
.fin:	
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret


ASM_convertRGBtoYUV:				;RDI = src, ESI = srcw, EDX = srch
									;RCX = dst, R8d = dstw, R9d = dsth
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	
	xor rax, rax
	mov rbx, rsi
	mov r12, rdx
	mov r13, r8
	mov r14, r9
	
	mov rsi, rcx
	mov eax, r8d
	mul r9d
	
	mov ecx, eax
	shr ecx, 1
	pxor xmm0, xmm0

	movups xmm12, [m_128] 	
 	movups xmm11, [aux_1]

	movups xmm13, [m_Y]
	movups xmm14, [m_U]
	movups xmm15, [m_V]
	
.ciclo:
	cmp ecx, 0
	je .fin

	movq xmm1, [rdi]
	
	punpcklbw xmm1, xmm0				;xmm1 = | extR1 | extG1 | extB1 | extA1 | extR0 | extG0 | extB0 | extA0 |
	
	movups xmm5, xmm1
	
	punpcklwd xmm1, xmm0				;xmm1 = | ext R | ext G | ext B | ext A |
	punpckhwd xmm5, xmm0

	movups xmm2, xmm1					;xmm2 = xmm1
	movups xmm3, xmm1					;xmm3 = xmm1

	movups xmm6, xmm5
    movups xmm7, xmm5
	
	pmulld xmm3, xmm13					;xmm1 = | 66*R  | 129*G |  25*B |  0  |
	pmulld xmm2, xmm14					;xmm2 =	|-38*R  | -74*G | 112*B |  0  |
	pmulld xmm1, xmm15 					;xmm3 = |112*R  | -94*G | -18*B |  0  |
	
	pmulld xmm7, xmm13
	pmulld xmm6, xmm14
	pmulld xmm5, xmm15

	phaddd xmm2, xmm3					;xmm2 = | R3+G3 |   B3  | R2+G2 | B2  |
	phaddd xmm1, xmm0					;xmm1 = |   0   |   0   | R1+G1 | B1  |
	pslldq xmm1, 8						;xmm1 = | R1+G1 |   B1  |   0   |  0  |
	phaddd xmm1, xmm2					;xmm1 = |R3+G3+B3|R2+G2+B2|R1+G1+B1|   0  |

	phaddd xmm6, xmm7
	phaddd xmm5, xmm0
	pslldq xmm5, 8
	phaddd xmm5, xmm6

	paddd xmm1, xmm12					;xmm1 = | + 128 | + 128 | + 128 |  0  |	
	paddd xmm5, xmm12

	psrad xmm1, 8						;xmm1 = | >> 8  | >> 8  | >> 8  |  0  |
	psrad xmm5, 8

	paddd xmm1, xmm11					;xmm1 = | + 16  | + 128 | + 128 |  0  |
	paddd xmm5, xmm11

	packssdw xmm1, xmm5					;xmm1 = | 0 | 0 | 0 | 0 | Y | U | V | A | 
	packuswb xmm1, xmm0
	
	;paddb xmm1, xmm10
	
	movq [rsi], xmm1
	
	add rdi, 8
	add rsi, 8
	
	dec ecx
	
	jmp .ciclo
.fin:	 
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
 
