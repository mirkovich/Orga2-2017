global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV


section .data
	
	aux1: dd 0, 128, 128, 128

	;valores a usar en yuv2rgb
	m_R: dd  1, 112, -38, 66
	
	m_G: dd  0, -94, -74, 129

	m_B: dd  0, -18, 112, 25
		
	aux2: dd 0, 128, 128, 16
	
	
	;valores a usar en yuv2rgb
	m_Y: dd 0, 298, 298, 298
	
	m_U: dd 0, 516, -100, 0 
	
	m_V: dd 0, 0, -208, 409 
	
	aux3: dd 0, 16, 16, 16
	
	aux4: dd 0, 128, 128, 0
	
	aux5: dd 0, 0, 128, 128

	aux_255: dd 0, 255, 255, 255 
	
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
	;shr rcx, 2
	pxor xmm0, xmm0								
	
	movups xmm7, [aux_255]
	movups xmm9, [aux1]
	movups xmm10, [aux3]
	movups xmm11, [aux4]
	movups xmm12, [aux5]
	
	movups xmm13, [m_Y]
	movups xmm14, [m_U]
	movups xmm15, [m_V]
								
.ciclo:
	cmp ecx, 0
	je .fin										  	
	
	
	movd xmm1, [rdi]
    
    punpcklbw xmm1, xmm0
    
    punpcklwd xmm1, xmm0
    
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  U  |  U  |  U  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  V  |  V  |  V  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  Y  |  Y  |  Y  |  A  |
    
    psubd xmm1, xmm10
    psubd xmm2, xmm11
    psubd xmm3, xmm12
    
    pmulld xmm1, xmm13
    pmulld xmm2, xmm14
    pmulld xmm3, xmm15
	
	paddd xmm1, xmm2
	paddd xmm1, xmm3
	
	paddd xmm1, xmm9
	
	psrad xmm1, 8
	
	movups xmm4, xmm1
	pcmpgtd xmm4, xmm0
	pand xmm1, xmm4

	
	packssdw xmm1, xmm0
	packuswb xmm1, xmm0
	
	movd [rsi], xmm1
    
    add rdi, 4
    add rsi, 4
    
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
	;shr rcx, 2
	pxor xmm0, xmm0								
	
	movups xmm11, [aux1]
	movups xmm12, [aux2]
	
	movups xmm13, [m_R]
	movups xmm14, [m_G]
	movups xmm15, [m_B]
								
.ciclo:
	cmp ecx, 0
	je .fin										  	
	
	
	movd xmm1, [rdi]
    
    punpcklbw xmm1, xmm0
    
    punpcklwd xmm1, xmm0
    
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  G  |  G  |  G  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  B  |  B  |  B  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  R  |  R  |  R  |  A  |
    
    pmulld xmm1, xmm13
    pmulld xmm2, xmm14
    pmulld xmm3, xmm15
	
	paddd xmm1, xmm2
	paddd xmm1, xmm3
	
	paddd xmm1, xmm11
	
	psrad xmm1, 8
	
	paddd xmm1, xmm12
	;paddd xmm1, xmm10
	
	packssdw xmm1, xmm0
	packuswb xmm1, xmm0
	
	movd [rsi], xmm1
    
    add rdi, 4
    add rsi, 4
    
    dec ecx
    jmp .ciclo
 
.fin:   
    pop r14
    pop r13
    pop r12 
    pop rbx
    pop rbp
	ret
