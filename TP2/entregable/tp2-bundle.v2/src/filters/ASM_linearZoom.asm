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
	shr esi, 1	;anho/2   voy a procesar de a dos pixeles por vez
	.ciclo_filas:
	cmp r8d, 0
	jle .borde_superior
	mov r10, rdi
	mov r11, rcx
	lea r9d, [esi -1]
	.ciclo_columnas:
		movdqu xmm0, [r10]		;xmm0 = | 1,4(b,g,r,a) | 1,3(b,g,r,a) | 1,2(b,g,r,a) | 1,1(b,g,r,a)|
		movdqu xmm1, xmm0		
		psrldq xmm1, 4			;xmm1 = | 0000 | 1,4(b,g,r,a) | 1,3(b,g,r,a) | 1,2(b,g,r,a) |
		punpcklbw xmm0, xmm7	;xmm0 = | 1,2(b,g,r,a) | 1,1(b,g,r,a)|
		punpcklbw xmm1, xmm7	;xmm1 = | 1,3(b,g,r,a) | 1,2(b,g,r,a)|
		paddusw xmm1, xmm0		;xmm1 = | 1,2 + 1,3 | 1,1 + 1,2|
		movdqu xmm3, xmm0		;xmm3 = | 1,2(b,g,r,a) | 1,1(b,g,r,a)|
		movdqu xmm2, xmm1		;xmm2 = | 1,2 + 1,3 | 1,1 + 1,2|
		psrlw xmm1, 1			;xmm1 = | (1,2 + 1,3)/2 | (1,1 + 1,2)/2|
		packuswb xmm0, xmm7		;xmm0 = | 0000 | 0000 | 1,2 | 1,1 |
		packuswb xmm1, xmm7		;xmm1 = | 0000 | 0000 | (1,2+1,3)/2 | (1,1+1,2)/2 |
		
		pshufd xmm0, xmm0, 0x98	;xmm0 = | 0000 | 1,2 | 0000 | 1,1 |
		pshufd xmm1, xmm1, 0x62	;xmm1 = | (1,2+1,3)/2 | 0000 | (1,1+1,2)/2 | 0000 |
		paddusb xmm0, xmm1		;xmm0 = | (1,2+1,3)/2 | 1,2 | (1,1+1,2)/2 | 1,1 |
		movdqu [r11], xmm0
				
		movdqu xmm0, [r10 + rax];xmm0 = | 2,4(b,g,r,a) | 2,3(b,g,r,a) | 2,2(b,g,r,a) | 2,1(b,g,r,a)|
		movdqu xmm1, xmm0		
		psrldq xmm1, 4			;xmm1 = | 0000 | 2,4(b,g,r,a) | 2,3(b,g,r,a) | 2,2(b,g,r,a) |
		punpcklbw xmm0, xmm7	;xmm0 = | 2,2(b,g,r,a) | 2,1(b,g,r,a)|
		punpcklbw xmm1, xmm7	;xmm1 = | 2,3(b,g,r,a) | 2,2(b,g,r,a)|
		paddusw xmm1, xmm0		;xmm1 = | 2,2 + 2,3 | 2,1 + 2,2|
		
		paddusw xmm3, xmm0		;xmm3 = | 2,2+1,2 | 2,1+1,1 |
		paddusw xmm2, xmm1		;xmm2 = | 1,2+1,3+2,2+2,3 | 1,1+1,2+2,1+2,2|
		psrlw xmm3, 1			;xmm3 = | (2,2+1,2)/2 | (2,1+1,1)/2 |
		psrlw xmm2, 2			;xmm2 = | (1,2+1,3+2,2+2,3)/4 | (1,1+1,2+2,1+2,2)/4 |
		packuswb xmm3, xmm7		;xmm3 = | 0000 | 0000 | (2,2+1,2)/2 | (2,1+1,1)/2 |
		packuswb xmm2, xmm7		;xmm2 = | 0000 | 0000 | (1,2+1,3+2,2+2,3)/4 | (1,1+1,2+2,1+2,2)/4 
		pshufd xmm3, xmm3, 0x98
		pshufd xmm2, xmm2, 0x62
		paddusb xmm3, xmm2
		movdqu [r11+rbx], xmm3
				
		add r10, 8
		add r11, 16
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
		lea rcx, [esi-1]
		;shr rcx, 1
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
		movq xmm0, [r10]	;xmm0 = | 0000 | 0000 | n,n(b,g,r,a) | n,n-1(b,g,r,a)|
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
	;estando en una fila i y las 2 ultimas columnas
	pxor xmm0, xmm0	; para asegurarme que la parte alta no tenga basura
	;pxor xmm1, xmm1
	movq xmm0, [r10]	;xmm0 = | 0000 | 0000 | i,n(b,g,r,a) | i,n-1(b,g,r,a)|
	movdqu xmm1, xmm0
	psrldq xmm1, 4			;xmm1 = | 0000 | 0000 | 0000 | i,n(b,g,r,a) |
	punpcklbw xmm0, xmm7	;xmm0 = | i,n(b,g,r,a) | i,n-1(b,g,r,a)|
	punpcklbw xmm1, xmm7	;xmm1 = | 0000 | i,n(b,g,r,a) |
	paddusw xmm1, xmm0		;xmm1 = | 0000 | i,n + i,n-1 |
	
	movdqu xmm3, xmm0		;xmm3 = | i,n(b,g,r,a) | i,n-1(b,g,r,a)|
	movdqu xmm2, xmm1		;xmm2 = | 0000 | i,n + i,n-1 |
	
	psrlw xmm1, 1			;xmm1 = | 0000 | (i,n + i,n-1)/2 |
	packuswb xmm0, xmm7		;xmm0 = | 0000 | 0000 | i,n | i,n-1 |
	packuswb xmm1, xmm7		;xmm1 = | 0000 | 0000 | 0000 | (i,n + i,n-1)/2 |
	
	pshufd xmm0, xmm0, 0x58	;xmm0 = | i,n | i,n | 0000 | i,n-1 |
	pshufd xmm1, xmm1, 0xA2	;xmm1 = | 0000 | 0000 | (i,n + i,n-1)/2 | 0000 |
	paddusb xmm0, xmm1		;xmm0 = | i,n | i,n | (i,n + i,n-1)/2 | i,n-1 |
	movdqu [r11], xmm0
	
	pxor xmm0, xmm0	; para asegurarme que la parte alta no tenga basura
	;pxor xmm1, xmm1
	movq xmm0, [r10+rax]	;xmm0 = | 0000 | 0000 | i+1,n(b,g,r,a) | i+1,n-1(b,g,r,a)|
	movdqu xmm1, xmm0
	psrldq xmm1, 4			;xmm1 = | 0000 | 0000 | 0000 | i+1,n(b,g,r,a) |
	punpcklbw xmm0, xmm7	;xmm0 = | i+1,n(b,g,r,a) | i+1,n-1(b,g,r,a)|
	punpcklbw xmm1, xmm7	;xmm1 = | 0000 | i+1,n(b,g,r,a) |
	paddusw xmm1, xmm0		;xmm1 = | (i+1,n) | (i+1,n-1)+(i+1,n) |
	
	paddusw xmm3, xmm0		;xmm3 = | (i,n)+(i+1,n) | (i,n-1)+(i+1,n-1)|
	paddusw xmm2, xmm1		;xmm2 = | (i+1,n) | (i,n) + (i,n-1) + (i+1,n-1) + (i+1,n)|
	psrlw xmm3, 1			;xmm3 = | ((i,n)+(i+1,n))/2 | ((i,n-1)+(i+1,n-1))/2|
	psrlw xmm2, 2			;xmm2 = | ((i+1,n))/4 | ((i,n) + (i,n-1) + (i+1,n-1) + (i+1,n))/4 |
	packuswb xmm3, xmm7		;xmm3 = | 0000 | 0000 | ((i,n)+(i+1,n))/2 | ((i,n-1)+(i+1,n-1))/2|
	packuswb xmm2, xmm7		;xmm2 = | 0000 | 0000 | ((i+1,n))/4 | ((i,n)+(i,n-1)+(i+1,n-1)+(i+1,n))/4 |
	pshufd xmm3, xmm3, 0x58	
	pshufd xmm2, xmm2, 0xA2	
	paddusb xmm2, xmm3
	
	movdqu [r11+rbx], xmm2
	
ret
