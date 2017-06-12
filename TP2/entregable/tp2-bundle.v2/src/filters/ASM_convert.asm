global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV


section .data
	
	m_R: dd 1, 112, -38, 66
	
	m_G: dd 0, -94, -74, 129
	
	m_B: dd 0, -18, 112, 25
	
	aux1: dd 0, 128, 128, 128
		
	aux2: dd 1, 256, 256, 256
	
	aux3: dd 0, 128, 128, 16
	
	s_16: dd 0, 16, 16, 16
	
	s_128a: dd 0, 128, 128, 0
	
	s_128b: dd 0, 0, 128, 128
	
	m_Y: dd 1, 298, 298, 298
	
	m_U: dd 0, 516, -100, 0
	
	m_V: dd 0, 0, -208, 409
	
	s_255: dd 0, 255, 255, 255 

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
		
	
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  U  |  U  |  U  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  V  |  V  |  V  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  Y  |  Y  |  Y  |  A  |
	
	psubd xmm1, xmm10					;xmm1 = | Y-16 | Y-16 | Y-16 |  A  |
	psubd xmm2, xmm11					;xmm2 = |   U  | U-128| U-128|  A  |
	psubd xmm3, xmm12					;xmm3 = | V-128| V-128|   V  |  A  |
	
	pmulld xmm1, xmm13					;xmm1 = |298*(Y-16) | 298*(Y-16) | 298*(Y-16)|   A   |
	pmulld xmm2, xmm14					;xmm2 = |     0     |-100*(U-128)|516*(U-128)|   0   |
	pmulld xmm3, xmm15					;xmm3 = |409*(V-128)|-208*(V-128)|     0     |   0   |
	
	
	paddd xmm1, xmm2
	paddd xmm1, xmm3
	
	paddd xmm1, xmm8

	psrad xmm1, 8

	packssdw xmm1, xmm0					
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
	
	
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  G  |  G  |  G  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  B  |  B  |  B  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  R  |  R  |  R  |  A  |
	
	pmulld xmm1, xmm13					;xmm1 = | 66*R | -38*R | 112*R |  A  |
	pmulld xmm2, xmm14					;xmm2 = | 129*G | -74*G | -94*G |  0 |
	pmulld xmm3, xmm15					;xmm3 = | 25*B | 112*B | -18*B |  0  |
	
	paddd xmm1, xmm2					;xmm1 = | R + G | R + G | R + G |  A  |
	paddd xmm1, xmm3					;xmm1 = |  R+G+B | R+G+B | R+G+B |  A  |  
	
	paddd xmm1, xmm12					;xmm1 = | ++128 |  ++128 | ++128 | A |

	psrad xmm1, 8

	paddd xmm1, xmm10
	
	packssdw xmm1, xmm0					;xmm1 = | 0 | 0 | 0 | 0 | Y | U | V | A | 
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
 
