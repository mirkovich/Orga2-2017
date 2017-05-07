global ASM_linearZoom
extern C_linearZoom
; Parámetros:
;RDI = src, ESI = srcw, EDX = srch
;RCX = dst, R8d = dstw, R9d = dsth
ASM_linearZoom:
push rbp
mov rbp, rsp
push r12
push r13
push r14
push rbx
	xor rax, rax
	xor rbx, rbx
	lea eax, [esi*4]	;cant de bytes por fila en imagen fuente
	lea ebx, [r8d * 4]	;cant de bytes por fila en imagen destino
	pxor xmm7, xmm7
	xor r8, r8
	dec edx
	;dec r9d
	mov r8d, edx
	;mov r12, rcx; puntero a matriz destino
	;sub edx, 1 
	.ciclo_filas:
	cmp r8d, 0
	jle .borde_superior
	mov r10, rdi
	mov r11, rcx
	lea r9d, [esi -1]
	.ciclo_columnas:
		movdqu xmm0, [r10]	;xmm0 = |B'(b,g,r,a) | A'(b,g,r,a) | B(b,g,r,a) | A(b,g,r,a)|
		movdqu xmm1, xmm0
		punpcklbw xmm1, xmm7	;xmm1 = | B(b,g,r,a) | A(b,g,r,a) |
		movdqu xmm4, xmm1
		psrldq xmm4, 8			;xmm4 = | ****** | B(b,g,r,a) |
		paddusw xmm4, xmm1		;xmm4 = | *****  | A + B |
			
		movdqu xmm2, [r10 + rax]
		movdqu xmm3, xmm2
		punpcklbw xmm3, xmm7	;xmm3 = | D(b,g,r,a) | C(b,g,r,a) |
		movdqu xmm5, xmm3
		psrldq xmm5, 8			;xmm5 = | ****** | D(b,g,r,a) |
		paddusw xmm5, xmm3		;xmm5 = | ****** | C + D |
		
		paddusw xmm1, xmm3		;xmm1 = | B+D | A+C |
		paddusw xmm5, xmm4		;xmm5 = | ****** | A+B+C+D |
		
		psrlw xmm4, 1	;xmm4 = | *****  | (A + B)/2 |
		psrlw xmm1, 1	;xmm1 = | (B+D)/2 | (A+C)/2 |
		psrlw xmm5, 2	;xmm5 = | ****** | (A+B+C+D)/4 |
		packuswb xmm4, xmm7	;xmm4 = | ** | ** | ** | (A + B)/2 |
		packuswb xmm1, xmm7	;xmm1 = | ** | ** | ** | (A + C)/2 |
		packuswb xmm5, xmm7	;xmm5 = | ** | ** | ** | (A + B + C + D)/4 |
		
		pslldq xmm0, 12			;	
		psrldq xmm0, 12			;xmm0 = | 0000 | 0000 | 0000 | A(b,g,r,a)|
		pslldq xmm4, 4			;xmm4 = | ** | ** | (A + B)/2 | 0000 |
		paddusb xmm0, xmm4		;xmm0 = | 0000 | 0000 | (A + B)/2 | A(b,g,r,a)|
		movq qword [r11], xmm0
		
		pslldq xmm5, 4			;xmm5 = | ** | ** | (A + B + C + D)/4 | 0000 |
		pslldq xmm1, 12
		psrldq xmm1, 12			;xmm1 = | ** | ** | 0000 | (A + C)/2 |
		paddusb xmm1, xmm5		;xmm1 = | ** | ** | (A + B + C + D)/4 | (A + C)/2 |
		movq qword [r11+rbx], xmm0
		
		add r10, 4
		add r11, 8
		dec r9d
		cmp r9d, 0
		jg .ciclo_columnas
		call borde_derecho
		add rdi, rax
		lea rcx, [rcx+rbx*2]
		dec r8d
		jmp .ciclo_filas

.borde_superior:
		mov r10, rdi
		mov r11, rcx
		lea rcx, [esi-2]
		shr rcx, 1
		.ciclo:
			movdqu xmm0, [r10]		;xmm0 = | n4(b,g,r,a) | n3(b,g,r,a) | n2(b,g,r,a) | n1(b,g,r,a)|
			movdqu xmm1, xmm0
			psrldq xmm1, 4			;xmm1 = | **** | n4(b,g,r,a) | n3(b,g,r,a) | n2(b,g,r,a) |
			punpcklbw xmm0, xmm7	;xmm0 = | n2(b,g,r,a) | n1(b,g,r,a)|
			punpcklbw xmm1, xmm7	;xmm1 = | n3(b,g,r,a) | n2(b,g,r,a)|
			paddusw xmm1, xmm0		;xmm1 = | n2 + n3 | n1 + n2|
			psrlw xmm1, 1			;xmm1 = | (n2 + n3)/2 | (n1 + n2)/2|
			packuswb xmm0, xmm7		;xmm0 = | **** | **** | n2 | n1 |
			packuswb xmm1, xmm7		;xmm1 = | **** | **** | (n2+n3)/2 | (n1+n2)/2 |
			pslldq xmm0, 8				
			psrldq xmm0, 8			;xmm0 = | 0000 | 0000 | n2 | n1 |
			pslldq xmm1, 8	
			psrldq xmm1, 8			;xmm1 = | 0000 | 0000 | (n2+n3)/2 | (n1+n2)/2 |
			pshufd xmm0, xmm0, 0xD8	;xmm0 = | 0000 | n2 | 0000 | n1 |
			pshufd xmm1, xmm1, 0x72	;xmm1 = | (n2+n3)/2 | 0000 | (n1+n2)/2| 0000 |
			paddusb xmm0, xmm1
			movdqu [r11], xmm0
			movdqu [r11+rbx], xmm0
			add r10, 8
			add r11, 16
			loop .ciclo
		;solo faltaria procesar los dos ultimos pixeles
		pxor xmm0, xmm0	; para asegurarme que la parte alta no tenga basura
		pxor xmm1, xmm1
		movq qword xmm0, [r10]	;xmm0 = | 0000 | 0000 | n,n(b,g,r,a) | n,n-1(b,g,r,a)|
		movdqu xmm1, xmm0
		psrldq xmm1, 4			;xmm1 = | 0000 | 0000 | 0000 | n,n(b,g,r,a) |
		punpcklbw xmm0, xmm7	;xmm0 = | n,n(b,g,r,a) | n,n-1(b,g,r,a)|
		punpcklbw xmm1, xmm7	;xmm1 = | 0000 | n,n(b,g,r,a) |
		paddusw xmm1, xmm0		;xmm1 = | **** | n,n + n,n-1 |
		psrlw xmm1, 1			;xmm1 = | **** | (n,n + n,n-1)/2 |
		packuswb xmm0, xmm7		;xmm0 = | **** | **** | n,n | n,n-1 |
		packuswb xmm1, xmm7		;xmm1 = | **** | **** | **** | (n,n + n,n-1)/2 |
		pslldq xmm0, 8				
		psrldq xmm0, 8			;xmm0 = ;xmm0 = | 0000 | 0000 | n,n | n,n-1 |
		pslldq xmm1, 12	
		psrldq xmm1, 12			;xmm1 = | 0000 | 0000 | 0000 | (n,n + n,n-1)/2 |
		pshufd xmm0, xmm0, 0x58	;xmm0 = | n,n | n,n | 0000 | n,n-1 |
		pshufd xmm1, xmm1, 0xA2	;xmm1 = | 0000 | 0000 | (n,n + n,n-1)/2 | 0000 |
		paddusb xmm0, xmm1
		movdqu [r11], xmm0
		movdqu [r11+rbx], xmm0
			
pop rbx
pop r14
pop r13
pop r12
pop rbp
ret

borde_derecho:
	movdqu xmm0, [r10]		;xmm0 = | **** | **** | **** | PixelSuperior(b,g,r,a)|
	movdqu xmm1, [r10+rax]	;xmm1 = | **** | **** | **** | PixelInferior(b,g,r,a)|
	punpcklbw xmm0, xmm7	;xmm0 = | **** | PixelSuperior(b,g,r,a) |
	punpcklbw xmm1, xmm7	;xmm1 = | **** | PixelInferior(b,g,r,a) |
	paddusb xmm1, xmm0		;xmm1 = | **** | PixelInf(b,g,r,a) + PixelSup(b,g,r,a) |
	psrlw xmm1, 1			;xmm1 = | **** | (PixelInf(b,g,r,a) + PixelSup(b,g,r,a))/2 |
	packuswb xmm1, xmm7		;xmm1 = | **** | **** | **** | (PixelInf(b,g,r,a) + PixelSup(b,g,r,a))/2 |
	packuswb xmm0, xmm7		;xmm0 = | **** | **** | **** | PixelSuperior(b,g,r,a)|
	pshufd xmm0 , xmm0, 0x00	;xmm0 = | **** | **** | PixelSup(b,g,r,a) | PixelSup(b,g,r,a)|
	pshufd xmm1 , xmm1, 0x00	;xmm1 = | **** | **** | (PixelInf(b,g,r,a) + PixelSup(b,g,r,a))/2 | (PixelInf(b,g,r,a) + PixelSup(b,g,r,a))/2 |
	movq qword [r11], xmm0
	movq qword [r11+rbx], xmm1
ret
