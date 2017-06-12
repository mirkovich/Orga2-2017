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
	
	
	movq xmm1, [rdi]
    
    punpcklbw xmm1, xmm0
    movups xmm4, xmm1
    punpcklwd xmm1, xmm0
	punpckhwd xmm4, xmm0

	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  U  |  U  |  U  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  V  |  V  |  V  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  Y  |  Y  |  Y  |  A  |
    
    pshufd xmm5, xmm4, 0xa8				;xmm2 = |  U  |  U  |  U  |  A  |
	pshufd xmm6, xmm4, 0x54				;xmm3 = |  V  |  V  |  V  |  A  |
	pshufd xmm4, xmm4, 0xfc				;xmm1 = |  Y  |  Y  |  Y  |  A  |

    psubd xmm1, xmm10					;xmm1 = | Y-16 | Y-16 | Y-16 |  A  |
    psubd xmm2, xmm11 					;xmm2 = |   U  | U-16 | U-16 |  A  |
    psubd xmm3, xmm12 					;xmm3 = | V-128| V-128|   V  |  A  |
    
    psubd xmm4, xmm10					;xmm4 = | Y-16 | Y-16 | Y-16 |  A  |
    psubd xmm5, xmm11 					;xmm5 = |   U  | U-16 | U-16 |  A  |
    psubd xmm6, xmm12 					;xmm6 = | V-128| V-128|   V  |  A  |

    pmulld xmm1, xmm13 					;xmm1 = |298*(Y-16) | 298*(Y-16) | 298*(Y-16)|   A   |
    pmulld xmm2, xmm14 					;xmm2 = |     0     |-100*(U-128)|516*(U-128)|   0   |
    pmulld xmm3, xmm15 					;xmm3 = |409*(V-128)|-208*(V-128)|     0     |   0   |
	
	pmulld xmm4, xmm13					;xmm4 = |298*(Y-16) | 298*(Y-16) | 298*(Y-16)|   A   |
    pmulld xmm5, xmm14   				;xmm5 = |     0     |-100*(U-128)|516*(U-128)|   0   |
    pmulld xmm6, xmm15 					;xmm6 = |409*(V-128)|-208*(V-128)|     0     |   0   |

	paddd xmm1, xmm2 					
	paddd xmm1, xmm3 					;xmm1 = |  Y+U+V  |  Y+U+V  |  Y+U+V  |  Y+U+V  |
	
	paddd xmm4, xmm5
	paddd xmm4, xmm6 					;xmm4 = |  Y+U+V  |  Y+U+V  |  Y+U+V  |  Y+U+V  |

	paddd xmm1, xmm9 					;xmm1 = | + 128  | + 128  | + 128  |   A   |
	paddd xmm4, xmm9 					;xmm4 = | + 128  | + 128  | + 128  |   A   |

	;shifteo los colores a 8 bits
	psrad xmm1, 8
	psrad xmm4, 8
	
	;en cada pixel los operacion transformaron los colores de YUV a RGB   xmm1 = |  R  |  G  |  B  |  A  | 
	;idem para xmm4

	packssdw xmm1, xmm4 				;empaqueto los colores de los 2 pixeles de dword a word con saturacion
	packuswb xmm1, xmm0 				;empaqueto los colores de word a byte acomodando los colores a su posicion de su pixel correspondiente
	
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
	
	movups xmm11, [aux1]
	movups xmm12, [aux2]
	
	movups xmm13, [m_R]
	movups xmm14, [m_G]
	movups xmm15, [m_B]
								
.ciclo:
	cmp ecx, 0
	je .fin										  	
	
	
	movq xmm1, [rdi]
    
    ;desempaqueto los colores de 2 pixeles de byte a dword para poder trabajar
    punpcklbw xmm1, xmm0
    movups xmm4, xmm1
    punpcklwd xmm1, xmm0 				;en xmm1 tengo los colores del 1º pixel 
	punpckhwd xmm4, xmm0 				;en xmm4 los colores del 2º pixel 
    
    ;reacomodo los colores en distintos registros para realizar las operacion en forma vertical
	pshufd xmm2, xmm1, 0xa8				;xmm2 = |  G  |  G  |  G  |  A  |
	pshufd xmm3, xmm1, 0x54				;xmm3 = |  B  |  B  |  B  |  A  |
	pshufd xmm1, xmm1, 0xfc				;xmm1 = |  R  |  R  |  R  |  A  |
    
    pshufd xmm5, xmm4, 0xa8				;xmm2 = |  G  |  G  |  G  |  A  |
	pshufd xmm6, xmm4, 0x54				;xmm3 = |  B  |  B  |  B  |  A  |
	pshufd xmm4, xmm4, 0xfc				;xmm1 = |  R  |  R  |  R  |  A  |

	;multiplico los colores por sus valores correspondientes declarados en section .data
    pmulld xmm1, xmm13					;xmm1 = | 66*R | -38*R | 112*R |  A  |
    pmulld xmm2, xmm14					;xmm2 = | 129*G | -74*G | -94*G |  0 |
    pmulld xmm3, xmm15					;xmm3 = | 25*B | 112*B | -18*B |  0  |

    pmulld xmm4, xmm13					;xmm4 = | 66*R | -38*R | 112*R |  A  |
    pmulld xmm5, xmm14					;xmm5 = | 129*G | -74*G | -94*G |  0 |
    pmulld xmm6, xmm15					;xmm6 = | 25*B | 112*B | -18*B |  0  |
	
	;
	paddd xmm1, xmm2 					;xmm1 = | R + G | R + G | R + G |  A  |
	paddd xmm1, xmm3 					;xmm1 = |  R+G+B | R+G+B | R+G+B |  A  | 

	paddd xmm4, xmm5 					;xmm4 = | R + G | R + G | R + G |  A  |
	paddd xmm4, xmm6 					;xmm4 = |  R+G+B | R+G+B | R+G+B |  A  | 
	
	paddd xmm1, xmm11 					;xmm1 = | ++128 |  ++128 | ++128 | A |
	paddd xmm4, xmm11 					;xmm4 = | ++128 |  ++128 | ++128 | A |

	;shifteo los colores a 8 bits
	psrad xmm1, 8
	psrad xmm4, 8

	paddd xmm1, xmm12 					;xmm1 = | ++16 |  ++128 | ++128 | A |
	paddd xmm4, xmm12					;xmm4 = | ++16 |  ++128 | ++128 | A |
; xmm1 = | Y | U | V |  A |    las operaciones anteriores dejaron acomodados los componentes de colores YUV en su determinada posicion
; lo mismo en xmm4 
	packssdw xmm1, xmm4 			;empaqueto de dword a word con saturacion
	packuswb xmm1, xmm0 			;empaqueto de word a byte para que los colores queden su posicion correspondiente de los pixeles
	
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
 
