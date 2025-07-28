
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"



;Initialize global variables
.section .bss
.global  Kernel              ;declare global space for kernel
Kernel:
.skip 6                      ;1B->ovf, 5B->TickCounter

.global  ker_tr              ;declare global space for ker_tr argument
ker_tr:
.skip 25                     ;for timer tick rate calculations



;Initialize vectors
.section .vectors, "ax", @progbits
.org    0x20
        RJMP  __vector_16



;Code section start
.section .text



;Initialize global functions
.global  Kernel_SysTick_Reg_Init
.global  Kernel_SysTick_Val_Get
.global  Kernel_Interrupt_Sts_Get



;Initialize interrupt vector subroutine
.global  __vector_16
    __vector_16:
	    
		;;======================if kernel debug enabled===========================;;
	    #ifdef KER_DBG_ENABLE
        SBI   KER_DBG_PORT ,  KER_DBG_PIN       ;set gpio
		#endif
		
		
		;;========================context save====================================;;
		;; total 68 clocks for context saving
        PUSH  R0                                ;save R0,                 (2 clocks)
		IN    R0           ,  0x3F              ;load SREG,               (1 clock )
		PUSH  R0                                ;save SREG,               (2 clocks)
		PUSH  R1                                ;save R1,                 (2 clocks)   
		CLR   R1                                ;clear R1,                (1 clock )
		PUSH  R2                                ;save R2,                 (2 clocks)   
		PUSH  R3                                ;save R3,                 (2 clocks)   
		PUSH  R4                                ;save R4,                 (2 clocks)   
		PUSH  R5                                ;save R5,                 (2 clocks)   
		PUSH  R6                                ;save R6,                 (2 clocks)   
		PUSH  R7                                ;save R7,                 (2 clocks)   
		PUSH  R8                                ;save R8,                 (2 clocks)   
		PUSH  R9                                ;save R9,                 (2 clocks)   
		PUSH  R10                               ;save R10,                (2 clocks)   
		PUSH  R11                               ;save R11,                (2 clocks)  
		PUSH  R12                               ;save R12,                (2 clocks)  
		PUSH  R13                               ;save R13,                (2 clocks)  
		PUSH  R14                               ;save R14,                (2 clocks)  
		PUSH  R15                               ;save R15,                (2 clocks)  
		PUSH  R16                               ;save R16,                (2 clocks)  
		PUSH  R17                               ;save R17,                (2 clocks)  
		PUSH  R18                               ;save R18,                (2 clocks)  
		PUSH  R19                               ;save R19,                (2 clocks)  
		PUSH  R20                               ;save R20,                (2 clocks)  
		PUSH  R21                               ;save R21,                (2 clocks)  
		PUSH  R22                               ;save R22,                (2 clocks)  
		PUSH  R23                               ;save R23,                (2 clocks)  
		PUSH  R24                               ;save R24,                (2 clocks)  
		PUSH  R25                               ;save R25,                (2 clocks)  
		PUSH  R26                               ;save R26,                (2 clocks)  
		PUSH  R27                               ;save R27,                (2 clocks)  
		PUSH  R28                               ;save R28,                (2 clocks)  
		PUSH  R29                               ;save R29,                (2 clocks)  
		PUSH  R30                               ;save R30,                (2 clocks)  
		PUSH  R31                               ;save R31,                (2 clocks)  
		
		
		;;=======================reload counter value=============================;;
		;; total 4 clocks for reloading
		LDS   R17          ,  Kernel+0x00       ;fetch reload value,      (2 clocks) 
		STS   TCNT0        ,  R17               ;Set value to TCNT0,      (2 clocks)  
		
		
		;;=======================increment tick counter===========================;;
		;; total 26 clocks for reloading, 40 bit counter
		LDI   R16          , 0x01               ;load 1 to R16,           (1 clock )
		LDS   R0           , Kernel+0x01        ;load Byte0,              (2 clocks)
		ADD   R0           , R16                ;add 1 with Byte0,        (1 clock )
		STS   Kernel+0x01  , R0                 ;set Byte0,               (2 clocks)
		LDS   R0           , Kernel+0x02        ;load Byte1,              (2 clocks)
		ADC   R0           , R1                 ;add carry with Byte1,    (1 clock )
		STS   Kernel+0x02  , R0                 ;set Byte1,               (2 clocks)
		LDS   R0           , Kernel+0x03        ;load Byte2,              (2 clocks)
		ADC   R0           , R1                 ;add carry with Byte2,    (1 clock )
		STS   Kernel+0x03  , R0                 ;set Byte2,               (2 clocks)
		LDS   R0           , Kernel+0x04        ;load Byte3,              (2 clocks)
		ADC   R0           , R1                 ;add carry with Byte3,    (1 clock )
		STS   Kernel+0x04  , R0                 ;set Byte3,               (2 clocks)
		LDS   R0           , Kernel+0x05        ;load Byte4,              (2 clocks)
		ADC   R0           , R1                 ;add carry with Byte4,    (1 clock )
		STS   Kernel+0x05  , R0                 ;set Byte4,               (2 clocks)
		
		
		;;=========================context restore================================;;
		;; total 68 clocks for context restore
		POP   R31                               ;restore R31,             (2 clocks) 
		POP   R30                               ;restore R30,             (2 clocks) 
		POP   R29                               ;restore R29,             (2 clocks)
		POP   R28                               ;restore R28,             (2 clocks) 
		POP   R27                               ;restore R27,             (2 clocks) 
		POP   R26                               ;restore R26,             (2 clocks) 
		POP   R25                               ;restore R25,             (2 clocks) 
		POP   R24                               ;restore R24,             (2 clocks) 
		POP   R23                               ;restore R23,             (2 clocks) 
		POP   R22                               ;restore R22,             (2 clocks) 
		POP   R21                               ;restore R21,             (2 clocks) 
		POP   R20                               ;restore R20,             (2 clocks) 
		POP   R19                               ;restore R19,             (2 clocks) 
		POP   R18                               ;restore R18,             (2 clocks) 
		POP   R17                               ;restore R17,             (2 clocks) 
		POP   R16                               ;restore R16,             (2 clocks) 
		POP   R15                               ;restore R15,             (2 clocks) 
		POP   R14                               ;restore R14,             (2 clocks) 
		POP   R13                               ;restore R13,             (2 clocks) 
		POP   R12                               ;restore R12,             (2 clocks) 
		POP   R11                               ;restore R11,             (2 clocks) 
		POP   R10                               ;restore R10,             (2 clocks) 
		POP   R9                                ;restore R9,              (2 clocks) 
		POP   R8                                ;restore R8,              (2 clocks) 
		POP   R7                                ;restore R7,              (2 clocks) 
		POP   R6                                ;restore R6,              (2 clocks) 
		POP   R5                                ;restore R5,              (2 clocks) 
		POP   R4                                ;restore R4,              (2 clocks) 
		POP   R3                                ;restore R3,              (2 clocks) 
		POP   R2                                ;restore R2,              (2 clocks) 
		POP   R1                                ;restore R1,              (2 clocks) 
		POP   R0                                ;fetch SREG,              (2 clocks) 
		OUT   0x3F         ,  R0                ;load SREG,               (1 clock ) 
		POP   R0                                ;restore R0,              (2 clocks) 
		
		
		;;======================if kernel debug enabled===========================;;
		#ifdef KER_DBG_ENABLE
		CBI   KER_DBG_PORT ,  KER_DBG_PIN       ;clear gpio
		#endif
		
		RETI                                    ;return from interrupt,   (4 clocks) 



;;==============================SysTick Reg Init===================================;;
;; total 32 clocks for SysTick Reg Init, omited debug gpio config
Kernel_SysTick_Reg_Init:
        
		#ifdef KER_DBG_ENABLE
		SBI   KER_DBG_DDR  ,  KER_DBG_PIN       ;set bit in DDR,          (2 clocks) 
		CBI   KER_DBG_PORT ,  KER_DBG_PIN       ;clear port bit,          (2 clocks) 
		#endif
		
		
        CLI                                     ;disable global interrupt,(1 clock ) 
		LDI   R16          ,  0x00              ;store r16 with 0,        (1 clock ) 
		STS   TCCR0A       ,  R16               ;clear TCCR0A,            (2 clocks) 
		STS   TCCR0B       ,  R16               ;clear TCCR0B,            (2 clocks) 
		STS   TIMSK0       ,  R16               ;clear TIMSK0,            (2 clocks) 
		STS   TIFR0        ,  R16               ;clear TIFR0,             (2 clocks) 
		STS   OCR0A        ,  R16               ;clear OCR0A,             (2 clocks) 
		STS   OCR0B        ,  R16               ;clear OCR0B,             (2 clocks) 
		STS   TCNT0        ,  R16               ;clear TCNT0,             (2 clocks) 
		LDI   R16          ,  KER_PRS           ;prescaler 64,            (1 clock ) 
		STS   TCCR0B       ,  R16               ;set to TCCR0B,           (2 clocks)
		LDI   R16          ,  KER_RLD           ;reload value (130),      (1 clock ) 
		STS   Kernel+0x00  ,  R16               ;Kernel[0] reload value,  (2 clocks) 
		STS   TCNT0        ,  R16               ;set to TCNT0,            (2 clocks) 
		LDI   R16          ,  0x01              ;store with TOIE0 enabled,(1 clock ) 
		STS   TIMSK0       ,  R16               ;set to TIMSK0,           (2 clocks) 
		SEI                                     ;enable global interrupt, (1 clock ) 
		RET                                     ;return from subroutine,  (4 clocks) 



;;=============================SysTick Value Get==================================;;
;; total 20 clocks for SysTick Value Get
;; interrupts disabled for 16 clocks
Kernel_SysTick_Val_Get:
        IN    R17          , 0x3F               ;Save SREG,               (1 clock ) 
        CLI                                     ;Disable interrupts,      (1 clock ) 
		LDS   R18		   , Kernel+0x01        ;Byte0 -> R18 (LSB),      (2 clocks) 
		LDS   R19		   , Kernel+0x02        ;Byte1 -> R19,            (2 clocks) 
		LDS   R20		   , Kernel+0x03        ;Byte2 -> R20,            (2 clocks) 
		LDS   R21		   , Kernel+0x04        ;Byte3 -> R21,            (2 clocks) 
		LDS   R22		   , Kernel+0x05        ;Byte4 -> R22 (MSB),      (2 clocks) 
		CLR   R23                 		        ;Clear Byte5,             (1 clock )
		CLR   R24						        ;Clear Byte5,             (1 clock )
		CLR   R25                               ;Clear Byte5,             (1 clock )
		OUT   0x3F, R17          		        ;Restore SREG,            (1 clock )
		RET                                     ;return from subroutine,  (4 clocks) 



;;===========================Interrupt Status Get=================================;;
;; total 10 clocks for Interrupt Status Get
Kernel_Interrupt_Sts_Get:
        LDI   R24		   , 0x00               ;clear R24,               (1 clock ) 
        IN    R16		   , 0x3F               ;save SREG in R16,        (1 clock )
		SBRC  R16		   , 0x07               ;check I flag->bit7,      (3 clocks)
		LDI   R24		   , 0x01               ;set R24 to 1,            (1 clock ) 
		RET                                     ;return from subroutine,  (4 clocks) 

