global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV


section .data
	
	m_R: dd 1.0, 112.0, -38.0, 66.0
	
	m_G: dd 0.0, -94.0, -74.0, 129.0
	
	m_B: dd 0.0, -18.0, 112.0, 25.0
	
	aux1: dd 0.0, 128.0, 128.0, 128.0
		
	aux2: dd 1.0, 256.0, 256.0, 256.0
	
	aux3: dd 0, 128, 128, 16
	
	s_16: dd 0.0, 16.0, 16.0, 16.0
	
	s_128a: dd 0.0, 128.0, 128.0, 0
	
	s_128b: dd 0.0, 0.0, 128.0, 128.0
	
	m_Y: dd 1.0, 298.0, 298.0, 298.0
	
	m_U: dd 0.0, 516.0, -100.0, 0.0
	
	m_V: dd 0.0, 0.0, -208.0, 409.0
		
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
	
	pxor xmm0, xmm0
	
	movups xmm9, [aux2]
	movups xmm8, [aux1]
	
	movups xmm10, [s_16]
	movups xmm11, [s_128a]
	movups xmm12, [s_128b]
	
	movups xmm13, [m_Y]
	movups xmm14, [m_U]
	movups xmm15, [m_V]
	

.ciclo:
	movd xmm1, [rdi]
	
	punpcklbw xmm1, xmm0				;xmm1 = | 0 | 0 | 0 | 0 | ext0 Y | ext0 U | ext0 V | ext0 A |
	punpcklwd xmm1, xmm0				;xmm1 = | ext Y | ext U | ext V | ext A |
		
	cvtdq2ps xmm1, xmm1                 ;xmm1 = conversion a float
	
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  U  |  U  |  U  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  V  |  V  |  V  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  Y  |  Y  |  Y  |  A  |
	
	subps xmm1, xmm10					;xmm1 = | Y-16 | Y-16 | Y-16 |  A  |
	subps xmm2, xmm11					;xmm2 = |   U  | U-16 | U-16 |  A  |
	subps xmm3, xmm12					;xmm3 = | V-128| V-128|   V  |  A  |
	
	mulps xmm1, xmm13					;xmm1 = |298*(Y-16) | 298*(Y-16) | 298*(Y-16)|   A   |
	mulps xmm2, xmm14					;xmm2 = |     0     |-100*(U-128)|516*(U-128)|   0   |
	mulps xmm3, xmm15					;xmm3 = |409*(V-128)|-208*(V-128)|     0     |   0   |
	
	
	addps xmm1, xmm2
	addps xmm1, xmm3
	
	addps xmm1, xmm8

	divps xmm1, xmm9					;xmm1 = |  >> 8  |  >> 8  |  >> 8  |   A   |
	
	cvtps2dq xmm1, xmm1
	
	packusdw xmm1, xmm0					
	packuswb xmm1, xmm0
	
	movd [rsi], xmm1
	
	add rdi, 4
	add rsi, 4
	
	loop .ciclo
	
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
	
	pxor xmm0, xmm0
	
	movups xmm13, [m_R]
	movups xmm14, [m_G]
	movups xmm15, [m_B]
	
	movups xmm12, [aux1]
	movups xmm11, [aux2]
	movups xmm10, [aux3]
	
.ciclo:
	movd xmm1, [rdi]
	
	punpcklbw xmm1, xmm0				;xmm1 = | 0 | 0 | 0 | 0 | ext0 R | ext0 G | ext0 B | ext0 A |
	punpcklwd xmm1, xmm0				;xmm1 = | ext R | ext G | ext B | ext A |
	
	cvtdq2ps xmm1, xmm1                 ;xmm1 = conversion a float
	
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  G  |  G  |  G  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  B  |  B  |  B  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  R  |  R  |  R  |  A  |
	
	mulps xmm1, xmm13					;xmm1 = | 66*R | -38*R | 112*R |  A  |
	mulps xmm2, xmm14					;xmm2 = | 129*G | -74*G | -94*G |  0 |
	mulps xmm3, xmm15					;xmm3 = | 25*B | 112*B | -18*B |  0  |
	
	addps xmm1, xmm2					;xmm1 = | R + G | R + G | R + G |  A  |
	addps xmm1, xmm3					;xmm1 = |  R+G+B | R+G+B | R+G+B |  A  |  
	
	addps xmm1, xmm12					;xmm1 = | ++128 |  ++128 | ++128 | A |
	divps xmm1, xmm11					;xmm1 = | >> 8| >> 8| >> 8 | >> 8|
	

	cvtps2dq xmm1, xmm1
	paddd xmm1, xmm10
	
	packusdw xmm1, xmm0					;xmm1 = | 0 | 0 | 0 | 0 | Y | U | V | A | 
	packuswb xmm1, xmm0
	
	;paddb xmm1, xmm10
	
	movd [rsi], xmm1
	
	add rdi, 4
	add rsi, 4
	
	
	
	loop .ciclo
	 
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
 
