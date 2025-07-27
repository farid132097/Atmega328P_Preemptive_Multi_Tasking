
#include <avr/io.h>
#include <avr/interrupt.h>

;Initialize global variables
.section .bss
.global  Kernel              ;declare global space for kernel
Kernel:
.skip 6                      ;1B->ovf, 5B->TickCounter


.section .text

;Initialize global functions
.global  Kernel_SysTick_Reg_Init
.global  Kernel_SysTick_Val_Get
.global  Kernel_Interrupt_Sts_Get


;Initialize interrupt vector subroutine
.global  __vector_16
__vector_16:
        PUSH  R17                      ;save r17
		PUSH  R18                      ;save r18
		IN    R17          ,  0x3F     ;load SREG
		PUSH  R17                      ;save SREG
		
		LDS   R17          ,  Kernel+0x00
		STS   TCNT0        ,  R17      ;Set Reload value to TCNT0
		
		IN    R17          ,  0x08     ;fetch PORTC value
		LDI   R18          ,  (1<<5)   ;Bit mask for Bit pos 5
		EOR   R17          ,  R18      ;XOR with current val
		OUT   0x08         ,  R17      ;set to PORTC
		
		POP   R17                      ;fetch SREG val
		OUT   0x3F         ,  R17      ;restore SREG
		POP   R18                      ;restore R18
		POP   R17                      ;restore R17
		RETI

.org    0x28
        RJMP  __vector_16

Kernel_SysTick_Reg_Init:
        CLI                            ;disable global interrupt
		LDI   R16          ,  0x00     ;store r16 with 0
		STS   TCCR0A       ,  R16      ;clear TCCR0A
		STS   TCCR0B       ,  R16      ;clear TCCR0B
		STS   TIMSK0       ,  R16      ;clear TIMSK0
		STS   TIFR0        ,  R16      ;clear TIFR0
		STS   OCR0A        ,  R16      ;clear OCR0A
		STS   OCR0B        ,  R16      ;clear OCR0B
		STS   TCNT0        ,  R16      ;clear TCNT0
		
		LDI   R16          ,  0x03     ;store r16 with prescaler 64
		STS   TCCR0B       ,  R16      ;set to TCCR0B
		
		LDI   R16          ,  0x84     ;r16 with reload value (130)
		STS   Kernel + 0x00,  R16      ;Kernel[0] with reload value (130)
		
		STS   TCNT0        ,  R16      ;set to TCNT0
		LDI   R16          ,  0x01     ;store r16 with TOIE0 enabled
		STS   TIMSK0       ,  R16      ;set to TIMSK0
		SEI
		
		RET
		
Kernel_SysTick_Val_Get:
        
		RET
		
Kernel_Interrupt_Sts_Get:
        
		RET

