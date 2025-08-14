
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"






;;============================define user address or macro starting=========================;; 
.equ     KER_TR ,         1000    ;TickRate in Hz, only defined, not calculated
.equ     KER_PRS,         0x03    ;For prescaler 64, manually select
.equ     KER_RLD,         0x82    ;KER_RLD = 0xFF-(F_CPU/KER_PRS/KER_TR), check overflow
.equ     KER_STZ,         128     ;stack size in bytes for each task
.equ     KER_MX_NTSK,     10      ;max number of tasks
;;==============================define user address or macro end============================;; 





;;===========================define hardware reg address starting===========================;; 
.equ     SRSREG,          0x5F    ;manually defined SREG in SRAM
.equ     SRSPH,           0x5E    ;manually defined SPH in SRAM
.equ     SRSPL,           0x5D    ;manually defined SPL in SRAM

.equ     SRTIMSK0,        0x6E    ;manually defined TIMSK0 in SRAM
.equ     SROCR0B,         0x48    ;manually defined OCR0B in SRAM
.equ     SROCR0A,         0x47    ;manually defined OCR0A in SRAM
.equ     SRTCNT0,         0x46    ;manually defined TCNT0 in SRAM
.equ     SRTCCR0B,        0x45    ;manually defined TCCR0B in SRAM
.equ     SRTCCR0A,        0x44    ;manually defined TCCR0A in SRAM
.equ     SRTIFR0,         0x35    ;manually defined TIFR0 in SRAM

.equ     IOOCR0B,         0x28    ;manually defined OCR0B in IO
.equ     IOOCR0A,         0x27    ;manually defined OCR0A in IO
.equ     IOTCNT0,         0x26    ;manually defined TCNT0 in IO
.equ     IOTCCR0B,        0x25    ;manually defined TCCR0B in IO
.equ     IOTCCR0A,        0x24    ;manually defined TCCR0A in IO
.equ     IOTIFR0,         0x15    ;manually defined TIFR0 in IO

.equ     IOSREG,          0x3F    ;manually defined SREG in IO
.equ     IOSPH,           0x3E    ;manually defined SPH in IO
.equ     IOSPL,           0x3D    ;manually defined SPL in IO
;;==============================define hardware reg address end=============================;; 





;;=============================define global variables starting=============================;; 
.section  .bss

.global   KerBase                 ;declare global space for kernel
KerBase:  .skip 10                ;TickCnt(5), rld_val(1), task_id(1), ntask(1), rsrvd(2)

.global   KerSP                   ;declare global space for stack pointers
KerSP:    .skip KER_MX_NTSK*2     ;2 bytes for each task

.global   KerSch                  ;declare global space for schedulers
KerSch:   .skip KER_MX_NTSK*4     ;timing(3), status(1)

.global   KerStack                ;declare global space for stack
KerStack: .skip KER_STZ*10        ;KER_STZ bytes for each task
;;==============================define global variables end=================================;; 





;;===============================define vector section starting=============================;; 
.section .vectors, "ax", @progbits

.org    0x20
        RJMP  __vector_16
;;=================================define vector section end================================;; 





;;===============================define text section starting===============================;; 
.section .text
;;==================================define text section end=================================;; 





;;==============================define global functions starting============================;; 
.global  Kernel_SysTick_Reg_Init
.global  Kernel_SysTick_Val_Get
.global  Kernel_SysTick_Val_Safely_Get
.global  Kernel_Interrupt_Sts_Get
.global  Kernel_Task_Init
.global  Kernel_Start_Tasks
;;================================define global functions end===============================;; 





;;============================debug pin operation init starting=============================;; 
.macro  KER_DEBUG_PIN_INIT                                ;total 0.5uS @8MHz      (  4 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
		SBI   KER_DBG_DDR        , KER_DBG_PIN            ;set bit in DDR         (  2 clocks) 
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear port bit         (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation init end================================;; 





;;===========================debug pin operation set starting===============================;; 
.macro  KER_DEBUG_PIN_SET                                 ;total 0.25uS @8MHz     (  2 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
        SBI   KER_DBG_PORT       , KER_DBG_PIN            ;set gpio               (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation set end=================================;; 





;;===========================debug pin operation clear starting=============================;; 
.macro  KER_DEBUG_PIN_CLEAR                               ;total 0.25uS @8MHz     (  2 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear gpio             (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation clear end===============================;; 





;;==============================reload counter value starting===============================;; 
.macro  KER_COUNTER_RELOAD                                ;total 0.5uS @8MHz      (  4 clocks) 
        LDS   R16                , KerBase+0x05           ;load reload value      (  2 clocks) 
		STS   SRTCNT0            , R16                    ;Set value to TCNT0     (  2 clocks) 
.endm
;;=================================reload counter value end=================================;; 





;;==================================context save starting===================================;; 
.macro  KER_CONTEXT_SAVE                                  ;total 8.5uS @8MHz      ( 68 clocks) 
        PUSH  R0                                          ;push R0                (  2 clocks) 
		IN    R0                 , IOSREG                 ;save SREG              (  1 clock ) 
		PUSH  R0                                          ;save SREG              (  2 clocks) 
		PUSH  R1                                          ;save R1                (  2 clocks) 
		CLR   R1                                          ;clear R1               (  1 clock ) 
		PUSH  R2                                          ;save R2                (  2 clocks) 
		PUSH  R3                                          ;save R3                (  2 clocks) 
		PUSH  R4                                          ;save R4                (  2 clocks) 
		PUSH  R5                                          ;save R5                (  2 clocks) 
		PUSH  R6                                          ;save R6                (  2 clocks) 
		PUSH  R7                                          ;save R7                (  2 clocks) 
		PUSH  R8                                          ;save R8                (  2 clocks) 
		PUSH  R9                                          ;save R9                (  2 clocks) 
		PUSH  R10                                         ;save R10               (  2 clocks) 
		PUSH  R11                                         ;save R11               (  2 clocks) 
		PUSH  R12                                         ;save R12               (  2 clocks) 
		PUSH  R13                                         ;save R13               (  2 clocks) 
		PUSH  R14                                         ;save R14               (  2 clocks) 
		PUSH  R15                                         ;save R15               (  2 clocks) 
		PUSH  R16                                         ;save R16               (  2 clocks) 
		PUSH  R17                                         ;save R17               (  2 clocks) 
		PUSH  R18                                         ;save R18               (  2 clocks) 
		PUSH  R19                                         ;save R19               (  2 clocks) 
		PUSH  R20                                         ;save R20               (  2 clocks) 
		PUSH  R21                                         ;save R21               (  2 clocks) 
		PUSH  R22                                         ;save R22               (  2 clocks) 
		PUSH  R23                                         ;save R23               (  2 clocks) 
		PUSH  R24                                         ;save R24               (  2 clocks) 
		PUSH  R25                                         ;save R25               (  2 clocks) 
		PUSH  R26                                         ;save R26               (  2 clocks) 
		PUSH  R27                                         ;save R27               (  2 clocks) 
		PUSH  R28                                         ;save R28               (  2 clocks) 
		PUSH  R29                                         ;save R29               (  2 clocks) 
		PUSH  R30                                         ;save R30               (  2 clocks) 
		PUSH  R31                                         ;save R31               (  2 clocks) 
.endm
;;=====================================context save end=====================================;; 





;;================================context restore starting==================================;; 
.macro  KER_CONTEXT_RESTORE                               ;total 8.38uS @8MHz     ( 67 clocks) 
		POP   R31                                         ;restore R31            (  2 clocks) 
		POP   R30                                         ;restore R30            (  2 clocks) 
		POP   R29                                         ;restore R29            (  2 clocks) 
		POP   R28                                         ;restore R28            (  2 clocks) 
		POP   R27                                         ;restore R27            (  2 clocks) 
		POP   R26                                         ;restore R26            (  2 clocks) 
		POP   R25                                         ;restore R25            (  2 clocks) 
		POP   R24                                         ;restore R24            (  2 clocks) 
		POP   R23                                         ;restore R23            (  2 clocks) 
		POP   R22                                         ;restore R22            (  2 clocks) 
		POP   R21                                         ;restore R21            (  2 clocks) 
		POP   R20                                         ;restore R20            (  2 clocks) 
		POP   R19                                         ;restore R19            (  2 clocks) 
		POP   R18                                         ;restore R18            (  2 clocks) 
		POP   R17                                         ;restore R17            (  2 clocks) 
		POP   R16                                         ;restore R16            (  2 clocks) 
		POP   R15                                         ;restore R15            (  2 clocks) 
		POP   R14                                         ;restore R14            (  2 clocks) 
		POP   R13                                         ;restore R13            (  2 clocks) 
		POP   R12                                         ;restore R12            (  2 clocks) 
		POP   R11                                         ;restore R11            (  2 clocks) 
		POP   R10                                         ;restore R10            (  2 clocks) 
		POP   R9                                          ;restore R9             (  2 clocks) 
		POP   R8                                          ;restore R8             (  2 clocks) 
		POP   R7                                          ;restore R7             (  2 clocks) 
		POP   R6                                          ;restore R6             (  2 clocks) 
		POP   R5                                          ;restore R5             (  2 clocks) 
		POP   R4                                          ;restore R4             (  2 clocks) 
		POP   R3                                          ;restore R3             (  2 clocks) 
		POP   R2                                          ;restore R2             (  2 clocks) 
		POP   R1                                          ;restore R1             (  2 clocks) 
		POP   R0                                          ;fetch SREG             (  2 clocks) 
		OUT   IOSREG             , R0                     ;load SREG              (  1 clock ) 
		POP   R0                                          ;restore R0             (  2 clocks) 
.endm
;;===================================context restore end====================================;; 





;;==============================increment tick counter starting=============================;; 
.macro  KER_TICK_INCREMENT                                ;total 3.38uS @8MHz     ( 27 clocks) 
		LDI   R16                , 0x01                   ;load 1 to R16          (  1 clock ) 
		LDS   R17                , KerBase+0x00           ;load Byte0             (  2 clocks) 
		ADD   R17                , R16                    ;add 1 with Byte0       (  1 clock ) 
		STS   KerBase+0x00       , R17                    ;set Byte0              (  2 clocks) 
		LDI   R16                , 0x00                   ;load 0 to R16          (  1 clock ) 
		LDS   R17                , KerBase+0x01           ;load Byte1             (  2 clocks) 
		ADC   R17                , R16                    ;add carry with Byte1   (  1 clock ) 
		STS   KerBase+0x01       , R17                    ;set Byte1              (  2 clocks) 
		LDS   R17                , KerBase+0x02           ;load Byte2             (  2 clocks) 
		ADC   R17                , R16                    ;add carry with Byte2   (  1 clock ) 
		STS   KerBase+0x02       , R17                    ;set Byte2              (  2 clocks) 
		LDS   R17                , KerBase+0x03           ;load Byte3             (  2 clocks) 
		ADC   R17                , R16                    ;add carry with Byte3   (  1 clock ) 
		STS   KerBase+0x03       , R17                    ;set Byte3              (  2 clocks) 
		LDS   R17                , KerBase+0x04           ;load Byte4             (  2 clocks) 
		ADC   R17                , R16                    ;add carry with Byte4   (  1 clock ) 
		STS   KerBase+0x04       , R17                    ;set Byte4              (  2 clocks) 
.endm
;;=================================increment tick counter end===============================;; 





;;===============================save current task sp starting==============================;; 
.macro  KER_SAVE_CURR_TASK_SP                             ;total 1.75uS @8MHz     ( 14 clocks) 
		IN    R16                , IOSPL                  ;fetch SPL0             (  1 clock ) 
		IN    R17                , IOSPH                  ;fetch SPH0             (  1 clock ) 
		LDS   R18                , KerBase+0x06           ;fetch task_id          (  2 clocks) 
		LSL   R18                                         ;left shift to multiply (  1 clock ) 
		LDI   R30                , lo8(KerSP)             ;fetch base pos low     (  1 clock ) 
		LDI   R31                , hi8(KerSP)             ;fetch base pos high    (  1 clock ) 
		ADD   R30                , R18                    ;add offset to array    (  1 clock ) 
		LDI   R18                , 0x00                   ;set 0 to R16           (  1 clock ) 
		ADC   R31                , R18                    ;add carry if any       (  1 clock ) 
		ST    Z+                 , R16                    ;store SPL at ZP        (  2 clocks) 
		ST    z                  , R17                    ;store SPH ZP+1         (  2 clocks) 
.endm
;;================================save current task sp end==================================;; 





;;==============================load next task id starting==================================;; 
.macro  KER_LOAD_NEXT_TASK_ID                             ;total 1.63uS @8MHz     ( 13 clocks) 
		LDS   R16                , KerBase+0x06           ;fetch task_id          (  2 clocks) 
		INC   R16                                         ;increment task index   (  1 clock ) 
		LDS   R17                , KerBase+0x07           ;load ntask             (  2 clocks) 
	_MOD_CONT:
	    CP    R16                , R17                    ;compare R17 with R16   (  1 clock ) 
		BRLO  _MOD_DONE                                   ;if R16<R17, done       (  2 clocks) 
		SUB   R16                , R17                    ;subtract R17 from R16  (  1 clock ) 
		RJMP  _MOD_CONT                                   ;go to loop start       (  2 clocks) 
	_MOD_DONE:
	    STS   KerBase+0x06       , R16                    ;save task_id%ntask     (  2 clocks) 
.endm
;;=================================load next task id end====================================;; 





;;==============================load task id & sp starting==================================;; 
.macro  KER_LOAD_TASK_ID_AND_SP                           ;total 1.75uS @8MHz     ( 14 clocks) 
	    LDS   R16                , KerBase+0x06           ;load task_id           (  2 clocks) 
		LSL   R16                                         ;left shift to multiply (  1 clock ) 
		LDI   R30                , lo8(KerSP)             ;fetch base pos low     (  1 clock ) 
		LDI   R31                , hi8(KerSP)             ;fetch base pos high    (  1 clock ) 
		ADD   R30                , R16                    ;add offset to array    (  1 clock ) 
		LDI   R16                , 0x00                   ;set 0 to R16           (  1 clock ) 
		ADC   R31                , R16                    ;add carry if any       (  1 clock ) 
		LD    R16                , Z+                     ;load SPL at ZP         (  2 clocks) 
		LD    R17                , Z                      ;load SPH at ZP         (  2 clocks) 
		OUT   IOSPL              , R16                    ;load SPL0              (  1 clock ) 
		OUT   IOSPH              , R17                    ;load SPH0              (  1 clock ) 
.endm
;;=================================load task id & sp end====================================;; 





;;=================================ISR execution starting===================================;; 
.global  __vector_16
    __vector_16:                                          ;total 26.13uS @8MHz    (211 clocks) 
	    KER_DEBUG_PIN_SET                                 ;debug pin set          (  2 clocks) 
        KER_CONTEXT_SAVE                                  ;save context           ( 68 clocks) 
		KER_COUNTER_RELOAD                                ;counter reload         (  4 clocks) 
		KER_TICK_INCREMENT                                ;increment tick counter ( 27 clocks)
        KER_SAVE_CURR_TASK_SP                             ;save current task SP   ( 14 clocks) 
		KER_LOAD_NEXT_TASK_ID                             ;inc & load next task ID( 13 clocks) 
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 14 clocks) 
		KER_CONTEXT_RESTORE                               ;restore context        ( 67 clocks) 
	    KER_DEBUG_PIN_CLEAR                               ;debug pin clear        (  2 clocks) 
		RETI                                              ;return from interrupt  (  4 clocks) 
;;====================================ISR execution end=====================================;; 





;;================================SysTick reg init starting=================================;; 
Kernel_SysTick_Reg_Init:                                  ;total operation        ( 55 clocks) 
        CLI                                               ;disable global int,    (  1 clock ) 
		KER_DEBUG_PIN_INIT                                ;debug pin init         (  4 clocks) 
		LDI   R16                , 0x00                   ;set 0x00 to R16,       (  1 clock ) 
		STS   KerBase+0x00       , R16                    ;clear  KerBase[0]      (  2 clocks) 
		STS   KerBase+0x01       , R16                    ;clear  KerBase[1]      (  2 clocks) 
		STS   KerBase+0x02       , R16                    ;clear  KerBase[2]      (  2 clocks) 
		STS   KerBase+0x03       , R16                    ;clear  KerBase[3]      (  2 clocks) 
		STS   KerBase+0x04       , R16                    ;clear  KerBase[4]      (  2 clocks) 
		STS   KerBase+0x05       , R16                    ;clear  KerBase[5]      (  2 clocks) 
		STS   KerBase+0x06       , R16                    ;clear  KerBase[6]      (  2 clocks) 
		STS   KerBase+0x07       , R16                    ;clear  KerBase[7]      (  2 clocks) 
		STS   KerBase+0x08       , R16                    ;clear  KerBase[8]      (  2 clocks) 
        STS   KerBase+0x09       , R16                    ;clear  KerBase[9]      (  2 clocks) 
		STS   KerBase+0x07       , R16                    ;set ntask to 0         (  2 clocks) 
		STS   SRTCCR0A           , R16                    ;clear TCCR0A           (  2 clocks) 
		STS   SRTCCR0B           , R16                    ;clear TCCR0B           (  2 clocks) 
		STS   SRTIMSK0           , R16                    ;clear TIMSK0           (  2 clocks) 
		STS   SRTIFR0            , R16                    ;clear TIFR0            (  2 clocks) 
		STS   SROCR0A            , R16                    ;clear OCR0A            (  2 clocks) 
		STS   SROCR0B            , R16                    ;clear OCR0B            (  2 clocks) 
		STS   SRTCNT0            , R16                    ;clear TCNT0            (  2 clocks) 
		MOV   R16                , R24                    ;prescaler from arg1    (  1 clock ) 
		STS   SRTCCR0B           , R16                    ;set to TCCR0B          (  2 clocks) 
		MOV   R16                , R22                    ;reload val from arg2   (  1 clock ) 
		STS   KerBase+0x05       , R16                    ;KerBase[5] reload val  (  2 clocks) 
		STS   SRTCNT0            , R16                    ;set to TCNT0           (  2 clocks) 
		LDI   R16                , 0x01                   ;bit mask TOIE0         (  1 clock ) 
		STS   SRTIMSK0           , R16                    ;set to TIMSK0          (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================SysTick reg init end===================================;; 





;;===============================SysTick value get starting=================================;; 
Kernel_SysTick_Val_Get:                                   ;total operation        ( 42 clocks) 
    _READ_AGAIN:
	    ;first read & store to actual return registers
		LDS   R18		         , KerBase+0x00           ;byte0 (LSB)            (  2 clocks) 
		LDS   R19		         , KerBase+0x01           ;byte1                  (  2 clocks) 
		LDS   R20		         , KerBase+0x02           ;byte2                  (  2 clocks) 
		LDS   R21		         , KerBase+0x03           ;byte3                  (  2 clocks) 
		LDS   R22		         , KerBase+0x04           ;byte4 (MSB)            (  2 clocks) 
		
		;second read to scratch registers
		LDS   R26		         , KerBase+0x00           ;byte0 (LSB)            (  2 clocks) 
		LDS   R27		         , KerBase+0x01           ;byte1                  (  2 clocks) 
		LDS   R30		         , KerBase+0x02           ;byte2                  (  2 clocks) 
		LDS   R31		         , KerBase+0x03           ;byte3                  (  2 clocks) 
		LDS   R0		         , KerBase+0x04           ;byte4 (MSB)            (  2 clocks) 
		
		;compare all pairs
		CP    R18                , R26                    ;compare                (  1 clock ) 
		BRNE  _READ_AGAIN                                 ;if !=0, read again     (  2 clocks) 
		CP    R19                , R27                    ;compare                (  1 clock ) 
		BRNE  _READ_AGAIN                                 ;if !=0, read again     (  2 clocks) 
		CP    R20                , R30                    ;compare                (  1 clock ) 
		BRNE  _READ_AGAIN                                 ;if !=0, read again     (  2 clocks) 
		CP    R21                , R31                    ;compare                (  1 clock ) 
		BRNE  _READ_AGAIN                                 ;if !=0, read again     (  2 clocks) 
		CP    R22                , R0                     ;compare                (  1 clock ) 
		BRNE  _READ_AGAIN                                 ;if !=0, read again     (  2 clocks) 
		
		;only 5 bytes data are taken, force clear 3 high bytes (64bit return R25:R18)
		LDI   R23		         , 0x00                   ;byte5 -> R23           (  1 clocks) 
		LDI   R24		         , 0x00                   ;byte6 -> R24           (  1 clocks) 
		LDI   R25		         , 0x00                   ;byte7 -> R25           (  1 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================SysTick value get end===================================;; 





;;============================SysTick value safely get starting=============================;; 
Kernel_SysTick_Val_Safely_Get:                            ;total operation        ( 20 clocks) 
        IN    R2                 , IOSREG                 ;save SREG              (  1 clock ) 
        CLI                                               ;disable interrupts     (  1 clock ) 
		LDS   R18		         , KerBase+0x00           ;byte0 -> R18 (LSB)     (  2 clocks) 
		LDS   R19		         , KerBase+0x01           ;byte1 -> R19           (  2 clocks) 
		LDS   R20		         , KerBase+0x02           ;byte2 -> R20           (  2 clocks) 
		LDS   R21		         , KerBase+0x03           ;byte3 -> R21           (  2 clocks) 
		LDS   R22		         , KerBase+0x04           ;byte4 -> R22           (  2 clocks) 
		LDI   R23		         , 0x00                   ;byte5 -> R23           (  1 clocks) 
		LDI   R24		         , 0x00                   ;byte6 -> R24           (  1 clocks) 
		LDI   R25		         , 0x00                   ;byte7 -> R25 (MSB)     (  1 clocks) 
		OUT   IOSREG             , R2          		      ;restore SREG           (  1 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===============================SysTick value safely get end===============================;; 





;;==============================interrupt status get starting===============================;; 
Kernel_Interrupt_Sts_Get:                                 ;total operation        ( 10 clocks) 
        LDI   R24		         , 0x00                   ;clear R24              (  1 clock ) 
        IN    R16		         , IOSREG                 ;save SREG in R16       (  1 clock ) 
		SBRC  R16		         , 0x07                   ;check I flag->bit7     (  3 clocks) 
		LDI   R24		         , 0x01                   ;set R24 to 1           (  1 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;================================interrupt status get end==================================;; 




;;================================kernel task init starting=================================;; 
Kernel_Task_Init:
        ;func_ptr->R25:R24, task_id->R22, task_priority->R20
        ;save main SP & Z pointer
        IN    R2                 , IOSPL                  ;save SPL of MSP        (  1 clock ) 
        IN    R3                 , IOSPH                  ;save SPH of MSP        (  1 clock ) 
        MOV   R4                 , R30                    ;save ZPL               (  2 clocks) 
		MOV   R5                 , R31                    ;save ZPH               (  2 clocks) 
		
		;increment ntask
		LDS   R16                , KerBase+0x07           ;load ntask             (  2 clocks) 
		INC   R16                                         ;increment ntask        (  1 clock ) 
		STS   KerBase+0x07       , R16                    ;store ntask            (  2 clocks) 
		
		;set stack pointer for current task (KerStack + KER_STZ*(ker_ind+1) - 1) ->stack top   
		MOV   R16                , R22                    ;load task_id           (  1 clock ) 
		INC   R16                                         ;increment task_id      (  1 clock ) 
		LDI   R17                , KER_STZ                ;load stack size        (  1 clock ) 
		MUL   R16                , R17                    ;multiply to get offset (  2 clocks) 
		MOV   R30                , R0                     ;load multiplied low    (  2 clocks) 
		MOV   R31                , R1                     ;load multiplied high   (  2 clocks) 
		SBIW  R30                , 0x01                   ;KER_STZ*(task_id+1)-1  (  2 clocks) 
		CLR   R1                                          ;gcc expects cleared    (  1 clock ) 
		LDI   R16                , lo8(KerStack)          ;load base addr low     (  1 clock ) 
		LDI   R17                , hi8(KerStack)          ;load base addr high    (  1 clock ) 
		ADD   R30                , R16                    ;add low bytes          (  1 clock ) 
		ADC   R31                , R17                    ;add high bytes+carry   (  1 clock ) 
		OUT   IOSPL              , R30                    ;load SPL               (  1 clock ) 
        OUT   IOSPH              , R31                    ;load SPH               (  1 clock ) 
		
		;function argument directly returns word address
	    PUSH  R24                                         ;push word addr low     (  2 clocks) 
		PUSH  R25                                         ;push word addr high    (  2 clocks) 
		
		;push context to stack of this task
		KER_CONTEXT_SAVE                                  ;save context           ( 68 clocks) 
		
		;read stack pointer of current task (necessary when restore)
		IN    R16                , IOSPL                  ;read SPL               (  1 clock ) 
        IN    R17                , IOSPH                  ;read SPH               (  1 clock ) 
		
		;calculate the address where current task's SP will be stored and store SP
		MOV   R18                , R22                    ;fetch task_id from arg (  1 clock ) 
		LSL   R18                                         ;left shift to multiply (  1 clock ) 
		LDI   R30                , lo8(KerSP)             ;fetch base pos low     (  1 clock ) 
		LDI   R31                , hi8(KerSP)             ;fetch base pos high    (  1 clock ) 
		ADD   R30                , R18                    ;add offset to array    (  1 clock ) 
		LDI   R18                , 0x00                   ;set 0 to R16           (  1 clock ) 
		ADC   R31                , R18                    ;add carry if any       (  1 clock ) 
		ST    Z+                 , R16                    ;SPL at KerSp+offset    (  2 clocks) 
		ST    z                  , R17                    ;SPH at KerSp+offset    (  2 clocks) 
		
		;load Main SP, restore Z pointer
		OUT   IOSPL              , R2                     ;load SPL               (  1 clock ) 
        OUT   IOSPH              , R3                     ;load SPH               (  1 clock ) 
		MOV   R30                , R4                     ;push ZPL               (  2 clocks) 
		MOV   R31                , R5                     ;push ZPL               (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================kernel task init end===================================;; 





;;===================================Kernel Task starting===================================;; 
Kernel_Start_Tasks:
		;start executing from task0
		;save ZP
		MOV   R4                 , R30                    ;save ZPL               (  2 clocks) 
		MOV   R5                 , R31                    ;save ZPH               (  2 clocks) 
		
		;load ZP with addr+offset
		LDI   R30                , lo8(KerSP)             ;fetch ZPL KerSP        (  1 clock ) 
		LDI   R31                , hi8(KerSP)             ;fetch ZPH KerSP        (  1 clock ) 
		
		;load last task's SP
		LD    R16                , Z+                     ;load val from Z, inc Z (  2 clocks) 
		LD    R17                , Z                      ;load val from Z+1      (  2 clocks) 
		
		;set last task's SP
		OUT   IOSPL              , R16                    ;load SPL               (  1 clock ) 
        OUT   IOSPH              , R17                    ;load SPH               (  1 clock ) 
       
        ;forcefully restore context, in ISR it will be stored automatically
		KER_CONTEXT_RESTORE                               ;restore context        ( 67 clocks) 
		
		;restore ZP
		MOV   R30                , R4                     ;restore ZPL            (  2 clocks) 
		MOV   R31                , R5                     ;restore ZPL            (  2 clocks) 
		
		;enable global interrupt to start executing task, starting with task0
		SEI                                               ;enable global int      (  1 clock ) 
		
		;execute return to jump to task0, pushed while task init
		RET                                               ;return from subroutine (  4 clocks) 
;;======================================Kernel Task end=====================================;; 





