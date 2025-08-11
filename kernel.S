
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






;;=============================define user address or macro start===========================;;
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
.equ     KER_NTASK,       2      ;total tasks
;;==============================define user address or macro end============================;;





;;=============================define hardware reg address start============================;;
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
;;==============================define hardware reg address end=============================;;





;;===============================define global variables start==============================;;
.section  .bss
.global   Kernel                  ;declare global space for kernel
Kernel:   .skip 10                ;TickCnt(5), rld_val(1), task_ind(1), ntask(1), rsrvd(2)

.global   ker_stp                 ;declare global space for stack pointers
ker_stp:  .skip 6                 ;2B->STP0, 2B->STP1, 2B->STP2

.global   ker_stk0                ;declare global space for stack of task0
ker_stk0: .skip KER_STZ           ;KER_STZ B->Stack0

.global   ker_stk1                ;declare global space for stack of task1
ker_stk1: .skip KER_STZ           ;KER_STZ B->Stack1

.global   ker_stk2                ;declare global space for stack of task2
ker_stk2: .skip KER_STZ           ;KER_STZ B->Stack2
;;================================define global variables end===============================;;





;;=================================define vector section start==============================;;
.section .vectors, "ax", @progbits
.org    0x20
        RJMP  __vector_16
;;=================================define vector section end================================;;





;;=================================define text section start================================;;
.section .text
;;==================================define text section end=================================;;





;;===============================define global functions start==============================;;
.global  Kernel_SysTick_Reg_Init
.global  Kernel_SysTick_Val_Get
.global  Kernel_Interrupt_Sts_Get

.global  Kernel_Task0_Init
.global  Kernel_Task1_Init
;;================================define global functions end===============================;;





;;==============================debug pin operation init start==============================;; 
.macro  KER_DEBUG_PIN_INIT                                ;total operation        (  4 clocks) 
        #ifdef KER_DBG_ENABLE
		SBI   KER_DBG_DDR        , KER_DBG_PIN            ;set bit in DDR         (  2 clocks) 
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear port bit         (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation init end================================;;





;;=============================debug pin operation set start================================;; 
.macro  KER_DEBUG_PIN_SET                                 ;total operation        (  2 clocks) 
        #ifdef KER_DBG_ENABLE
        SBI   KER_DBG_PORT       , KER_DBG_PIN            ;set gpio               (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation set end=================================;; 





;;=============================debug pin operation clear start==============================;; 
.macro  KER_DEBUG_PIN_CLEAR                               ;total operation        (  2 clocks) 
        #ifdef KER_DBG_ENABLE
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear gpio             (  2 clocks) 
		#endif
.endm
;;==============================debug pin operation clear end===============================;; 





;;================================reload counter value start================================;; 
.macro  KER_COUNTER_RELOAD                                ;total operation        (  4 clocks) 
        LDS   R16                , Kernel+0x08            ;fetch reload value     (  2 clocks) 
		STS   SRTCNT0            , R16                    ;Set value to TCNT0     (  2 clocks) 
.endm
;;=================================reload counter value end=================================;; 





;;====================================context save start====================================;; 
.macro  KER_CONTEXT_SAVE                                  ;total operation        ( 68 clocks) 
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





;;==================================context restore start===================================;; 
.macro  KER_CONTEXT_RESTORE                               ;total operation        ( 67 clocks) 
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





;;================================increment tick counter start==============================;;
.macro  KER_TICK_INCREMENT                                ;total operation        ( 27 clocks) 
		LDI   R16                , 0x01                   ;load 1 to R16          (  1 clock )
		LDS   R17                , Kernel+0x00            ;load Byte0             (  2 clocks)
		ADD   R17                , R16                    ;add 1 with Byte0       (  1 clock )
		STS   Kernel+0x00        , R17                    ;set Byte0              (  2 clocks)
		LDI   R16                , 0x00                   ;load 0 to R16          (  1 clock )
		LDS   R17                , Kernel+0x01            ;load Byte1             (  2 clocks)
		ADC   R17                , R16                    ;add carry with Byte1   (  1 clock )
		STS   Kernel+0x01        , R17                    ;set Byte1              (  2 clocks)
		LDS   R17                , Kernel+0x02            ;load Byte2             (  2 clocks)
		ADC   R17                , R16                    ;add carry with Byte2   (  1 clock )
		STS   Kernel+0x02        , R17                    ;set Byte2              (  2 clocks)
		LDS   R17                , Kernel+0x03            ;load Byte3             (  2 clocks)
		ADC   R17                , R16                    ;add carry with Byte3   (  1 clock )
		STS   Kernel+0x03        , R17                    ;set Byte3              (  2 clocks)
		LDS   R17                , Kernel+0x04            ;load Byte4             (  2 clocks)
		ADC   R17                , R16                    ;add carry with Byte4   (  1 clock )
		STS   Kernel+0x04        , R17                    ;set Byte4              (  2 clocks)
.endm
;;=================================increment tick counter end===============================;;





;;======================================task switch start===================================;;
.macro  KER_TASK_SWITCH                                   ;total operation        ( 39 clocks) 
		IN    R24                , IOSPL                  ;fetch SPL0             (  1 clock )
		IN    R25                , IOSPH                  ;fetch SPH0             (  1 clock )
		LDS   R16                , Kernel+0x06            ;fetch task index       (  2 clocks)
		LSL   R16                                         ;left shift to multiply (  1 clock )
		LDI   R30                , lo8(ker_stp)           ;fetch base pos low     (  1 clock )
		LDI   R31                , hi8(ker_stp)           ;fetch base pos high    (  1 clock )
		ADD   R30                , R16                    ;add offset to array    (  1 clock )
		LDI   R16                , 0x00                   ;set 0 to R16           (  1 clock )
		ADC   R31                , R16                    ;add carry if any       (  1 clock )
		ST    Z+                 , R24                    ;store SPL at ZP        (  2 clocks)
		ST    z                  , R25                    ;store SPH ZP+1         (  2 clocks)
		LDS   R16                , Kernel+0x06            ;fetch task index       (  2 clocks)
		INC   R16                                         ;increment task index   (  1 clock )
		LDS   R17                , Kernel+0x07            ;load number of tasks   (  2 clocks)
	_MOD_CONT:
	    CP    R16                , R17                    ;compare R17 with R16   (  1 clock )
		BRLO  _MOD_DONE                                   ;if R16<R17, done       (  2 clocks)
		SUB   R16                , R17                    ;subtract R17 from R16  (  1 clock )
		RJMP  _MOD_CONT                                   ;go to loop start       (  2 clocks)
	_MOD_DONE:
	    STS   Kernel+0x06        , R16                    ;task_ind%ntask         (  2 clocks)
		LSL   R16                                         ;left shift to multiply (  1 clock )
		LDI   R30                , lo8(ker_stp)           ;fetch base pos low     (  1 clock )
		LDI   R31                , hi8(ker_stp)           ;fetch base pos high    (  1 clock )
		ADD   R30                , R16                    ;add offset to array    (  1 clock )
		LDI   R16                , 0x00                   ;set 0 to R16           (  1 clock )
		ADC   R31                , R16                    ;add carry if any       (  1 clock )
		LD    R24                , Z+                     ;load SPL at ZP         (  2 clocks)
		LD    R25                , Z                      ;load SPH at ZP         (  2 clocks)
		OUT   IOSPL              , R24                    ;load SPL0              (  1 clock )
		OUT   IOSPH              , R25                    ;load SPH0              (  1 clock )
.endm
;;=======================================task switch end====================================;;





;;===================================ISR execution start====================================;;
.global  __vector_16
    __vector_16:                                          ;total operation        (208 clocks)
	    KER_DEBUG_PIN_SET                                 ;debug pin set          (  2 clocks) 
        KER_CONTEXT_SAVE                                  ;save context           ( 68 clocks) 
		KER_COUNTER_RELOAD                                ;counter reload         (  4 clocks) 
		KER_TICK_INCREMENT                                ;increment tick counter ( 27 clocks) 
		KER_TASK_SWITCH                                   ;task switching         ( 38 clocks) 
		KER_CONTEXT_RESTORE                               ;restore context        ( 67 clocks) 
	    KER_DEBUG_PIN_CLEAR                               ;debug pin clear        (  2 clocks) 
		RETI                                              ;return from interrupt  (  4 clocks) 
;;====================================ISR execution end=====================================;;





;;==================================SysTick reg init start==================================;;
Kernel_SysTick_Reg_Init:                                  ;total operation        ( 55 clocks)
        CLI                                               ;disable global int,    (  1 clock ) 
		KER_DEBUG_PIN_INIT                                ;debug pin init         (  4 clocks) 
		LDI   R16                , 0x00                   ;set 0x00 to R16,       (  1 clock ) 
		STS   Kernel+0x00        , R16                    ;clear  kernel[0]       (  2 clocks) 
		STS   Kernel+0x01        , R16                    ;clear  kernel[1]       (  2 clocks) 
		STS   Kernel+0x02        , R16                    ;clear  kernel[2]       (  2 clocks) 
		STS   Kernel+0x03        , R16                    ;clear  kernel[3]       (  2 clocks) 
		STS   Kernel+0x04        , R16                    ;clear  kernel[4]       (  2 clocks) 
		STS   Kernel+0x05        , R16                    ;clear  kernel[5]       (  2 clocks) 
		STS   Kernel+0x06        , R16                    ;clear  kernel[6]       (  2 clocks) 
		STS   Kernel+0x07        , R16                    ;clear  kernel[7]       (  2 clocks) 
		STS   Kernel+0x08        , R16                    ;clear  kernel[8]       (  2 clocks)
        STS   Kernel+0x09        , R16                    ;clear  kernel[9]       (  2 clocks) 
		LDI   R16                , KER_NTASK              ;load ntask to reg      (  1 clock ) 
		STS   Kernel+0x07        , R16                    ;store ntask            (  2 clocks) 
		LDI   R16                , 0x00                   ;store r16 with 0       (  1 clock ) 
		STS   SRTCCR0A           , R16                    ;clear TCCR0A           (  2 clocks) 
		STS   SRTCCR0B           , R16                    ;clear TCCR0B           (  2 clocks) 
		STS   SRTIMSK0           , R16                    ;clear TIMSK0           (  2 clocks) 
		STS   SRTIFR0            , R16                    ;clear TIFR0            (  2 clocks) 
		STS   SROCR0A            , R16                    ;clear OCR0A            (  2 clocks) 
		STS   SROCR0B            , R16                    ;clear OCR0B            (  2 clocks) 
		STS   SRTCNT0            , R16                    ;clear TCNT0            (  2 clocks) 
		LDI   R16                , KER_PRS                ;prescaler 64           (  1 clock ) 
		STS   SRTCCR0B           , R16                    ;set to TCCR0B          (  2 clocks)
		LDI   R16                , KER_RLD                ;reload value (130)     (  1 clock ) 
		STS   Kernel+0x08        , R16                    ;Kernel[5] reload value (  2 clocks) 
		STS   SRTCNT0            , R16                    ;set to TCNT0           (  2 clocks) 
		LDI   R16                , 0x01                   ;bit mask TOIE0         (  1 clock ) 
		STS   SRTIMSK0           , R16                    ;set to TIMSK0          (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================SysTick reg init end===================================;;





;;=================================SysTick value get start==================================;;
Kernel_SysTick_Val_Get:                                   ;total operation        ( 20 clocks)
        IN    R16                , IOSREG                 ;save SREG              (  1 clock ) 
        CLI                                               ;disable interrupts     (  1 clock ) 
		LDS   R18		         , Kernel+0x00            ;byte0 -> R18 (LSB)     (  2 clocks) 
		LDS   R19		         , Kernel+0x01            ;byte1 -> R19           (  2 clocks) 
		LDS   R20		         , Kernel+0x02            ;byte2 -> R20           (  2 clocks) 
		LDS   R21		         , Kernel+0x03            ;byte3 -> R21           (  2 clocks) 
		LDS   R22		         , Kernel+0x04            ;byte4 -> R22           (  2 clocks) 
		LDI   R23		         , 0x00                   ;byte5 -> R23           (  1 clocks) 
		LDI   R24		         , 0x00                   ;byte6 -> R24           (  1 clocks) 
		LDI   R25		         , 0x00                   ;byte7 -> R25 (MSB)     (  1 clocks) 
		OUT   IOSREG             , R16          		  ;restore SREG           (  1 clock )
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================SysTick value get end===================================;;





;;===============================interrupt status get start=================================;;
Kernel_Interrupt_Sts_Get:                                 ;total operation        ( 10 clocks)
        LDI   R24		         , 0x00                   ;clear R24              (  1 clock ) 
        IN    R16		         , IOSREG                 ;save SREG in R16       (  1 clock )
		SBRC  R16		         , 0x07                   ;check I flag->bit7     (  3 clocks)
		LDI   R24		         , 0x01                   ;set R24 to 1           (  1 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;================================interrupt status get end==================================;;



    

;;====================================Kernel Task0 Init=====================================;;
Kernel_Task0_Init:
        ;init stack for task0
		
		;save MSP
		IN    R2                 , IOSPL
		IN    R3                 , IOSPH
		
		;set stack for task0
		LDI   R16                , lo8(ker_stk0+KER_STZ)  ;fetch top SPL0,          (1 clock )
		LDI   R17                , hi8(ker_stk0+KER_STZ)  ;fetch top SPH0,          (1 clock )
		OUT   IOSPL              , R16                    ;load SPL                 (1 clock )
        OUT   IOSPH              , R17                    ;load SPH                 (1 clock )
		
		;psuh return address of task0
		LDI   R16                , lo8(Tasks_Task0)       ;fetch task address low   (1 clock )
		LDI   R17                , hi8(Tasks_Task0)       ;fetch task address high  (1 clock )
		LSR   R17                                         ;right shift high byte    (1 clock )
		ROR   R16                                         ;rotate right th carry    (1 clock )
		PUSH  R16                                         ;push word addr low       (2 clocks)
		PUSH  R17                                         ;push word addr high      (2 clocks) 
		
        KER_CONTEXT_SAVE
		
		;save PSP of task0
        IN    R16                , IOSPL                  ;read SPL                 (1 clock )
        IN    R17                , IOSPH                  ;read SPH                 (1 clock )
        STS   ker_stp + 0        , R16                    ;set stp of task0         (2 clocks) 
        STS   ker_stp + 1        , R17                    ;set stp of task0         (2 clocks) 
		
		;set task index -> 0
		LDI   R16                , 0x00                   ;set R16 to 0x00          (1 clock )
		STS   Kernel+0x06        , R16                    ;set task index = 0       (2 clocks) 
		
		;restore MSP
		OUT   IOSPL              , R2                     ;load SPL                 (1 clock )
        OUT   IOSPH              , R3                     ;load SPH                 (1 clock )
        RET                                               ;return from subroutine   (4 clocks) 



;;====================================Kernel Task1 Init=====================================;;
Kernel_Task1_Init:
        ;init stack for task1
		;save MSP
		;IN    R2                 , IOSPL
		;IN    R3                 , IOSPH
		
		;set stack for task1
		LDI   R16                , lo8(ker_stk1+KER_STZ)  ;fetch top SPL1,          (1 clock )
		LDI   R17                , hi8(ker_stk1+KER_STZ)  ;fetch top SPH1,          (1 clock )
		OUT   IOSPL              , R16                    ;load SPL                 (1 clock )
        OUT   IOSPH              , R17                    ;load SPH                 (1 clock )
		
		;psuh return address of task1
		LDI   R16                , lo8(Tasks_Task1)       ;fetch task address low   (1 clock )
		LDI   R17                , hi8(Tasks_Task1)       ;fetch task address high  (1 clock )
		LSR   R17                                         ;right shift high byte    (1 clock )
		ROR   R16                                         ;rotate right th carry    (1 clock )
		PUSH  R16                                         ;push word addr low       (2 clocks)
		PUSH  R17                                         ;push word addr high      (2 clocks) 
		
        ;KER_CNTXT_SV
		
		;save PSP of task1
        IN    R16                , IOSPL                  ;read SPL                 (1 clock )
        IN    R17                , IOSPH                  ;read SPH                 (1 clock )
        STS   ker_stp + 2        , R16                    ;set stp of task1         (2 clocks) 
        STS   ker_stp + 3        , R17                    ;set stp of task1         (2 clocks) 
		
		;set task index -> 1
		LDI   R16                , 0x01                   ;set R16 to 0x01          (1 clock )
		STS   Kernel+0x06        , R16                    ;set task index = 1       (2 clocks) 
		
		;restore MSP
		;OUT   IOSPL              , R2                     ;load SPL                 (1 clock )
        ;OUT   IOSPH              , R3                     ;load SPH                 (1 clock )
		SEI
        RET                                               ;return from subroutine   (4 clocks)  
