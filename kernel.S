
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"





;;============================define user address or macro starting=========================;; 
.equ     KER_TR ,         1000    ;TickRate in Hz, only defined, not calculated
.equ     KER_PRS,         0x03    ;For prescaler 64, manually select
.equ     KER_RLD,         0x82    ;KER_RLD = 0xFF-(F_CPU/KER_PRS/KER_TR), check overflow
.equ     KER_STK_SZ,      128     ;stack size in bytes for each task
.equ     KER_MX_NTSK,     10      ;max number of tasks
;;==============================define user address or macro end============================;; 





;;===============================define data offsets starting===============================;; 
.equ     OFF_TICK0,       0x00    ;tick count byte0 offset from KerBase
.equ     OFF_TICK1,       0x01    ;tick count byte1 offset from KerBase
.equ     OFF_TICK2,       0x02    ;tick count byte2 offset from KerBase
.equ     OFF_TICK3,       0x03    ;tick count byte3 offset from KerBase
.equ     OFF_TICK4,       0x04    ;tick count byte4 offset from KerBase
.equ     OFF_PRS  ,       0x05    ;counter prescaler offset from KerBase
.equ     OFF_RLD  ,       0x06    ;counter reload offset from KerBase
.equ     OFF_TID  ,       0x07    ;task id offset from KerBase
.equ     OFF_NTSK ,       0x08    ;ntask offset from KerBase
.equ     OFF_PTID ,       0x09    ;priority task_id offset from KerBase
;;==================================define data offsets end=================================;; 





;;===============================define system macro starting===============================;; 
.equ     TASK_READY,      0x01    ;bit 0 in system status reg
.equ     TASK_BLOCK,      0x00    ;bit 0 in system status reg
;;==================================define system macro end=================================;; 





;;===========================define hardware reg address starting===========================;; 
.equ     SRSREG  ,        0x5F    ;manually defined SREG in SRAM
.equ     SRSPH   ,        0x5E    ;manually defined SPH in SRAM
.equ     SRSPL   ,        0x5D    ;manually defined SPL in SRAM

.equ     SRTIMSK0,        0x6E    ;manually defined TIMSK0 in SRAM
.equ     SROCR0B ,        0x48    ;manually defined OCR0B in SRAM
.equ     SROCR0A ,        0x47    ;manually defined OCR0A in SRAM
.equ     SRTCNT0 ,        0x46    ;manually defined TCNT0 in SRAM
.equ     SRTCCR0B,        0x45    ;manually defined TCCR0B in SRAM
.equ     SRTCCR0A,        0x44    ;manually defined TCCR0A in SRAM
.equ     SRTIFR0 ,        0x35    ;manually defined TIFR0 in SRAM

.equ     IOOCR0B ,        0x28    ;manually defined OCR0B in IO
.equ     IOOCR0A ,        0x27    ;manually defined OCR0A in IO
.equ     IOTCNT0 ,        0x26    ;manually defined TCNT0 in IO
.equ     IOTCCR0B,        0x25    ;manually defined TCCR0B in IO
.equ     IOTCCR0A,        0x24    ;manually defined TCCR0A in IO
.equ     IOTIFR0 ,        0x15    ;manually defined TIFR0 in IO

.equ     IOSREG  ,        0x3F    ;manually defined SREG in IO
.equ     IOSPH   ,        0x3E    ;manually defined SPH in IO
.equ     IOSPL   ,        0x3D    ;manually defined SPL in IO
;;==============================define hardware reg address end=============================;; 





;;=============================define global variables starting=============================;; 
.section   .bss

.global    KerBase                 ;declare global space for kernel
KerBase:   .skip 10                ;Tick(5), prs(1), rld(1), task_id(1), ntask(1), ptid(1)

.global    KerPSP                  ;declare global space for process stack pointers
KerPSP:    .skip KER_MX_NTSK*2     ;2 bytes for each task

.global    KerSchSts               ;declare global space for scheduler status
KerSchSts: .skip KER_MX_NTSK*1     ;status(1)

.global    KerSchPr                ;declare global space for scheduler priority
KerSchPr:  .skip KER_MX_NTSK*1     ;priority(1)

.global    KerSchSlp               ;declare global space for task sleep
KerSchSlp: .skip KER_MX_NTSK*2     ;timing(2)

.global    KerStack                ;declare global space for stack
KerStack:  .skip KER_STK_SZ*10     ;KER_STK_SZ bytes for each task
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
.global  Kernel_Init
.global  Kernel_Task_Create
.global  Kernel_Start_Tasks
.global  Kernel_Task_Idle
.global  Kernel_Task_Sleep
.global  Kernel_Task_Sleep_Time_Get
.global  Kernel_Task_Sts_Get
.global  Kernel_Task_Prio_Get
.global  Kernel_High_Prio_Task_ID_Get
.global  Kernel_Abs_High_Prio_Task_ID_Get
;;================================define global functions end===============================;; 


       
;;============================debug pin operation init starting=============================;; 
.macro  KER_TIMER_INIT                                    ;total 1.5uS @8MHz      ( 12 clocks) 
        LDS   R16		         , KerBase+OFF_PRS        ;load prescaler         (  2 clocks) 
		LDS   R17		         , KerBase+OFF_RLD        ;load reload val        (  2 clocks) 
		STS   SRTCCR0B           , R16                    ;prescaler-> TCCR0B     (  2 clocks) 
		STS   SRTCNT0            , R17                    ;reload val-> TCNT0     (  2 clocks) 
		LDI   R16                , 0x01                   ;bit mask TOIE0         (  1 clock ) 
		STS   SRTIMSK0           , R16                    ;set to TIMSK0          (  2 clocks) 
		SEI                                               ;force enable interrupt (  1 clock ) 
.endm
;;==============================debug pin operation init end================================;; 





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
        LDS   R16                , KerBase+OFF_RLD        ;load reload value      (  2 clocks) 
		STS   SRTCNT0            , R16                    ;Set value to TCNT0     (  2 clocks) 
.endm
;;=================================reload counter value end=================================;; 





;;==================================context save starting===================================;; 
.macro  KER_CONTEXT_SAVE                                  ;total 8.5uS @8MHz      ( 68 clocks) 
        PUSH  R0                                          ;save R0                (  2 clocks) 
		IN    R0                 , IOSREG                 ;load SREG              (  1 clock ) 
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





;;===============================save current task sp starting==============================;; 
.macro  KER_SAVE_CURR_TASK_SP                             ;total 1.75uS @8MHz     ( 14 clocks) 
        LDS   R2                 , KerBase+OFF_TID        ;fetch task_id          (  2 clocks) 
		IN    R3                 , IOSPL                  ;fetch SPL0             (  1 clock ) 
		IN    R4                 , IOSPH                  ;fetch SPH0             (  1 clock ) 
		MOV   R16                , R2                     ;copy task_id           (  1 clock ) 
		LSL   R16                                         ;left shift to multiply (  1 clock ) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		ADD   ZL                 , R16                    ;add offset to array    (  1 clock ) 
		ADC   ZH                 , R1                     ;add carry, R1 zero reg (  1 clock ) 
		ST    Z+                 , R3                     ;store SPL at ZP        (  2 clocks) 
		ST    z                  , R4                     ;store SPH ZP+1         (  2 clocks) 
.endm
;;================================save current task sp end==================================;; 





;;==============================load next task id starting==================================;; 
.macro  KER_LOAD_NEXT_TASK_ID                             ;total 1.63uS @8MHz     ( 13 clocks) 
		MOV   R16                , R2                     ;copy task_id           (  1 clock ) 
		INC   R16                                         ;increment task_id      (  1 clock ) 
		LDS   R17                , KerBase+OFF_NTSK       ;load ntask             (  2 clocks) 
	_MOD_CONT\@:                                          ;use local label
	    CP    R16                , R17                    ;compare R17 with R16   (  1 clock ) 
		BRLO  _MOD_DONE\@                                 ;if R16<R17, done       (  2 clocks) 
		SUB   R16                , R17                    ;subtract R17 from R16  (  1 clock ) 
		RJMP  _MOD_CONT\@                                 ;go to loop start       (  2 clocks) 
	_MOD_DONE\@:                                          ;use local label
	    STS   KerBase+OFF_TID    , R16                    ;save task_id%ntask     (  2 clocks) 
		MOV   R2                 , R16                    ;copy task_id           (  1 clock ) 
.endm
;;=================================load next task id end====================================;; 





;;==============================increment tick counter starting=============================;; 
.macro  KER_TICK_INCREMENT                                ;total 3.13uS @8MHz     ( 25 clocks) 
		LDS   R16                , KerBase+OFF_TICK0      ;load Byte0             (  2 clocks) 
		INC   R16                                         ;add 1 with Byte0       (  1 clock ) 
		STS   KerBase+OFF_TICK0  , R16                    ;set Byte0              (  2 clocks) 
		LDS   R16                , KerBase+OFF_TICK1      ;load Byte1             (  2 clocks) 
		ADC   R16                , R1                     ;add carry with Byte1   (  1 clock ) 
		STS   KerBase+OFF_TICK1  , R16                    ;set Byte1              (  2 clocks) 
		LDS   R16                , KerBase+OFF_TICK2      ;load Byte2             (  2 clocks) 
		ADC   R16                , R1                     ;add carry with Byte2   (  1 clock ) 
		STS   KerBase+OFF_TICK2  , R16                    ;set Byte2              (  2 clocks) 
		LDS   R16                , KerBase+OFF_TICK3      ;load Byte3             (  2 clocks) 
		ADC   R16                , R1                     ;add carry with Byte3   (  1 clock ) 
		STS   KerBase+OFF_TICK3  , R16                    ;set Byte3              (  2 clocks) 
		LDS   R16                , KerBase+OFF_TICK4      ;load Byte4             (  2 clocks) 
		ADC   R16                , R1                     ;add carry with Byte4   (  1 clock ) 
		STS   KerBase+OFF_TICK4  , R16                    ;set Byte4              (  2 clocks) 
.endm
;;=================================increment tick counter end===============================;; 





;;==============================load task id & sp starting==================================;; 
.macro  KER_LOAD_TASK_ID_AND_SP                           ;total 1.5uS @8MHz      ( 12 clocks) 
		MOV   R16                , R2                     ;copy task_id           (  1 clock ) 
		LSL   R16                                         ;left shift to multiply (  1 clock ) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		ADD   ZL                 , R16                    ;add offset to array    (  1 clock ) 
		ADC   ZH                 , R1                     ;add carry if any       (  1 clock ) 
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
		KER_SAVE_CURR_TASK_SP                             ;save current task SP   ( 14 clocks) 
		KER_COUNTER_RELOAD                                ;counter reload         (  4 clocks) 
		;KER_TICK_INCREMENT                                ;increment tick counter ( 27 clocks) 
        
		
		;KER_DEC_SLP_TIMEOUT                               ;decrement of sleep time
		KER_LOAD_NEXT_TASK_ID                             ;load next task_id      ( 13 clocks)
		;KER_RUN_SCHEDULER                                 ;run scheduler          ( 14 clocks) 
	    
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 12 clocks) 
		KER_CONTEXT_RESTORE                               ;restore context        ( 67 clocks) 
	    KER_DEBUG_PIN_CLEAR                               ;debug pin clear        (  2 clocks) 
		RETI                                              ;return from interrupt  (  4 clocks) 
;;====================================ISR execution end=====================================;; 





;;================================SysTick reg init starting=================================;; 
Kernel_SysTick_Reg_Init:                                  ;total 6.0uS @8MHz      ( 48 clocks) 
        ;arg1 -> prescaler R24, arg2 -> reload val R22
        CLI                                               ;disable global int     (  1 clock ) 
		KER_DEBUG_PIN_INIT                                ;debug pin init         (  4 clocks) 
		LDI   R16                , 0x00                   ;set 0x00 to R16        (  1 clock ) 
		CLR   R1                                          ;gcc expects            (  1 clock ) 
		
		;clear tick counter
		STS   KerBase+OFF_TICK0  , R16                    ;clear  KerBase[0]      (  2 clocks) 
		STS   KerBase+OFF_TICK1  , R16                    ;clear  KerBase[1]      (  2 clocks) 
		STS   KerBase+OFF_TICK2  , R16                    ;clear  KerBase[2]      (  2 clocks) 
		STS   KerBase+OFF_TICK3  , R16                    ;clear  KerBase[3]      (  2 clocks) 
		STS   KerBase+OFF_TICK4  , R16                    ;clear  KerBase[4]      (  2 clocks) 
	    
		;clear system registers
		STS   KerBase+OFF_PRS    , R16                    ;clear  KerBase[5]      (  2 clocks) 
		STS   KerBase+OFF_RLD    , R16                    ;clear  KerBase[6]      (  2 clocks) 
		STS   KerBase+OFF_TID    , R16                    ;clear  KerBase[7]      (  2 clocks) 
		STS   KerBase+OFF_NTSK   , R16                    ;clear  KerBase[8]      (  2 clocks) 
        STS   KerBase+OFF_PTID   , R16                    ;clear  KerBase[9]      (  2 clocks) 
		
		;clear all timer registers
		STS   SRTCCR0A           , R16                    ;clear TCCR0A           (  2 clocks) 
		STS   SRTCCR0B           , R16                    ;clear TCCR0B           (  2 clocks) 
		STS   SRTIMSK0           , R16                    ;clear TIMSK0           (  2 clocks) 
		STS   SRTIFR0            , R16                    ;clear TIFR0            (  2 clocks) 
		STS   SROCR0A            , R16                    ;clear OCR0A            (  2 clocks) 
		STS   SROCR0B            , R16                    ;clear OCR0B            (  2 clocks) 
		STS   SRTCNT0            , R16                    ;clear TCNT0            (  2 clocks) 
		
		;store prescaler value
		STS   KerBase+OFF_PRS    , R24                    ;KerBase[5] prescaler   (  2 clocks) 
        
		;store reload value
		STS   KerBase+OFF_RLD    , R22                    ;KerBase[6] reload val  (  2 clocks) 
		
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================SysTick reg init end===================================;; 





;;===============================kernel task create starting================================;; 
Kernel_Task_Create:                                       ;total operation        (130 clocks) 
        ;func_ptr->R25:R24, task_priority->R22 
        ;save main SP & Z pointer 
        IN    R2                 , IOSPL                  ;save SPL of MSP        (  1 clock ) 
        IN    R3                 , IOSPH                  ;save SPH of MSP        (  1 clock ) 
        MOV   R4                 , ZL                     ;save ZPL               (  1 clock ) 
		MOV   R5                 , ZH                     ;save ZPH               (  1 clock ) 
        
		
		;across this function, R16 will be used as task_id 
		LDS   R16                , KerBase+OFF_TID        ;load task_id           (  2 clocks) 
		
		;set priority to KerSchPr+task_id
		LDI   ZL                 , lo8(KerSchPr)          ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchPr)          ;load high byte         (  1 clock ) 
		ADD   ZL                 , R16                    ;add low bytes          (  1 clock ) 
		ADC   ZH                 , R1                     ;add high byte+carry    (  1 clock ) 
		ST    Z                  , R22                    ;save priority          (  2 clocks) 
		
		;stack pointer for current task (KerStack + KER_STK_SZ*(task_id+1) - 1) ->stack top    
		MOV   R17                , R16                    ;load task_id           (  1 clock ) 
		INC   R17                                         ;increment task_id      (  1 clock ) 
		LDI   R18                , KER_STK_SZ             ;load stack size        (  1 clock ) 
		MUL   R17                , R18                    ;multiply to get offset (  2 clocks) 
		MOV   ZL                 , R0                     ;load multiplied low    (  1 clocks) 
		MOV   ZH                 , R1                     ;load multiplied high   (  1 clocks) 
		SBIW  ZL                 , 0x01                   ;dec multiplied val-1   (  2 clocks) 
		CLR   R1                                          ;gcc expects cleared    (  1 clock ) 
		LDI   R17                , lo8(KerStack)          ;load base addr low     (  1 clock ) 
		LDI   R18                , hi8(KerStack)          ;load base addr high    (  1 clock ) 
		ADD   ZL                 , R17                    ;add low bytes          (  1 clock ) 
		ADC   ZH                 , R18                    ;add high bytes+carry   (  1 clock ) 
		OUT   IOSPL              , ZL                     ;load SPL               (  1 clock ) 
        OUT   IOSPH              , ZH                     ;load SPH               (  1 clock ) 
		
		;function argument directly returns word address
	    PUSH  R24                                         ;push word addr low     (  2 clocks) 
		PUSH  R25                                         ;push word addr high    (  2 clocks) 
		
		;push context to stack of this task
		KER_CONTEXT_SAVE                                  ;save context           ( 68 clocks) 
		
		;read stack pointer of current task (necessary when restore)
		IN    R17                , IOSPL                  ;read SPL               (  1 clock ) 
        IN    R18                , IOSPH                  ;read SPH               (  1 clock ) 
		
		;calculate the address where current task's SP will be stored and store SP
		MOV   R19                , R16                    ;fetch task_id from arg (  1 clock ) 
		LSL   R19                                         ;left shift to multiply (  1 clock ) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		ADD   ZL                 , R19                    ;add offset to array    (  1 clock ) 
		ADC   ZH                 , R1                     ;add carry if any       (  1 clock ) 
		ST    Z+                 , R17                    ;SPL at KerPSp+offset   (  2 clocks) 
		ST    z                  , R18                    ;SPH at KerPSp+offset   (  2 clocks) 
		
		;increment task_id
		LDS   R17                , KerBase+OFF_TID        ;load task_id           (  2 clocks) 
		INC   R17                                         ;increment task_id      (  1 clock ) 
		STS   KerBase+OFF_TID    , R17                    ;store task_id          (  2 clocks) 

		;increment ntask
		LDS   R17                , KerBase+OFF_NTSK       ;load ntask             (  2 clocks) 
		INC   R17                                         ;increment ntask        (  1 clock ) 
		STS   KerBase+OFF_NTSK   , R17                    ;store ntask            (  2 clocks) 
		
		;load Main SP, restore Z pointer
		OUT   IOSPL              , R2                     ;load SPL               (  1 clock ) 
        OUT   IOSPH              , R3                     ;load SPH               (  1 clock ) 
		MOV   ZL                 , R4                     ;push ZPL               (  1 clock ) 
		MOV   ZH                 , R5                     ;push ZPL               (  1 clock ) 
		
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================kernel task create end==================================;; 





;;=================================kernel start tasks starting==============================;; 
Kernel_Start_Tasks:
		;start executing from task0
		;save ZP
		MOV   R4                 , ZL                     ;save ZPL               (  2 clocks) 
		MOV   R5                 , ZH                     ;save ZPH               (  2 clocks) 
		
		;clear task_id
		LDI   R16                , 0x00                   ;load task_id           (  2 clocks) 
		STS   KerBase+OFF_TID    , R16                    ;store task_id          (  2 clocks) 
		
		;load ZP with addr+offset
		LDI   ZL                 , lo8(KerPSP+0x00)       ;fetch ZPL KerPSP->TID0 (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP+0x00)       ;fetch ZPH KerPSP->TID0 (  1 clock ) 
		
		;load task_id 0 task's SP
		LD    R16                , Z+                     ;load val from Z, inc Z (  2 clocks) 
		LD    R17                , Z                      ;load val from Z+1      (  2 clocks) 
		
		;set task_id=0 task's SP
		OUT   IOSPL              , R16                    ;load SPL               (  1 clock ) 
        OUT   IOSPH              , R17                    ;load SPH               (  1 clock ) 
        
        ;forcefully restore context, in ISR it will be stored automatically
		KER_CONTEXT_RESTORE                               ;restore context        ( 67 clocks) 
		
		;restore ZP
		MOV   ZL                 , R4                     ;restore ZPL            (  2 clocks) 
		MOV   ZH                 , R5                     ;restore ZPL            (  2 clocks) 
		
		;config timer for system tick
		KER_TIMER_INIT                                    ;init timer, int enable ( 12 clocks) 
		
		;execute return to jump to task0, pushed while task init
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================kernel start tasks end==================================;; 





;;===================================kernel init starting===================================;; 
Kernel_Init:
		;save necessary registers and MSP
		IN    R16                , IOSPL                  ;load main SPL          (  1 clock ) 
		IN    R17                , IOSPH                  ;load main SPH          (  1 clock ) 
		PUSH  R16                                         ;save main SPL          (  2 clocks)
		PUSH  R17                                         ;save main SPH          (  2 clocks)
		PUSH  ZL                                          ;save ZPL               (  2 clocks) 
		PUSH  ZH                                          ;save ZPH               (  2 clocks) 

		;init timer for kernel 
		LDI   R24                , 0x03                   ;set prescaler          (  1 clock ) 
		LDI   R22                , 0x82                   ;set reload val         (  1 clock ) 
		CALL  Kernel_SysTick_Reg_Init                     ;init timer             ( 55 clocks) 
		
		;create idle task at task_id 0, priority 0xFF (lowest)
		LDI   R24                , lo8(Kernel_Task_Idle)  ;load func addr low     (  1 clock ) 
		LDI   R25                , hi8(Kernel_Task_Idle)  ;load func addr high    (  1 clock ) 
		LSR   R25                                         ;right shift to divide  (  1 clock ) 
		ROR   R24                                         ;rotate right th carry  (  1 clock ) 
		LDI   R22                , 0xFF                   ;set max val
		CALL  Kernel_Task_Create                          ;init idle task         (130 clocks) 
		
		;restore necessary registers and MSP
		POP   ZH                                          ;restore ZPL            (  2 clocks) 
		POP   ZL                                          ;restore ZPH            (  2 clocks) 
		POP   R17                                         ;load main SPH          (  1 clock ) 
		POP   R16                                         ;load main SPH          (  1 clock ) 
		OUT   IOSPL              , R16                    ;save main SPL          (  1 clock ) 
		OUT   IOSPH              , R17                    ;save main SPL          (  1 clock ) 

		;execute return to jump to task0, pushed while task init
		RET                                               ;return from subroutine (  4 clocks) 
;;======================================kernel init end=====================================;; 





;;=================================kernel idle task starting================================;; 
Kernel_Task_Idle:                                         ;jumps to this function when idle
        LDI   R25                , 0x00                   ;set UBRRH              (  1 clock ) 
        LDI   R24                , 0x00                   ;set UBRRL              (  1 clock ) 
        CALL  Debug_Init                                  ;debug init
    _IDLE_LOOP:                                           ;forever loop
	    LDI   R24                , 0x23
		CALL  Debug_Tx_Byte_Conf
		RJMP  _IDLE_LOOP                                  ;return from subroutine (  4 clocks) 
;;==================================kernel idle task end====================================;; 





;;=============================kernel task priority get starting============================;; 
Kernel_Task_Prio_Get:
		;get priority of the task id, arg (task_id->R24), return R24
		MOV   R16                , R24                    ;copy task_id           (  1 clock ) 
		LDI   ZL                 , lo8(KerSchPr)          ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchPr)          ;load high byte         (  1 clock ) 
		ADD   ZL                 , R16                    ;add low bytes          (  1 clock ) 
		ADC   ZH                 , R1                     ;add high byte+carry    (  1 clock ) 
		LD    R24                , Z                      ;load priority          (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;================================kernel task priority get end==============================;; 




