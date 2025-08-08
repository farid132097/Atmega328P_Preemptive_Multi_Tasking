
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"

#define  KER_CNTXT_SV_ISR
;#define  KER_TSK_SW_ISR
#define  KER_CNTXT_RS_ISR


;define user macros 
.equ     KER_TR ,         1000   ;TickRate in Hz, only defined, not calculated
.equ     KER_PRS,         0x03   ;For prescaler 64, manually select
.equ     KER_RLD,         0x82   ;ReloadVal = 0xFF-(F_CPU/prescaler/KER_TR)

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
.section  .bss
.global   Kernel                  ;declare global space for kernel
Kernel:   .skip 10                ;5B->TickCounter, 1B->ovf, 4B->Reserved

.global   ker_tski                ;declare global space for task index
ker_tski: .skip 2                 ;1B->TaskIndex, 1B->Reserved

.global   ker_stp                 ;declare global space for stack pointers
ker_stp:  .skip 6                 ;2B->STP0, 2B->STP1, 2B->STP2

.global   ker_stk0                ;declare global space for stack of task0
ker_stk0: .skip KER_STZ           ;KER_STZ B->Stack0

.global   ker_stk1                ;declare global space for stack of task1
ker_stk1: .skip KER_STZ           ;KER_STZ B->Stack1

.global   ker_stk2                ;declare global space for stack of task2
ker_stk2: .skip KER_STZ           ;KER_STZ B->Stack2



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

.global  Kernel_Task0_Init
.global  Kernel_Task1_Init
.global  Kernel_Task2_Init

.global  Kernel_Task_Debug
.global  Kernel_Task_Debug1


.macro  KER_CNTXT_SV
        ;;==============================context save========================================;; 
		;; total 68 clocks for context saving                                                  
        PUSH  R0                                          ;save R0,                 (2 clocks) 
		IN    R0                 , IOSREG                 ;load SREG,               (1 clock ) 
		PUSH  R0                                          ;save SREG,               (2 clocks) 
		PUSH  R1                                          ;save R1,                 (2 clocks) 
		CLR   R1                                          ;clear R1,                (1 clock ) 
		PUSH  R2                                          ;save R2,                 (2 clocks) 
		PUSH  R3                                          ;save R3,                 (2 clocks) 
		PUSH  R4                                          ;save R4,                 (2 clocks) 
		PUSH  R5                                          ;save R5,                 (2 clocks) 
		PUSH  R6                                          ;save R6,                 (2 clocks) 
		PUSH  R7                                          ;save R7,                 (2 clocks) 
		PUSH  R8                                          ;save R8,                 (2 clocks) 
		PUSH  R9                                          ;save R9,                 (2 clocks) 
		PUSH  R10                                         ;save R10,                (2 clocks) 
		PUSH  R11                                         ;save R11,                (2 clocks) 
		PUSH  R12                                         ;save R12,                (2 clocks) 
		PUSH  R13                                         ;save R13,                (2 clocks) 
		PUSH  R14                                         ;save R14,                (2 clocks) 
		PUSH  R15                                         ;save R15,                (2 clocks) 
		PUSH  R16                                         ;save R16,                (2 clocks) 
		PUSH  R17                                         ;save R17,                (2 clocks) 
		PUSH  R18                                         ;save R18,                (2 clocks) 
		PUSH  R19                                         ;save R19,                (2 clocks) 
		PUSH  R20                                         ;save R20,                (2 clocks) 
		PUSH  R21                                         ;save R21,                (2 clocks) 
		PUSH  R22                                         ;save R22,                (2 clocks) 
		PUSH  R23                                         ;save R23,                (2 clocks) 
		PUSH  R24                                         ;save R24,                (2 clocks) 
		PUSH  R25                                         ;save R25,                (2 clocks) 
		PUSH  R26                                         ;save R26,                (2 clocks) 
		PUSH  R27                                         ;save R27,                (2 clocks) 
		PUSH  R28                                         ;save R28,                (2 clocks) 
		PUSH  R29                                         ;save R29,                (2 clocks) 
		PUSH  R30                                         ;save R30,                (2 clocks) 
		PUSH  R31                                         ;save R31,                (2 clocks) 
.endm

.macro  KER_CNTXT_RS
        ;;===============================context restore====================================;; 
		;; total 68 clocks for context restore                                                 
		POP   R31                                         ;restore R31,             (2 clocks) 
		POP   R30                                         ;restore R30,             (2 clocks) 
		POP   R29                                         ;restore R29,             (2 clocks) 
		POP   R28                                         ;restore R28,             (2 clocks) 
		POP   R27                                         ;restore R27,             (2 clocks) 
		POP   R26                                         ;restore R26,             (2 clocks) 
		POP   R25                                         ;restore R25,             (2 clocks) 
		POP   R24                                         ;restore R24,             (2 clocks) 
		POP   R23                                         ;restore R23,             (2 clocks) 
		POP   R22                                         ;restore R22,             (2 clocks) 
		POP   R21                                         ;restore R21,             (2 clocks) 
		POP   R20                                         ;restore R20,             (2 clocks) 
		POP   R19                                         ;restore R19,             (2 clocks) 
		POP   R18                                         ;restore R18,             (2 clocks) 
		POP   R17                                         ;restore R17,             (2 clocks) 
		POP   R16                                         ;restore R16,             (2 clocks) 
		POP   R15                                         ;restore R15,             (2 clocks) 
		POP   R14                                         ;restore R14,             (2 clocks) 
		POP   R13                                         ;restore R13,             (2 clocks) 
		POP   R12                                         ;restore R12,             (2 clocks) 
		POP   R11                                         ;restore R11,             (2 clocks) 
		POP   R10                                         ;restore R10,             (2 clocks) 
		POP   R9                                          ;restore R9,              (2 clocks) 
		POP   R8                                          ;restore R8,              (2 clocks) 
		POP   R7                                          ;restore R7,              (2 clocks) 
		POP   R6                                          ;restore R6,              (2 clocks) 
		POP   R5                                          ;restore R5,              (2 clocks) 
		POP   R4                                          ;restore R4,              (2 clocks) 
		POP   R3                                          ;restore R3,              (2 clocks) 
		POP   R2                                          ;restore R2,              (2 clocks) 
		POP   R1                                          ;restore R1,              (2 clocks) 
		POP   R0                                          ;fetch SREG,              (2 clocks) 
		OUT   IOSREG             , R0                     ;load SREG,               (1 clock ) 
		POP   R0                                          ;restore R0,              (2 clocks) 
.endm

.macro  KER_TICK_INC
        ;;=============================increment tick counter===============================;;
		;; total 27 clocks for reloading, 40 bit counter
		LDI   R16                , 0x01                   ;load 1 to R16,           (1 clock )
		LDS   R17                , Kernel+0x00            ;load Byte0,              (2 clocks)
		ADD   R17                , R16                    ;add 1 with Byte0,        (1 clock )
		STS   Kernel+0x00        , R17                    ;set Byte0,               (2 clocks)
		LDI   R16                , 0x00                   ;load 0 to R16,           (1 clock )
		LDS   R17                , Kernel+0x01            ;load Byte1,              (2 clocks)
		ADC   R17                , R16                    ;add carry with Byte1,    (1 clock )
		STS   Kernel+0x01        , R17                    ;set Byte1,               (2 clocks)
		LDS   R17                , Kernel+0x02            ;load Byte2,              (2 clocks)
		ADC   R17                , R16                    ;add carry with Byte2,    (1 clock )
		STS   Kernel+0x02        , R17                    ;set Byte2,               (2 clocks)
		LDS   R17                , Kernel+0x03            ;load Byte3,              (2 clocks)
		ADC   R17                , R16                    ;add carry with Byte3,    (1 clock )
		STS   Kernel+0x03        , R17                    ;set Byte3,               (2 clocks)
		LDS   R17                , Kernel+0x04            ;load Byte4,              (2 clocks)
		ADC   R17                , R16                    ;add carry with Byte4,    (1 clock )
		STS   Kernel+0x04        , R17                    ;set Byte4,               (2 clocks)
.endm





;Initialize interrupt vector subroutine
.global  __vector_16
    __vector_16:
	    
		;;============================if kernel debug enabled===============================;;
	    #ifdef KER_DBG_ENABLE
        SBI   KER_DBG_PORT       , KER_DBG_PIN            ;set gpio,                (2 clocks)
		#endif
		
		
		;;==============================context save========================================;;
		;; total 68 clocks for context saving
		#ifdef KER_CNTXT_SV_ISR
        KER_CNTXT_SV
		#endif
		
		;;=============================reload counter value=================================;;
		;; total 4 clocks for reloading
		LDS   R16                , Kernel+0x08            ;fetch reload value,      (2 clocks) 
		STS   SRTCNT0            , R16                    ;Set value to TCNT0,      (2 clocks) 
		
		
		;;=============================increment tick counter===============================;;
		;; total 27 clocks for reloading, 40 bit counter
		KER_TICK_INC
		
		
		;;========================check current task index, save SP=========================;;
		;;
		#ifdef KER_TSK_SW_ISR
	    LDS   R16                , ker_tski               ;fetch task index,        (2 clocks)
		CPI   R16                , 0                      ;check if val!=0          (1 clock )
		BRNE  TSK1                                        ;goto saving task1 SP     (2 clocks)
		
		
		
		;;======================save stack pointer0, set task index 1=======================;;
		;;
	TSK0:
	    IN    R24                , IOSPL                  ;fetch SPL0,              (1 clock )
		IN    R25                , IOSPH                  ;fetch SPH0,              (1 clock )
		STS   ker_stp+0x00       , R24                    ;load  SPL0,              (2 clocks)
		STS   ker_stp+0x01       , R25                    ;load  SPH0,              (2 clocks)
		LDI   R16                , 0x01                   ;set ker_tski to 1,       (1 clock )
		STS   ker_tski           , R16                    ;load  ker_tski=1,        (2 clocks)
		LDS   R24                , ker_stp+0x02           ;fetch SPL0,              (2 clocks)
		LDS   R25                , ker_stp+0x03           ;fetch SPH0,              (2 clocks)
		OUT   IOSPL              , R24                    ;load SPL0,               (1 clock )
		OUT   IOSPH              , R25                    ;load SPH0,               (1 clock )
		RJMP  RS_CNTXT                                    ;jump to restore context, (2 clocks)
		
		
	    ;;======================save stack pointer1, set task index 0=======================;;
		;;
	TSK1:
	    IN    R24                , IOSPL                  ;fetch SPL0,              (1 clock )
		IN    R25                , IOSPH                  ;fetch SPH0,              (1 clock )
		STS   ker_stp+0x02       , R24                    ;load  SPL0,              (2 clocks)
		STS   ker_stp+0x03       , R25                    ;load  SPH0,              (2 clocks)
		LDI   R16                , 0x00                   ;set ker_tski to 0,       (1 clock )
		STS   ker_tski           , R16                    ;load  ker_tski=0,        (2 clocks)
		LDS   R24                , ker_stp+0x00           ;fetch SPL0,              (2 clocks)
		LDS   R25                , ker_stp+0x01           ;fetch SPH0,              (2 clocks)
		OUT   IOSPL              , R24                    ;load SPL0,               (1 clock )
		OUT   IOSPH              , R25                    ;load SPH0,               (1 clock )
		RJMP  RS_CNTXT                                    ;jump to restore context, (2 clocks)
		#endif
		
		
	RS_CNTXT:
		;;===============================context restore====================================;;
		;; total 68 clocks for context restore
		#ifdef KER_CNTXT_RS_ISR
		KER_CNTXT_RS
		#endif
		
		;;============================if kernel debug enabled===============================;;
		#ifdef KER_DBG_ENABLE
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear gpio,              (2 clocks)
		#endif
		
		RETI                                              ;return from interrupt,   (4 clocks) 



;;====================================SysTick Reg Init=======================================;;
;; total 32 clocks for SysTick Reg Init, omited debug gpio config
Kernel_SysTick_Reg_Init:
        ;clear all kernel variables
		LDI   R16                , 0x00                   ;set 0x00 to R16,         (1 clock )
		STS   Kernel+0x00        , R16                    ;clear  kernel[0],        (2 clocks)
		STS   Kernel+0x01        , R16                    ;clear  kernel[1],        (2 clocks)
		STS   Kernel+0x02        , R16                    ;clear  kernel[2],        (2 clocks)
		STS   Kernel+0x03        , R16                    ;clear  kernel[3],        (2 clocks)
		STS   Kernel+0x04        , R16                    ;clear  kernel[4],        (2 clocks)
		STS   Kernel+0x05        , R16                    ;clear  kernel[5],        (2 clocks)
		STS   Kernel+0x06        , R16                    ;clear  kernel[6],        (2 clocks)
		STS   Kernel+0x07        , R16                    ;clear  kernel[7],        (2 clocks)
		STS   Kernel+0x08        , R16                    ;clear  kernel[8],        (2 clocks)
		
		#ifdef KER_DBG_ENABLE
		SBI   KER_DBG_DDR        , KER_DBG_PIN            ;set bit in DDR,          (2 clocks) 
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear port bit,          (2 clocks) 
		#endif
		
		
        CLI                                               ;disable global interrupt,(1 clock ) 
		LDI   R16                , 0x00                   ;store r16 with 0,        (1 clock ) 
		STS   SRTCCR0A           , R16                    ;clear TCCR0A,            (2 clocks) 
		STS   SRTCCR0B           , R16                    ;clear TCCR0B,            (2 clocks) 
		STS   SRTIMSK0           , R16                    ;clear TIMSK0,            (2 clocks) 
		STS   SRTIFR0            , R16                    ;clear TIFR0,             (2 clocks) 
		STS   SROCR0A            , R16                    ;clear OCR0A,             (2 clocks) 
		STS   SROCR0B            , R16                    ;clear OCR0B,             (2 clocks) 
		STS   SRTCNT0            , R16                    ;clear TCNT0,             (2 clocks) 
		LDI   R16                , KER_PRS                ;prescaler 64,            (1 clock ) 
		STS   SRTCCR0B           , R16                    ;set to TCCR0B,           (2 clocks)
		LDI   R16                , KER_RLD                ;reload value (130),      (1 clock ) 
		STS   Kernel+0x08        , R16                    ;Kernel[5] reload value,  (2 clocks) 
		STS   SRTCNT0            , R16                    ;set to TCNT0,            (2 clocks) 
		LDI   R16                , 0x01                   ;store with TOIE0 enabled,(1 clock ) 
		STS   SRTIMSK0           , R16                    ;set to TIMSK0,           (2 clocks) 
		;SEI                                               ;enable global interrupt, (1 clock ) 
		RET                                               ;return from subroutine,  (4 clocks) 



;;===================================SysTick Value Get======================================;;
;; total 20 clocks for SysTick Value Get
;; interrupts disabled for 16 clocks
Kernel_SysTick_Val_Get:
        IN    R16                , IOSREG                 ;Save SREG,               (1 clock ) 
        CLI                                               ;Disable interrupts,      (1 clock ) 
		LDS   R18		         , Kernel+0x00            ;Byte0 -> R18 (LSB),      (2 clocks) 
		LDS   R19		         , Kernel+0x01            ;Byte1 -> R19,            (2 clocks) 
		LDS   R20		         , Kernel+0x02            ;Byte2 -> R20,            (2 clocks) 
		LDS   R21		         , Kernel+0x03            ;Byte3 -> R21,            (2 clocks) 
		LDS   R22		         , Kernel+0x04            ;Byte4 -> R22,            (2 clocks) 
		LDI   R23		         , 0x00                   ;Byte5 -> R23,            (1 clocks) 
		LDI   R24		         , 0x00                   ;Byte6 -> R24,            (1 clocks) 
		LDI   R25		         , 0x00                   ;Byte7 -> R25 (MSB),      (1 clocks) 
		OUT   IOSREG             , R16          		  ;Restore SREG,            (1 clock )
		RET                                               ;return from subroutine,  (4 clocks) 



;;=================================Interrupt Status Get=====================================;;
;; total 10 clocks for Interrupt Status Get
Kernel_Interrupt_Sts_Get:
        LDI   R24		         , 0x00                   ;clear R24,               (1 clock ) 
        IN    R16		         , IOSREG                 ;save SREG in R16,        (1 clock )
		SBRC  R16		         , 0x07                   ;check I flag->bit7,      (3 clocks)
		LDI   R24		         , 0x01                   ;set R24 to 1,            (1 clock ) 
		RET                                               ;return from subroutine,  (4 clocks) 













;;===================================Kernel Test Task0======================================;;
Kernel_Test_Task0:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK0_DDR       , KER_TSK0_PIN           ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK0_PORT      , KER_TSK0_PIN           ;clear port bit,          (2 clocks)
		 
    LOOP0:
	    ;pin toggle, total 5 clocks
		IN    R16                , KER_TSK0_PORT          ;load PORT val,           (2 clocks)
		LDI   R17                , (1<<KER_TSK0_PIN)      ;bit mask for port pin    (1 clock )
		EOR   R16                , R17                    ;XOR with current val     (1 clock )
		OUT   KER_TSK0_PORT      , R16                    ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16                , 0xEB                   ;set loop cnt val,        (1 clock )
		
    DLY00:
	    LDI   R17                , 0xFF                   ;set loop cnt val,        (1 clock )
		
	DLY01:                                                ;inner loop,127.5uS@8Mhz  (4 clocks)
		NOP                                               ;no operation,            (1 clock )
		DEC   R17                                         ;decrement R17 val,       (1 clock )
		BRNE  DLY01                                       ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                         ;decrement R16 val,       (1 clock )
		BRNE  DLY00                                       ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP0                                       ;if R16 is 0->jump,       (2 clock )  



;;===================================Kernel Test Task1======================================;;
Kernel_Test_Task1:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK1_DDR       , KER_TSK1_PIN           ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK1_PORT      , KER_TSK1_PIN           ;clear port bit,          (2 clocks)
		 
    LOOP1:
	    ;pin toggle, total 5 clocks
		IN    R16                , KER_TSK1_PORT          ;load PORT val,           (2 clocks)
		LDI   R17                , (1<<KER_TSK1_PIN)      ;bit mask for port pin    (1 clock )
		EOR   R16                , R17                    ;XOR with current val     (1 clock )
		OUT   KER_TSK1_PORT      , R16                    ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16                , 0xEB                   ;set loop cnt val,        (1 clock )
		
    DLY10:
	    LDI   R17                , 0xFF                   ;set loop cnt val,        (1 clock )
		
	DLY11:                                                ;inner loop,127.5uS@8Mhz  (4 clocks)
		NOP                                               ;no operation,            (1 clock )
		DEC   R17                                         ;decrement R17 val,       (1 clock )
		BRNE  DLY11                                       ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                         ;decrement R16 val,       (1 clock )
		BRNE  DLY10                                       ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP1                                       ;if R16 is 0->jump,       (2 clock )  


;;===================================Kernel Test Task2======================================;;
Kernel_Test_Task2:
        ;initialize DDR and Port register, total 4 clocks
        SBI   KER_TSK2_DDR       , KER_TSK2_PIN           ;set bit in DDR,          (2 clocks) 
		CBI   KER_TSK2_PORT      , KER_TSK2_PIN           ;clear port bit,          (2 clocks)
		 
    LOOP2:
	    ;pin toggle, total 5 clocks
		IN    R16                , KER_TSK2_PORT          ;load PORT val,           (2 clocks)
		LDI   R17                , (1<<KER_TSK2_PIN)      ;bit mask for port pin    (1 clock )
		EOR   R16                , R17                    ;XOR with current val     (1 clock )
		OUT   KER_TSK2_PORT      , R16                    ;set new PORT val,        (1 clock )
		
		;assign delay loop count val, for 30ms 
		LDI   R16                , 0xEB                   ;set loop cnt val,        (1 clock )
		
    DLY20:
	    LDI   R17                , 0xFF                   ;set loop cnt val,        (1 clock )
		
	DLY21:                                                ;inner loop, 127.5uS@8Mhz (4 clocks)
		NOP                                               ;no operation,            (1 clock )
		DEC   R17                                         ;decrement R17 val,       (1 clock )
		BRNE  DLY21                                       ;if R17 not equal to 0,   (2 clock ) 
		DEC   R16                                         ;decrement R16 val,       (1 clock )
		BRNE  DLY20                                       ;if R16 not equal to 0,   (2 clock ) 
		RJMP  LOOP2                                       ;if R16 is 0->jump,       (2 clock ) 
    

;;====================================Kernel Task0 Init=====================================;;
Kernel_Task0_Init:
        ;init stack for task0
		LDI   R16                , lo8(ker_stk0+KER_STZ)  ;fetch top SPL1,          (1 clock )
		LDI   R17                , hi8(ker_stk0+KER_STZ)  ;fetch top SPH1,          (1 clock )
		
		
		;debug
		MOV   R24                , R16                    ;copy val to R24          (1 clock )
		CALL  Debug_Tx_Byte                               ;send via uart
		MOV   R24                , R17                    ;copy val to R24          (1 clock )
		CALL  Debug_Tx_Byte                               ;send via uart
		
		
		OUT   IOSPL              , R16                    ;load SPL                 (1 clock )
        OUT   IOSPH              , R17                    ;load SPH                 (1 clock )
		
		LDI   R16                , lo8(Kernel_Test_Task0) ;fetch task address low,  (1 clock )
		PUSH  R16                                         ;push,                    (2 clocks) 
		LDI   R16                , hi8(Kernel_Test_Task0) ;fetch task address high, (1 clock )
		PUSH  R16                                         ;push,                    (2 clocks) 
		
        KER_CNTXT_SV
		
        IN    R16, IOSPL                                  ;fetch SPL                (1 clock )
        IN    R17, IOSPH                                  ;fetch SPH                (1 clock )
        STS   ker_stp + 0        , R16                    ;set stp of task0         (2 clocks) 
        STS   ker_stp + 1        , R17                    ;set stp of task0         (2 clocks) 
		
        RET                                               ;return from subroutine,  (4 clocks) 



;;====================================Kernel Task1 Init=====================================;;
Kernel_Task1_Init:
        ;init stack for task1
		LDI   R16                , lo8(ker_stk1+KER_STZ)  ;fetch top SPL1,          (1 clock )
		LDI   R17                , hi8(ker_stk1+KER_STZ)  ;fetch top SPH1,          (1 clock )
		
		;debug
		MOV   R24                , R16                    ;copy val to R24          (1 clock )
		CALL  Debug_Tx_Byte                               ;send via uart
		MOV   R24                , R17                    ;copy val to R24          (1 clock )
		CALL  Debug_Tx_Byte                               ;send via uart
		
		OUT   IOSPL              , R16                    ;load SPL                 (1 clock )
        OUT   IOSPH              , R17                    ;load SPH                 (1 clock )
		
		LDI   R16                , lo8(Kernel_Test_Task1) ;fetch task address low,  (1 clock )
		PUSH  R16                                         ;push,                    (2 clocks) 
		LDI   R16                , hi8(Kernel_Test_Task1) ;fetch task address high, (1 clock )
		PUSH  R16                                         ;push,                    (2 clocks) 
		
        KER_CNTXT_SV
		
        IN    R16, IOSPL                                  ;fetch SPL                (1 clock )
        IN    R17, IOSPH                                  ;fetch SPH                (1 clock )
        STS   ker_stp + 2        , R16                    ;set stp of task0         (2 clocks) 
        STS   ker_stp + 3        , R17                    ;set stp of task0         (2 clocks) 
		
        RET                                               ;return from subroutine,  (4 clocks) 


;;====================================Kernel Task Debug=====================================;;
Kernel_Task_Debug:
		
		;save OLD SP
		IN    R2                 , IOSPL
		IN    R3                 , IOSPH
		
		;set new SP
		LDI   R16                , lo8(0x0800)
		OUT   IOSPL              , R16
		LDI   R16                , hi8(0x0800)
		OUT   IOSPH              , R16
		
		;push
		LDI   R16                , lo8(0x0104)
		PUSH  R16                 
		LDI   R16                , hi8(0x0104)
		PUSH  R16                
		
		;save new SP
		IN    R4                 , IOSPL
		IN    R5                 , IOSPH
		
		;restore OLD SP
		MOV   R16                , R2
		OUT   IOSPL              , R16
		MOV   R16                , R3
		OUT   IOSPH              , R16
		
		;print from OLD SP
		LDI   R24                , lo8(0x0800)
		LDI   R25                , hi8(0x0800)
		LDI   R22                , 10
		CALL  Debug_Tx_RAM_Area
		MOV   R24                , R4
		CALL  Debug_Tx_Byte_Conf
		MOV   R24                , R5
		CALL  Debug_Tx_Byte_Conf
		LDI   R24                , lo8(Kernel_Task_Debug1)
		CALL  Debug_Tx_Byte_Conf
		LDI   R24                , hi8(Kernel_Task_Debug1)
		CALL  Debug_Tx_Byte_Conf
		
		
		;save OLD SP
		;IN    R2                 , IOSPL
		;IN    R3                 , IOSPH
		
		
		;restore new SP
		;MOV   R16                , R4
		;OUT   IOSPL              , R16
		;MOV   R16                , R5
		;OUT   IOSPH              , R16
	    ;CALL  Kernel_Task_Debug1          
		
		
		;set new SP
		LDI   R16                , lo8(0x07FE)
		OUT   IOSPL              , R16
		LDI   R16                , hi8(0x07FE)
		OUT   IOSPH              , R16
		
        RET



;;====================================Kernel Task Debug1=====================================;;
Kernel_Task_Debug1:
        ;save new SP
		IN    R4                 , IOSPL
		IN    R5                 , IOSPH
		
		;restore OLD SP
		MOV   R16                , R2
		OUT   IOSPL              , R16
		MOV   R16                , R3
		OUT   IOSPH              , R16
		
		;print from OLD SP
		LDI   R24                , lo8(0x0800)
		LDI   R25                , hi8(0x0800)
		LDI   R22                , 10
		CALL  Debug_Tx_RAM_Area
		MOV   R24                , R4
		CALL  Debug_Tx_Byte_Conf
		MOV   R24                , R5
		CALL  Debug_Tx_Byte_Conf
		
    __LF:
	    JMP   __LF