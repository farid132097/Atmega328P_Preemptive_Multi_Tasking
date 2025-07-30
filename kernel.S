
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"

;define user macros 
.equ     KER_TR ,         1000   ;TickRate in Hz, only defined, not calculated
.equ     KER_PRS,         0x03   ;For prescaler 64, manually select
.equ     KER_RLD,         0x83   ;ReloadVal = 0xFF-(F_CPU/prescaler/KER_TR)

.equ     KER_TSK0_DDR,    0x0A   ;DDRD IO address
.equ     KER_TSK0_PORT,   0x0B   ;PORTD IO address
.equ     KER_TSK0_PIN,    0x05   ;PORTD5 pin

.equ     KER_TSK1_DDR,    0x0A   ;DDRD IO address
.equ     KER_TSK1_PORT,   0x0B   ;PORTD IO address
.equ     KER_TSK1_PIN,    0x06   ;PORTD6 pin

.equ     KER_TSK2_DDR,    0x0A   ;DDRD IO address
.equ     KER_TSK2_PORT,   0x0B   ;PORTD IO address
.equ     KER_TSK2_PIN,    0x07   ;PORTD7 pin

.equ     KER_STZ,         128    ;stack size for each task


;define hardware register addresses macros 
.equ     SRSREG,          0x5F   ;manually defined SREG in SRAM
.equ     SRSPH,           0x5E   ;manually defined SPH in SRAM
.equ     SRSPL,           0x5D   ;manually defined SPL in SRAM

.equ     SRTIMSK0,        0x6E   ;manually defined TIMSK0 in SRAM
.equ     SROCR0B,         0x48   ;manually defined OCR0B in SRAM
.equ     SROCR0A,         0x47   ;manually defined OCR0A in SRAM
.equ     SRTCNT0,         0x46   ;manually defined TCNT0 in SRAM
.equ     SRTCCR0B,        0x45   ;manually defined TCCR0B in SRAM
.equ     SRTCCR0A,        0x44   ;manually defined TCCR0A in SRAM
.equ     SRTIFR0,         0x35   ;manually defined TIFR0 in SRAM

.equ     IOOCR0B,         0x28   ;manually defined OCR0B in IO
.equ     IOOCR0A,         0x27   ;manually defined OCR0A in IO
.equ     IOTCNT0,         0x26   ;manually defined TCNT0 in IO
.equ     IOTCCR0B,        0x25   ;manually defined TCCR0B in IO
.equ     IOTCCR0A,        0x24   ;manually defined TCCR0A in IO
.equ     IOTIFR0,         0x15   ;manually defined TIFR0 in IO

.equ     IOSREG,          0x3F   ;manually defined SREG in IO
.equ     IOSPH,           0x3E   ;manually defined SPH in IO
.equ     IOSPL,           0x3D   ;manually defined SPL in IO




;Initialize global variables
.section .bss
.global  Kernel                  ;declare global space for kernel
Kernel:
.skip 6                          ;1B->ovf, 5B->TickCounter

.global  ker_tcbb                ;declare global space for task control base
ker_tcbb:
.skip 2 

.global  ker_stp                 ;declare global space for stack pointers
ker_stp:
.skip 6                         

.global  ker_tcb0                ;declare global space for task control block0
ker_tcb0:
.skip KER_STZ                         

.global  ker_tcb1                ;declare global space for task control block1
ker_tcb1:
.skip KER_STZ                        

.global  ker_tcb2                ;declare global space for task control block2
ker_tcb2:
.skip KER_STZ                         

.global  ker_tr                  ;declare global space for ker_tr argument
ker_tr:
.skip 10                         ;for timer tick rate calculations



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

.global  Kernel_Test_Task0
.global  Kernel_Test_Task1
.global  Kernel_Test_Task2

.global  Kernel_Task_Init



;Initialize interrupt vector subroutine
.global  __vector_16
    __vector_16:
	    
		;;========================if kernel debug enabled=============================;;
	    #ifdef KER_DBG_ENABLE
        SBI   KER_DBG_PORT ,  KER_DBG_PIN           ;set gpio,                (2 clocks)
		#endif
		
		
		;;==========================context save======================================;;
		;; total 68 clocks for context saving
        PUSH  R0                                    ;save R0,                 (2 clocks)
		IN    R0           ,  IOSREG                ;load SREG,               (1 clock )
		PUSH  R0                                    ;save SREG,               (2 clocks)
		PUSH  R1                                    ;save R1,                 (2 clocks)   
		CLR   R1                                    ;clear R1,                (1 clock )
		PUSH  R2                                    ;save R2,                 (2 clocks)   
		PUSH  R3                                    ;save R3,                 (2 clocks)   
		PUSH  R4                                    ;save R4,                 (2 clocks)   
		PUSH  R5                                    ;save R5,                 (2 clocks)   
		PUSH  R6                                    ;save R6,                 (2 clocks)   
		PUSH  R7                                    ;save R7,                 (2 clocks)   
		PUSH  R8                                    ;save R8,                 (2 clocks)   
		PUSH  R9                                    ;save R9,                 (2 clocks)   
		PUSH  R10                                   ;save R10,                (2 clocks)   
		PUSH  R11                                   ;save R11,                (2 clocks)  
		PUSH  R12                                   ;save R12,                (2 clocks)  
		PUSH  R13                                   ;save R13,                (2 clocks)  
		PUSH  R14                                   ;save R14,                (2 clocks)  
		PUSH  R15                                   ;save R15,                (2 clocks)  
		PUSH  R16                                   ;save R16,                (2 clocks)  
		PUSH  R17                                   ;save R17,                (2 clocks)  
		PUSH  R18                                   ;save R18,                (2 clocks)  
		PUSH  R19                                   ;save R19,                (2 clocks)  
		PUSH  R20                                   ;save R20,                (2 clocks)  
		PUSH  R21                                   ;save R21,                (2 clocks)  
		PUSH  R22                                   ;save R22,                (2 clocks)  
		PUSH  R23                                   ;save R23,                (2 clocks)  
		PUSH  R24                                   ;save R24,                (2 clocks)  
		PUSH  R25                                   ;save R25,                (2 clocks)  
		PUSH  R26                                   ;save R26,                (2 clocks)  
		PUSH  R27                                   ;save R27,                (2 clocks)  
		PUSH  R28                                   ;save R28,                (2 clocks)  
		PUSH  R29                                   ;save R29,                (2 clocks)  
		PUSH  R30                                   ;save R30,                (2 clocks)  
		PUSH  R31                                   ;save R31,                (2 clocks)  
		
		
		;;=========================reload counter value===============================;;
		;; total 4 clocks for reloading
		LDS   R17          ,  Kernel+0x00           ;fetch reload value,      (2 clocks) 
		STS   SRTCNT0      ,  R17                   ;Set value to TCNT0,      (2 clocks) 
		
		
		;;=========================increment tick counter=============================;;
		;; total 26 clocks for reloading, 40 bit counter
		LDI   R16          , 0x01                   ;load 1 to R16,           (1 clock )
		LDS   R0           , Kernel+0x01            ;load Byte0,              (2 clocks)
		ADD   R0           , R16                    ;add 1 with Byte0,        (1 clock )
		STS   Kernel+0x01  , R0                     ;set Byte0,               (2 clocks)
		LDS   R0           , Kernel+0x02            ;load Byte1,              (2 clocks)
		ADC   R0           , R1                     ;add carry with Byte1,    (1 clock )
		STS   Kernel+0x02  , R0                     ;set Byte1,               (2 clocks)
		LDS   R0           , Kernel+0x03            ;load Byte2,              (2 clocks)
		ADC   R0           , R1                     ;add carry with Byte2,    (1 clock )
		STS   Kernel+0x03  , R0                     ;set Byte2,               (2 clocks)
		LDS   R0           , Kernel+0x04            ;load Byte3,              (2 clocks)
		ADC   R0           , R1                     ;add carry with Byte3,    (1 clock )
		STS   Kernel+0x04  , R0                     ;set Byte3,               (2 clocks)
		LDS   R0           , Kernel+0x05            ;load Byte4,              (2 clocks)
		ADC   R0           , R1                     ;add carry with Byte4,    (1 clock )
		STS   Kernel+0x05  , R0                     ;set Byte4,               (2 clocks)
		
		
		
		;;====================save stack pointer, current task========================;;
		;; 
		IN    R26          , IOSPL                  ;load SPL,                (1 clock )
		IN    R27          , IOSPH                  ;load SPH,                (1 clock )
		
		
	SV_TSK0_SP:
	    STS   ker_stp+0x00 , R26                    ;set STP,                 (2 clocks)
		STS   ker_stp+0x01 , R27                    ;set STP,                 (2 clocks)
	    
	SV_TSK1_SP:
	    STS   ker_stp+0x02 , R26                    ;set STP,                 (2 clocks)
		STS   ker_stp+0x03 , R27                    ;set STP,                 (2 clocks)
		
		
		
		
		;;===========================context restore==================================;;
		;; total 68 clocks for context restore
		POP   R31                                   ;restore R31,             (2 clocks) 
		POP   R30                                   ;restore R30,             (2 clocks) 
		POP   R29                                   ;restore R29,             (2 clocks)
		POP   R28                                   ;restore R28,             (2 clocks) 
		POP   R27                                   ;restore R27,             (2 clocks) 
		POP   R26                                   ;restore R26,             (2 clocks) 
		POP   R25                                   ;restore R25,             (2 clocks) 
		POP   R24                                   ;restore R24,             (2 clocks) 
		POP   R23                                   ;restore R23,             (2 clocks) 
		POP   R22                                   ;restore R22,             (2 clocks) 
		POP   R21                                   ;restore R21,             (2 clocks) 
		POP   R20                                   ;restore R20,             (2 clocks) 
		POP   R19                                   ;restore R19,             (2 clocks) 
		POP   R18                                   ;restore R18,             (2 clocks) 
		POP   R17                                   ;restore R17,             (2 clocks) 
		POP   R16                                   ;restore R16,             (2 clocks) 
		POP   R15                                   ;restore R15,             (2 clocks) 
		POP   R14                                   ;restore R14,             (2 clocks) 
		POP   R13                                   ;restore R13,             (2 clocks) 
		POP   R12                                   ;restore R12,             (2 clocks) 
		POP   R11                                   ;restore R11,             (2 clocks) 
		POP   R10                                   ;restore R10,             (2 clocks) 
		POP   R9                                    ;restore R9,              (2 clocks) 
		POP   R8                                    ;restore R8,              (2 clocks) 
		POP   R7                                    ;restore R7,              (2 clocks) 
		POP   R6                                    ;restore R6,              (2 clocks) 
		POP   R5                                    ;restore R5,              (2 clocks) 
		POP   R4                                    ;restore R4,              (2 clocks) 
		POP   R3                                    ;restore R3,              (2 clocks) 
		POP   R2                                    ;restore R2,              (2 clocks) 
		POP   R1                                    ;restore R1,              (2 clocks) 
		POP   R0                                    ;fetch SREG,              (2 clocks) 
		OUT   0x3F         ,  R0                    ;load SREG,               (1 clock ) 
		POP   R0                                    ;restore R0,              (2 clocks) 
		
		
		;;========================if kernel debug enabled=============================;;
		#ifdef KER_DBG_ENABLE
		CBI   KER_DBG_PORT ,  KER_DBG_PIN           ;clear gpio,              (2 clocks)
		#endif
		
		RETI                                        ;return from interrupt,   (4 clocks) 



;;================================SysTick Reg Init=====================================;;
;; total 32 clocks for SysTick Reg Init, omited debug gpio config
Kernel_SysTick_Reg_Init:
        
		#ifdef KER_DBG_ENABLE
		SBI   KER_DBG_DDR  ,  KER_DBG_PIN           ;set bit in DDR,          (2 clocks) 
		CBI   KER_DBG_PORT ,  KER_DBG_PIN           ;clear port bit,          (2 clocks) 
		#endif
		
		
        CLI                                         ;disable global interrupt,(1 clock ) 
		LDI   R16          ,  0x00                  ;store r16 with 0,        (1 clock ) 
		STS   SRTCCR0A     ,  R16                   ;clear TCCR0A,            (2 clocks) 
		STS   SRTCCR0B     ,  R16                   ;clear TCCR0B,            (2 clocks) 
		STS   SRTIMSK0     ,  R16                   ;clear TIMSK0,            (2 clocks) 
		STS   SRTIFR0      ,  R16                   ;clear TIFR0,             (2 clocks) 
		STS   SROCR0A      ,  R16                   ;clear OCR0A,             (2 clocks) 
		STS   SROCR0B      ,  R16                   ;clear OCR0B,             (2 clocks) 
		STS   SRTCNT0      ,  R16                   ;clear TCNT0,             (2 clocks) 
		LDI   R16          ,  KER_PRS               ;prescaler 64,            (1 clock ) 
		STS   SRTCCR0B     ,  R16                   ;set to TCCR0B,           (2 clocks)
		LDI   R16          ,  KER_RLD               ;reload value (130),      (1 clock ) 
		STS   Kernel+0x00  ,  R16                   ;Kernel[0] reload value,  (2 clocks) 
		STS   SRTCNT0      ,  R16                   ;set to TCNT0,            (2 clocks) 
		LDI   R16          ,  0x01                  ;store with TOIE0 enabled,(1 clock ) 
		STS   SRTIMSK0     ,  R16                   ;set to TIMSK0,           (2 clocks) 
		SEI                                         ;enable global interrupt, (1 clock ) 
		RET                                         ;return from subroutine,  (4 clocks) 



;;===============================SysTick Value Get====================================;;
;; total 20 clocks for SysTick Value Get
;; interrupts disabled for 16 clocks
Kernel_SysTick_Val_Get:
        IN    R17          , IOSREG                 ;Save SREG,               (1 clock ) 
        CLI                                         ;Disable interrupts,      (1 clock ) 
		LDS   R18		   , Kernel+0x01            ;Byte0 -> R18 (LSB),      (2 clocks) 
		LDS   R19		   , Kernel+0x02            ;Byte1 -> R19,            (2 clocks) 
		LDS   R20		   , Kernel+0x03            ;Byte2 -> R20,            (2 clocks) 
		LDS   R21		   , Kernel+0x04            ;Byte3 -> R21,            (2 clocks) 
		LDS   R22		   , Kernel+0x05            ;Byte4 -> R22 (MSB),      (2 clocks) 
		CLR   R23                 		            ;Clear Byte5,             (1 clock )
		CLR   R24						            ;Clear Byte5,             (1 clock )
		CLR   R25                                   ;Clear Byte5,             (1 clock )
		OUT   IOSREG       , R17          		    ;Restore SREG,            (1 clock )
		RET                                         ;return from subroutine,  (4 clocks) 



;;=============================Interrupt Status Get===================================;;
;; total 10 clocks for Interrupt Status Get
Kernel_Interrupt_Sts_Get:
        LDI   R24		   , 0x00                   ;clear R24,               (1 clock ) 
        IN    R16		   , IOSREG                 ;save SREG in R16,        (1 clock )
		SBRC  R16		   , 0x07                   ;check I flag->bit7,      (3 clocks)
		LDI   R24		   , 0x01                   ;set R24 to 1,            (1 clock ) 
		RET                                         ;return from subroutine,  (4 clocks) 













;;===============================Kernel Test Task0====================================;;
Kernel_Test_Task0:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK0_DDR ,  KER_TSK0_PIN          ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK0_PORT,  KER_TSK0_PIN          ;clear port bit,          (2 clocks)
		 
    LOOP0:
	    ;pin toggle, total 5 clocks
		IN    R16          ,  KER_TSK0_PORT         ;load PORT val,           (2 clocks)
		LDI   R17          ,  (1<<KER_TSK0_PIN)     ;bit mask for port pin    (1 clock )
		EOR   R16          ,  R17                   ;XOR with current val     (1 clock )
		OUT   KER_TSK0_PORT,  R16                   ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16          ,  0xEB                  ;set loop cnt val,        (1 clock )
		
    DLY00:
	    LDI   R17          ,  0xFF                  ;set loop cnt val,        (1 clock )
		
	DLY01:                                          ;inner loop,127.5uS@8Mhz  (4 clocks)
		NOP                                         ;no operation,            (1 clock )
		DEC   R17                                   ;decrement R17 val,       (1 clock )
		BRNE  DLY01                                 ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                   ;decrement R16 val,       (1 clock )
		BRNE  DLY00                                 ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP0                                 ;if R16 is 0->jump,       (2 clock ) 
		RET                                         ;return from subroutine,  (4 clocks) 



;;===============================Kernel Test Task1====================================;;
Kernel_Test_Task1:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK1_DDR ,  KER_TSK1_PIN          ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK1_PORT,  KER_TSK1_PIN          ;clear port bit,          (2 clocks)
		 
    LOOP1:
	    ;pin toggle, total 5 clocks
		IN    R16          ,  KER_TSK1_PORT         ;load PORT val,           (2 clocks)
		LDI   R17          ,  (1<<KER_TSK1_PIN)     ;bit mask for port pin    (1 clock )
		EOR   R16          ,  R17                   ;XOR with current val     (1 clock )
		OUT   KER_TSK1_PORT,  R16                   ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16          ,  0xEB                  ;set loop cnt val,        (1 clock )
		
    DLY10:
	    LDI   R17          ,  0xFF                  ;set loop cnt val,        (1 clock )
		
	DLY11:                                          ;inner loop,127.5uS@8Mhz  (4 clocks)
		NOP                                         ;no operation,            (1 clock )
		DEC   R17                                   ;decrement R17 val,       (1 clock )
		BRNE  DLY11                                 ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                   ;decrement R16 val,       (1 clock )
		BRNE  DLY10                                 ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP1                                 ;if R16 is 0->jump,       (2 clock ) 
		RET                                         ;return from subroutine,  (4 clocks) 
		



;;===============================Kernel Test Task2====================================;;
Kernel_Test_Task2:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK2_DDR ,  KER_TSK2_PIN          ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK2_PORT,  KER_TSK2_PIN          ;clear port bit,          (2 clocks)
		 
    LOOP2:
	    ;pin toggle, total 5 clocks
		IN    R16          ,  KER_TSK2_PORT         ;load PORT val,           (2 clocks)
		LDI   R17          ,  (1<<KER_TSK2_PIN)     ;bit mask for port pin    (1 clock )
		EOR   R16          ,  R17                   ;XOR with current val     (1 clock )
		OUT   KER_TSK2_PORT,  R16                   ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16          ,  0xEB                  ;set loop cnt val,        (1 clock )
		
    DLY20:
	    LDI   R17          ,  0xFF                  ;set loop cnt val,        (1 clock )
		
	DLY21:                                          ;inner loop, 127.5uS@8Mhz (4 clocks)
		NOP                                         ;no operation,            (1 clock )
		DEC   R17                                   ;decrement R17 val,       (1 clock )
		BRNE  DLY21                                 ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                   ;decrement R16 val,       (1 clock )
		BRNE  DLY20                                 ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP2                                 ;if R16 is 0->jump,       (2 clock ) 
		RET                                         ;return from subroutine,  (4 clocks) 
    

;;================================Kernel Task Init====================================;;
Kernel_Task_Init:
        ;init stack for task0
		LDI   R16          ,  hi8(ker_tcb0+KER_STZ) ;set loop cnt val,        (1 clock )
		OUT   IOSPH        ,  R16                   ;set SPH with high byte,  (1 clock )
		LDI   R16          ,  lo8(ker_tcb0+KER_STZ) ;set loop cnt val,        (1 clock )
		OUT   IOSPL        ,  R16                   ;set SPL with low byte,   (1 clock )

	