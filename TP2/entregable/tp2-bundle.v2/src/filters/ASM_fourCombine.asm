global ASM_fourCombine
extern C_fourCombine

ASM_fourCombine:				;RDI = src, ESI = srcw, EDX = srch 
								;RCX = dst, R8d = dstw, R9d = dsth
	push rbp
	mov rbp, rsp
	sub rsp, 8
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	xor rax, rax
	mov rbx, rsi					;RBX = srcw
	mov r12, rdx					;R12 = srch
	mov r13, r8						;R13 = dstw
	mov r14, r9						;R14 = dsth
	
	mov rsi, rcx					;RSI = dst
	
	mov r8, rbx
	mov r9, r12
	shl r8, 2
	shl r9, 2
	
	mov rax, r13
	mul r14
	mov rcx, rax
	shr rcx, 2
	
	shr r14,1
	
	add r12, rax
	
	mov r10, rdi
	mov r11, rsi
	
	xor r15, r15
	
.ciclo:	
	movq xmm1, [rdi]					;xmm1 = |  0  |  0  |  p12  |  p11  |
	movq xmm2, [rdi + r8]    			;xmm2 = |  0  |  0  |  p22  |  p21  |
;	movaps xmm4, xmm2					;xmm4 = xmm2
	;10 10 10 01 = 0xA9
	pshufd xmm3, xmm1, 0xa9					;xmm3 =	|  0  |  0  |  0  |  p12  |
	pshufd xmm4, xmm2, 0xa9				    ;xmm4 = |  0  |  0  |  0  |  p22  |
	
	
	movd [rsi], xmm1
	movd [rsi + 2*r13], xmm3
	movd [rsi + 2*rax], xmm2
	movd [rsi + 2*r12], xmm4
	
	inc r15
	cmp r15, r14
	jne .seguir
	lea rdi, [r10 + 2*r8]
	lea rsi, [r11 + r9]
	mov r10, rdi
	mov r11, rsi
	xor r15, r15
	jmp .cont
.seguir:
	add rdi, 8
	add rsi, 4
.cont
	loop .ciclo
	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	add rsp, 8
	pop rbp
	ret
