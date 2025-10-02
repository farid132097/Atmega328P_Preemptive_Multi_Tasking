
#include <avr/io.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"





;;============================define user address or macro starting=========================;; 
.equ     KER_TR ,         1000                            ;TickRate in Hz, not calculated      
.equ     KER_PRS,         0x03                            ;For prescaler 64, manually select   
.equ     KER_RLD,         0x82                            ;KER_RLD=0xFF-(F_CPU/KER_PRS/KER_TR) 
.equ     KER_STK_SZ,      160                             ;stack size in bytes for each task   
.equ     KER_MX_NTSK,     10                              ;max number of tasks                 
;;==============================define user address or macro end============================;; 





;;===============================define data offsets starting===============================;; 
.equ     OFB_TICK0,       0x00                            ;tick count byte0 offset from KerBase
.equ     OFB_TICK1,       0x01                            ;tick count byte1 offset from KerBase
.equ     OFB_TICK2,       0x02                            ;tick count byte2 offset from KerBase
.equ     OFB_TICK3,       0x03                            ;tick count byte3 offset from KerBase
.equ     OFB_TICK4,       0x04                            ;tick count byte4 offset from KerBase
.equ     OFB_PRS  ,       0x05                            ;prescaler offset from KerBase       
.equ     OFB_RLD  ,       0x06                            ;counter reload offset from KerBase  
.equ     OFB_TID  ,       0x07                            ;task id offset from KerBase         
.equ     OFB_NTSK ,       0x08                            ;ntask offset from KerBase           
.equ     OFB_LPR  ,       0x09                            ;lowest priority offset from KerBase 
.equ     OFB_PTID ,       0x0A                            ;prio task_id offset from KerBase    
.equ     OFB_UTC  ,       0x0B                            ;usage tick cnt offset from KerBase  
.equ     OFB_UATC ,       0x0C                            ;active tick cnt offset from KerBase 
.equ     OFB_USAGE,       0x0D                            ;cpu usage offset from KerBase       
.equ     OFM_MSPI ,       0x00                            ;msp index field offset from MSPZP   
.equ     OFM_MSPS ,       0x02                            ;msp starting offset from MSPZP      
;;==================================define data offsets end=================================;; 





;;===============================define system macro starting===============================;; 
.equ     TASK_BLOCKED,    0x00                            ;KerSchSts val=0                     
.equ     TASK_READY,      0x01                            ;KerSchSts val=1                     
.equ     TASK_EXECUTING,  0x02                            ;KerSchSts val=2                     
.equ     TASK_SUSPENDED,  0x03                            ;KerSchSts val=3                     
.equ     TASK_CONS_LAT,   0x04                            ;KerSchSts val=3, constant latency   
.equ     SCH_MODE_HANDLER,0x00                            ;handler mode in KER_SLP_TIME_MGNT   
.equ     SCH_MODE_THREAD, 0x01                            ;thread mode in KER_SLP_TIME_MGNT    
;;==================================define system macro end=================================;; 





;;===========================define hardware reg address starting===========================;; 
.equ     SRSREG  ,        0x5F                            ;manually defined SREG in SRAM       
.equ     SRSPH   ,        0x5E                            ;manually defined SPH in SRAM        
.equ     SRSPL   ,        0x5D                            ;manually defined SPL in SRAM        
.equ     SRTIMSK0,        0x6E                            ;manually defined TIMSK0 in SRAM     
.equ     SROCR0B ,        0x48                            ;manually defined OCR0B in SRAM      
.equ     SROCR0A ,        0x47                            ;manually defined OCR0A in SRAM      
.equ     SRTCNT0 ,        0x46                            ;manually defined TCNT0 in SRAM      
.equ     SRTCCR0B,        0x45                            ;manually defined TCCR0B in SRAM     
.equ     SRTCCR0A,        0x44                            ;manually defined TCCR0A in SRAM     
.equ     SRTIFR0 ,        0x35                            ;manually defined TIFR0 in SRAM      
.equ     IOOCR0B ,        0x28                            ;manually defined OCR0B in IO        
.equ     IOOCR0A ,        0x27                            ;manually defined OCR0A in IO        
.equ     IOTCNT0 ,        0x26                            ;manually defined TCNT0 in IO        
.equ     IOTCCR0B,        0x25                            ;manually defined TCCR0B in IO       
.equ     IOTCCR0A,        0x24                            ;manually defined TCCR0A in IO       
.equ     IOTIFR0 ,        0x15                            ;manually defined TIFR0 in IO        
.equ     IOSREG  ,        0x3F                            ;manually defined SREG in IO         
.equ     IOSPH   ,        0x3E                            ;manually defined SPH in IO          
.equ     IOSPL   ,        0x3D                            ;manually defined SPL in IO          
;;==============================define hardware reg address end=============================;; 





;;=============================define global variables starting=============================;; 
.section   .bss                                                                                
                                                                                               
.global    KerBase                                        ;declare global space for kernel     
KerBase:   .skip 14                                       ;see offset section                  
                                                                                               
.global    KerPSP                                         ;space for process stack pointers    
KerPSP:    .skip KER_MX_NTSK*2                            ;2 bytes for each task               
                                                                                               
.global    KerSSZ                                         ;stack for main stack pointers       
KerSSZ:    .skip 14                                       ;stack_ptr(2), MSPZPn(4)             
                                                                                               
.global    KerSchSts                                      ;space for scheduler status          
KerSchSts: .skip KER_MX_NTSK*1                            ;status(1)                           
                                                                                               
.global    KerSchPr                                       ;space for scheduler priority        
KerSchPr:  .skip KER_MX_NTSK*1                            ;priority(1)                         
                                                                                               
.global    KerSchSlp                                      ;space for task sleep                
KerSchSlp: .skip KER_MX_NTSK*2                            ;timing(2)                           
                                                                                               
.global    KerStack                                       ;space for stack                     
KerStack:  .skip KER_STK_SZ*KER_MX_NTSK                   ;KER_STK_SZ bytes for each task      
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
.global  Kernel_Task_Constant_Latency                                                          
.global  Kernel_Task_Constant_Latency_Sleep                                                    
.global  Kernel_Task_Sleep_Time_Get                                                            
.global  Kernel_Task_Status_Get                                                                
.global  Kernel_NTask_Get                                                                      
.global  Kernel_Task_Prio_Get                                                                  
.global  Kernel_Lowest_Prio_Get                                                                
.global  Kernel_High_Prio_Task_ID_Get                                                          
.global  Kernel_Abs_High_Prio_Task_ID_Get                                                      
.global  Kernel_CPU_Usage_Get                                                                  
;;================================define global functions end===============================;; 





;;============================debug pin operation init starting=============================;; 
;used registers          : R18, R19                                                            
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19                                                            
.macro  KER_TIMER_INIT                                    ;total 1.5uS @8MHz      ( 12 clocks) 
        LDS   R18		         , KerBase+OFB_PRS        ;load prescaler         (  2 clocks) 
		LDS   R19		         , KerBase+OFB_RLD        ;load reload val        (  2 clocks) 
		STS   SRTCCR0B           , R18                    ;prescaler-> TCCR0B     (  2 clocks) 
		STS   SRTCNT0            , R19                    ;reload val-> TCNT0     (  2 clocks) 
		LDI   R18                , 0x01                   ;bit mask TOIE0         (  1 clock ) 
		STS   SRTIMSK0           , R18                    ;set to TIMSK0          (  2 clocks) 
		SEI                                               ;force enable interrupt (  1 clock ) 
.endm                                                                                          
;;==============================debug pin operation init end================================;; 





;;============================debug pin operation init starting=============================;; 
;used registers          : None                                                                
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_DEBUG_PIN_INIT                                ;total 0.5uS @8MHz      (  4 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear port bit         (  2 clocks) 
		SBI   KER_DBG_DDR        , KER_DBG_PIN            ;set bit in DDR         (  2 clocks) 
		#endif                                                                                 
.endm                                                                                          
;;==============================debug pin operation init end================================;; 





;;===========================debug pin operation set starting===============================;; 
;used registers          : None                                                                
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_DEBUG_PIN_SET                                 ;total 0.25uS @8MHz     (  2 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
        SBI   KER_DBG_PORT       , KER_DBG_PIN            ;set gpio               (  2 clocks) 
		#endif                                                                                 
.endm                                                                                          
;;==============================debug pin operation set end=================================;; 





;;===========================debug pin operation clear starting=============================;; 
;used registers          : None                                                                
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_DEBUG_PIN_CLEAR                               ;total 0.25uS @8MHz     (  2 clocks) 
        #ifdef KER_DBG_ENABLE                                                                  
		CBI   KER_DBG_PORT       , KER_DBG_PIN            ;clear gpio             (  2 clocks) 
		#endif                                                                                 
.endm                                                                                          
;;==============================debug pin operation clear end===============================;; 





;;==============================reload counter value starting===============================;; 
;used registers          : R18                                                                 
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18                                                                 
.macro  KER_COUNTER_RELOAD                                ;total 0.5uS @8MHz      (  4 clocks) 
        LDS   R18                , KerBase+OFB_RLD        ;load reload value      (  2 clocks) 
		STS   SRTCNT0            , R18                    ;Set value to TCNT0     (  2 clocks) 
.endm                                                                                          
;;=================================reload counter value end=================================;; 





;;=================================save r0 & sreg starting==================================;; 
;used registers          : R0                                                                  
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_SAVE_R0_SREG                                  ;total 0.63uS @8MHz     (  5 clocks) 
        PUSH  R0                                          ;save R0                (  2 clocks) 
		IN    R0                 , IOSREG                 ;load SREG              (  1 clock ) 
		PUSH  R0                                          ;save SREG              (  2 clocks) 
.endm                                                                                          
;;====================================save r0 & sreg end====================================;; 





;;===============================save r0, sreg & cli starting===============================;; 
;used registers          : R0                                                                  
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_SAVE_R0_CLI_SREG                              ;total 0.75uS @8MHz     (  6 clocks) 
        PUSH  R0                                          ;push R0                (  2 clocks) 
		IN    R0                 , IOSREG                 ;save SREG              (  1 clock ) 
		CLI                                               ;clear interrupt        (  1 clock ) 
		PUSH  R0                                          ;save SREG              (  2 clocks) 
.endm                                                                                          
;;=================================save r0, sreg & cli end==================================;; 





;;===================================save r1~r31 starting===================================;; 
;used registers          : R1~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_SAVE_R1_R31                                   ;total 7.88uS @8MHz     ( 63 clocks) 
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
;;======================================save r1~r31 end=====================================;; 





;;==============================context save handler starting===============================;; 
;used registers          : R0~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_CONTEXT_SAVE_HANDLER                          ;total 8.5uS @8MHz      ( 68 clocks) 
        KER_SAVE_R0_SREG                                  ;save r0, sreg          (  5 clocks) 
        KER_SAVE_R1_R31                                   ;save r1~r31            ( 63 clocks) 
.endm                                                                                          
;;=================================context save handler end=================================;; 





;;===============================context save thread starting===============================;; 
;used registers          : R0~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_CONTEXT_SAVE_THREAD                           ;total 8.63uS @8MHz     ( 69 clocks) 
        KER_SAVE_R0_CLI_SREG                              ;save r0, sreg          (  6 clocks) 
        KER_SAVE_R1_R31                                   ;save r1~r31            ( 63 clocks) 
.endm                                                                                          
;;==================================context save thread end=================================;; 






;;================================restore r0 & sreg starting================================;; 
;used registers          : R0                                                                  
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_RESTORE_R0_SREG                               ;total 0.63uS @8MHz     (  5 clocks) 
        POP   R0                                          ;fetch SREG             (  2 clocks) 
		OUT   IOSREG             , R0                     ;load SREG              (  1 clock ) 
		POP   R0                                          ;restore R0             (  2 clocks) 
.endm                                                                                          
;;==================================restore r0 & sreg end===================================;; 





;;==============================restore r0, sreg & sei starting=============================;; 
;used registers          : R0                                                                  
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_RESTORE_R0_SREG_SEI                           ;total 0.75uS @8MHz     (  6 clocks) 
        POP   R0                                          ;fetch SREG             (  2 clocks) 
		OUT   IOSREG             , R0                     ;load SREG              (  1 clock ) 
		POP   R0                                          ;restore R0             (  2 clocks) 
		SEI                                               ;enable interrupt       (  1 clock ) 
.endm                                                                                          
;;===============================restore r0, sreg & sei end=================================;; 





;;=================================restore r1~r31 starting==================================;; 
;used registers          : R1~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_RESTORE_R1_R31                                ;total 8.38uS @8MHz     ( 62 clocks) 
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
.endm                                                                                          
;;====================================restore r1~r31 end====================================;; 





;;=============================context restore handler starting=============================;; 
;used registers          : R0~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_CONTEXT_RESTORE_HANDLER                       ;total 8.38uS @8MHz     ( 67 clocks) 
        KER_RESTORE_R1_R31                                ;restore r1~r31         ( 62 clocks) 
		KER_RESTORE_R0_SREG                               ;restore r0, sreg       (  5 clocks) 
.endm                                                                                          
;;===============================context restore handler end================================;; 





;;=============================context restore thread starting==============================;; 
;used registers          : R0~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
.macro  KER_CONTEXT_RESTORE_THREAD                        ;total 8.75uS @8MHz     ( 68 clocks) 
        KER_RESTORE_R1_R31                                ;restore r1~r31         ( 62 clocks) 
		KER_RESTORE_R0_SREG_SEI                           ;restore r0, sreg       (  6 clocks) 
.endm                                                                                          
;;================================context restore thread end================================;; 





;;==============================fetch current task id starting==============================;; 
;used registers          : R20                                                                 
;arg registers           : None                                                                
;return registers        : R20 (Current task id)                                               
;unsafe access registers : R20                                                                 
.macro  KER_FETCH_CURR_TID                                ;total 0.25uS @8MHz     (  2 clocks) 
        LDS   R20                , KerBase+OFB_TID        ;fetch task_id          (  2 clocks) 
.endm                                                                                          
;;================================fetch current task id end=================================;; 





;;==================================fetch ntask starting====================================;; 
;used registers          : R21                                                                 
;arg registers           : None                                                                
;return registers        : R21 (ntask)                                                         
;unsafe access registers : R21                                                                 
.macro  KER_FETCH_NTASK                                   ;total 0.25uS @8MHz     (  2 clocks) 
        LDS   R21                , KerBase+OFB_NTSK       ;fetch task_id          (  2 clocks) 
.endm                                                                                          
;;====================================fetch ntask end=======================================;; 





;;=========================calculate offset addr in words starting==========================;; 
;used registers          : R18, R30(ZL), R31(ZH)                                               
;arg registers           : R30(ZL), R31(ZH)                                                    
;return registers        : R30(ZL), R31(ZH)                                                    
;unsafe access registers : R18, R30(ZL), R31(ZH)                                               
.macro  KER_CALC_ADDR_OFF_WORD                            ;total 0.75uS @8MHz     (  6 clocks) 
        LDS   R18                , KerBase+OFB_TID        ;fetch task_id          (  2 clocks) 
		LSL   R18                                         ;left shift to multiply (  1 clock ) 
		ADD   ZL                 , R18                    ;add offset to array    (  1 clock ) 
		LDI   R18                , 0x00                   ;clear for carry prop   (  1 clock ) 
		ADC   ZH                 , R18                    ;add carry if any       (  1 clock ) 
.endm                                                                                          
;;=============================calculate offset addr in words end===========================;; 





;;=========================calculate offset addr in bytes starting==========================;; 
;used registers          : R18, R30(ZL), R31(ZH)                                               
;arg registers           : R30(ZL), R31(ZH)                                                    
;return registers        : R30(ZL), R31(ZH)                                                    
;unsafe access registers : R18, R30(ZL), R31(ZH)                                               
.macro  KER_CALC_ADDR_OFF_BYTES                           ;total 0.63uS @8MHz     (  5 clocks) 
        LDS   R18                , KerBase+OFB_TID        ;fetch task_id          (  2 clocks) 
		ADD   ZL                 , R18                    ;add offset to array    (  1 clock ) 
		LDI   R18                , 0x00                   ;clear for carry prop   (  1 clock ) 
		ADC   ZH                 , R18                    ;add carry if any       (  1 clock ) 
.endm                                                                                          
;;=============================calculate offset addr in bytes end===========================;; 





;;===============================save current task sp starting==============================;; 
;used registers          : R18, R19, R30(ZL), R31(ZH)                                          
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19, R30(ZL), R31(ZH)                                          
.macro  KER_SAVE_CURR_TASK_SP                             ;total 1.75uS @8MHz     ( 14 clocks) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		KER_CALC_ADDR_OFF_WORD                            ;calc offset            (  6 clocks) 
		IN    R18                , IOSPL                  ;fetch SPL0             (  1 clock ) 
		IN    R19                , IOSPH                  ;fetch SPH0             (  1 clock ) 
		STD   Z+0                , R18                    ;store SPL at ZP+0      (  2 clocks) 
		STD   Z+1                , R19                    ;store SPH at ZP+1      (  2 clocks) 
.endm                                                                                          
;;================================save current task sp end==================================;; 





;;==============================load next task id starting==================================;; 
;used registers          : R18, R19                                                            
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19                                                            
.macro  KER_LOAD_NEXT_TASK_ID                             ;total 1.63uS @8MHz     ( 13 clocks) 
		LDS   R18                , KerBase+OFB_TID        ;fetch task_id          (  2 clocks) 
		INC   R18                                         ;increment task_id      (  1 clock ) 
		LDS   R19                , KerBase+OFB_NTSK       ;load ntask             (  2 clocks) 
	_MOD_CONT\@:                                          ;use local label                     
	    CP    R18                , R19                    ;compare R17 with R16   (  1 clock ) 
		BRLO  _MOD_DONE\@                                 ;if R16<R17, done       (  2 clocks) 
		SUB   R18                , R19                    ;subtract R17 from R16  (  1 clock ) 
		RJMP  _MOD_CONT\@                                 ;go to loop start       (  2 clocks) 
	_MOD_DONE\@:                                          ;use local label                     
	    STS   KerBase+OFB_TID    , R18                    ;save task_id%ntask     (  2 clocks) 
.endm                                                                                          
;;=================================load next task id end====================================;; 





;;==============================increment tick counter starting=============================;; 
;used registers          : R18, R19                                                            
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19                                                            
.macro  KER_TICK_INCREMENT                                ;total 3.38uS @8MHz     ( 26 clocks) 
		LDS   R18                , KerBase+OFB_TICK0      ;load Byte0             (  2 clocks) 
		INC   R18                                         ;add 1 with Byte0       (  1 clock ) 
		STS   KerBase+OFB_TICK0  , R18                    ;set Byte0              (  2 clocks) 
		LDI   R19                , 0x00                   ;clear reg              (  1 clock ) 
		LDS   R18                , KerBase+OFB_TICK1      ;load Byte1             (  2 clocks) 
		ADC   R18                , R19                    ;add carry with Byte1   (  1 clock ) 
		STS   KerBase+OFB_TICK1  , R18                    ;set Byte1              (  2 clocks) 
		LDS   R18                , KerBase+OFB_TICK2      ;load Byte2             (  2 clocks) 
		ADC   R18                , R19                    ;add carry with Byte2   (  1 clock ) 
		STS   KerBase+OFB_TICK2  , R18                    ;set Byte2              (  2 clocks) 
		LDS   R18                , KerBase+OFB_TICK3      ;load Byte3             (  2 clocks) 
		ADC   R18                , R19                    ;add carry with Byte3   (  1 clock ) 
		STS   KerBase+OFB_TICK3  , R18                    ;set Byte3              (  2 clocks) 
		LDS   R18                , KerBase+OFB_TICK4      ;load Byte4             (  2 clocks) 
		ADC   R18                , R19                    ;add carry with Byte4   (  1 clock ) 
		STS   KerBase+OFB_TICK4  , R18                    ;set Byte4              (  2 clocks) 
.endm                                                                                          
;;=================================increment tick counter end===============================;; 





;;==============================load task id & sp starting==================================;; 
;used registers          : R18, R19, R30(ZL), R31(ZH)                                          
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19, R30(ZL), R31(ZH)                                          
.macro  KER_LOAD_TASK_ID_AND_SP                           ;total 1.75uS @8MHz     ( 14 clocks) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		KER_CALC_ADDR_OFF_WORD                            ;calc offset            (  6 clocks) 
		LDD   R18                , Z+0                    ;load SPL at ZP         (  2 clocks) 
		LDD   R19                , Z+1                    ;load SPH at ZP         (  2 clocks) 
		OUT   IOSPL              , R18                    ;load SPL0              (  1 clock ) 
		OUT   IOSPH              , R19                    ;load SPH0              (  1 clock ) 
.endm                                                                                          
;;=================================load task id & sp end====================================;; 





;;================================push msp & zp starting====================================;; 
;used registers          : R18, R19, R26(XL), R27(XH), R30(ZL), R31(ZH)                        
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19, R26(XL), R27(XH), R30(ZL), R31(ZH)                        
.macro  KER_PUSH_MSP_ZP                                   ;total 2.25uS @8MHz     ( 18 clocks) 
        LDS   XL                 , KerSSZ+OFM_MSPI+0      ;load val low           (  2 clocks) 
		LDS   XH                 , KerSSZ+OFM_MSPI+1      ;load val high          (  2 clocks) 
		IN    R18                , IOSPL                  ;copy                   (  1 clock ) 
		IN    R19                , IOSPH                  ;copy                   (  1 clock ) 
		ST    X+                 , R18                    ;store main SPL         (  2 clocks) 
        ST    X+                 , R19                    ;store main SPH         (  2 clocks) 
		ST    X+                 , ZL                     ;store main ZL          (  2 clocks) 
		ST    X+                 , ZH                     ;store main ZH          (  2 clocks) 
		STS   KerSSZ+OFM_MSPI+0  , XL                     ;store new index        (  2 clocks) 
		STS   KerSSZ+OFM_MSPI+1  , XH                     ;store new index        (  2 clocks) 
.endm                                                                                          
;;===================================push msp & zp end======================================;; 





;;=================================pop msp & zp starting====================================;; 
;used registers          : R18, R19, R26(XL), R27(XH), R30(ZL), R31(ZH)                        
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19, R26(XL), R27(XH), R30(ZL), R31(ZH)                        
.macro  KER_POP_MSP_ZP                                    ;total 2.25uS @8MHz     ( 18 clocks) 
		LDS   XL                 , KerSSZ+OFM_MSPI+0      ;load val low           (  2 clocks) 
		LDS   XH                 , KerSSZ+OFM_MSPI+1      ;load val high          (  2 clocks) 
		LD    ZH                 , -X                     ;load ZH                (  2 clocks) 
		LD    ZL                 , -X                     ;load ZL                (  2 clocks) 
		LD    R19                , -X                     ;load main SPH          (  2 clocks) 
		LD    R18                , -X                     ;load main SPL          (  2 clocks) 
		OUT   IOSPL              , R18                    ;set SPL                (  1 clock ) 
		OUT   IOSPH              , R19                    ;set SPH                (  1 clock ) 
		STS   KerSSZ+OFM_MSPI+0  , XL                     ;store new index        (  2 clocks) 
		STS   KerSSZ+OFM_MSPI+1  , XH                     ;store new index        (  2 clocks) 
.endm                                                                                          
;;====================================pop msp & zp end======================================;; 





;;============================sleep timeout management starting=============================;; 
;used registers          : R18, R19, R20, R24, R30(ZL), R31(ZH)                                
;arg registers           : R24 (SCH_MODE_HANDLER/SCH_MODE_THREAD)                              
;return registers        : R24 (READY/BLOCKED/EXECUTING/SUSPENDED/CONS_LAT)                    
;unsafe access registers : R18, R19, R20, R24, R30(ZL), R31(ZH)                                
.macro  KER_SLP_TIME_MGNT                                 ;total 5.50uS @8MHz     ( 44 clocks) 
		LDI   ZL                 , lo8(KerSchSlp)         ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSlp)         ;fetch base pos high    (  1 clock ) 
		KER_CALC_ADDR_OFF_WORD                            ;calc offset            (  6 clocks) 
		;fetch current value from ram, if val=0, skip decrement                                
        LDD   R18                , Z+0                    ;load val low byte      (  2 clocks) 
		LDD   R19                , Z+1                    ;load val high byte     (  2 clocks) 
		MOV   R20                , R18                    ;copy                   (  1 clock ) 
		OR    R20                , R19                    ;or high & low bytes    (  1 clock ) 
		BREQ  _VAL_NULL\@                                 ;val=0, save sts        (  2 clocks) 
        CPI   R24                , SCH_MODE_THREAD        ;if arg=1, thread mode  (  1 clock ) 
		BREQ  _VAL_NOT_NULL\@                             ;no need to dec val     (  2 clocks) 
		;R19:R18 contains 16 bit sleep timer val, decrease val by 1                            
		LDI   R20                , 0x01                   ;set val 1              (  1 clock ) 
        SUB   R18                , R20                    ;subtract low byte      (  1 clock ) 
		LDI   R20                , 0x00                   ;clear                  (  1 clock ) 
		SBC   R19                , R20                    ;subtract carry if any  (  1 clock ) 
		;store new value                                                                       
		STD   Z+0                , R18                    ;store low byte         (  2 clocks) 
		STD   Z+1                , R19                    ;store low byte         (  2 clocks) 
		MOV   R20                , R18                    ;copy                   (  1 clock ) 
		OR    R20                , R19                    ;or high & low bytes    (  1 clock ) 
		BRNE  _VAL_NOT_NULL\@                             ;val!=0                 (  2 clocks) 
	_VAL_NULL\@:                                                                               
	    ;find ram address for status                                                           
	    LDI   ZL                 , lo8(KerSchSts)         ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;fetch base pos high    (  1 clock ) 
        KER_CALC_ADDR_OFF_BYTES                           ;calc offset            (  5 clocks) 
		;update flag as task is ready                                                          
		LDI   R24                , TASK_READY             ;set TASK_READY         (  1 clock ) 
		ST    Z                  , R24                    ;update flag            (  2 clocks) 
		RJMP  _EXIT_SLP_TIME\@                            ;jump to exit           (  2 clocks) 
    _VAL_NOT_NULL\@:                                                                           
	    LDI   ZL                 , lo8(KerSchSts)         ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;fetch base pos high    (  1 clock ) 
        KER_CALC_ADDR_OFF_BYTES                           ;calc offset            (  5 clocks) 
	    LD    R24                , Z                      ;return sts             (  2 clocks) 
    _EXIT_SLP_TIME\@:                                                                          
.endm                                                                                          
;;============================sleep timeout management end==================================;; 





;;============================current task priority starting================================;; 
;used registers          : R18, R24, R30(ZL), R31(ZH)                                          
;arg registers           : None                                                                
;return registers        : R24 (Current task priority)                                         
;unsafe access registers : R18, R24, R30(ZL), R31(ZH)                                          
.macro  KER_CURR_TASK_PRIO                                ;total 1.13uS @8MHz     (  9 clocks) 
		LDI    ZL                , lo8(KerSchPr)          ;load low addr          (  1 clock ) 
		LDI    ZH                , hi8(KerSchPr)          ;load high addr         (  1 clock ) 
		LDI    R18               , 0x00                   ;clear reg, for carry   (  1 clock ) 
		LDS    R24               , KerBase+OFB_TID        ;load task id           (  2 clocks) 
        ADD    ZL                , R24                    ;add low addr           (  1 clock ) 
		ADC    ZH                , R18                    ;add carry if any       (  1 clock ) 
		LD     R24               , Z                      ;load current tid prio  (  2 clocks) 
.endm                                                                                          
;;==============================current task priority end===================================;; 





;;================================run scheduler starting====================================;; 
;used registers          : R18, R19, R20, R24, R25, R30(ZL), R31(ZH)                           
;arg registers           : R24 (SCH_MODE_HANDLER/SCH_MODE_THREAD)                              
;return registers        : None                                                                
;unsafe access registers : R18, R19, R20, R24, R25, R30(ZL), R31(ZH)                           
.macro  KER_RUN_SCHEDULER                                 ;total 11.5uS @8MHz     ( 92 clocks) 
		LDI    R18               , 0xFF                   ;set 0xff               (  1 clock ) 
		STS    KerBase+OFB_LPR   , R18                    ;lowest priority        (  2 clocks) 
		LDI    R18               , 0x00                   ;start from 0           (  1 clock ) 
		STS    KerBase+OFB_PTID  , R18                    ;highest prio tid=0     (  2 clocks) 
		MOV    R15               , R24                    ;copy sch mode          (  1 clock ) 
	_KER_SCH_LOOP\@:                                                                           
	    ;store task id to run from KER_DEC_SLP_TIMEOUT                                         
		STS    KerBase+OFB_TID   , R18                    ;store task id          (  2 clocks) 
        ;sleep time decrement, update ready/blocked status                                     
		MOV    R24               , R15                    ;restore sch mode       (  1 clock ) 
		KER_SLP_TIME_MGNT                                 ;update return vars     ( 44 clocks) 
        CPI    R24               , TASK_READY             ;compare                (  1 clock ) 
        BREQ   _KER_CALC_PRIO\@                           ;calc priority if ready (  2 clocks) 
		CPI    R24               , TASK_CONS_LAT          ;compare                (  1 clock ) 
        BREQ   _KER_CALC_PRIO\@                           ;calc priority if c_lat (  2 clocks) 
        RJMP   _KER_SCH_NEXT\@                            ;skip if !ready|c_lat   (  2 clocks) 
	_KER_CALC_PRIO\@:
		KER_CURR_TASK_PRIO                                ;get task prio ->R24    (  9 clocks) 
        ;compare current task priority with lowest priority found so far                       
		LDS    R18               , KerBase+OFB_LPR        ;load lowest priority   (  2 clocks) 
		CP     R24               , R18                    ;compare                (  1 clock ) 
		BRSH   _KER_SCH_NEXT\@                            ;if prio>=lowest prio   (  2 clocks) 
		;found new lowest priority                                                             
		STS    KerBase+OFB_LPR   , R24                    ;save lowest priority   (  2 clocks) 
		LDS    R18               , KerBase+OFB_TID        ;load task id           (  2 clocks) 
		STS    KerBase+OFB_PTID  , R18                    ;save lowest priority   (  2 clocks) 
                                                                                               
    _KER_SCH_NEXT\@:                                                                           
	    LDS    R18               , KerBase+OFB_TID        ;load task id           (  2 clocks) 
		INC    R18                                        ;increment by 1         (  1 clock ) 
		LDS    R19               , KerBase+OFB_NTSK       ;load ntask             (  2 clocks) 
		CP     R18               , R19                    ;compare with ntask     (  2 clocks) 
		BRSH   _KER_SCH_EXIT\@                            ;if task_id>=ntask      (  2 clocks) 
		RJMP   _KER_SCH_LOOP\@                            ;jump to entry          (  2 clocks) 
	_KER_SCH_EXIT\@:                                                                           
        LDS    R18               , KerBase+OFB_PTID       ;load high prio task id (  2 clocks) 
		STS    KerBase+OFB_TID   , R18                    ;for test only          (  2 clocks) 
.endm                                                                                          
;;===================================run scheduler end======================================;; 





;;================================calc cpu usage starting===================================;; 
;used registers          : R18, R19                                                            
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R18, R19                                                            
.macro  KER_CPU_USAGE                                     ;total 3.25uS @8MHz     ( 26 clocks) 
        ;check if current target task is idle task or not                                      
        LDS    R18               , KerBase+OFB_TID        ;load target task_id    (  2 clocks) 
		TST    R18                                        ;check if idle task     (  1 clock ) 
		BREQ   _KER_USG_TICK\@                            ;task_id=idle, skip     (  2 clocks) 
		LDS    R18               , KerBase+OFB_UATC       ;load active tick cnt   (  2 clocks) 
		INC    R18                                        ;inc active tick cnt    (  1 clock ) 
		STS    KerBase+OFB_UATC  , R18                    ;store new val          (  2 clocks) 
	_KER_USG_TICK\@:                                                                           
		LDS    R18               , KerBase+OFB_UTC        ;load usage tick cnt    (  2 clocks) 
		INC    R18                                        ;increment tick cnt     (  1 clock ) 
		CPI    R18               , 100                    ;compare with 100       (  1 clock ) 
		BRLO   _KER_USG_UTC_SV\@                          ;val<100, save new val  (  2 clocks) 
		LDI    R18               , 0x00                   ;val>=100, roll back    (  1 clock ) 
		LDS    R19               , KerBase+OFB_UATC       ;load active tick cnt   (  2 clocks) 
		STS    KerBase+OFB_USAGE , R19                    ;store usage            (  2 clocks) 
		LDI    R19               , 0x00                   ;clear reg              (  1 clock ) 
		STS    KerBase+OFB_UATC  , R19                    ;clear active tick cnt  (  2 clocks) 
	_KER_USG_UTC_SV\@:                                                                         
		STS    KerBase+OFB_UTC   , R18                    ;store new val          (  2 clocks) 
.endm                                                                                          
;;===================================calc cpu usage end=====================================;; 





;;=================================ISR execution starting===================================;; 
.global  __vector_16                                                                           
    __vector_16:                                          ;total 40.00uS @8MHz    (320 clocks) 
	    KER_DEBUG_PIN_SET                                 ;debug pin set          (  2 clocks) 
        KER_CONTEXT_SAVE_HANDLER                          ;save context           ( 68 clocks) 
		KER_SAVE_CURR_TASK_SP                             ;save current task SP   ( 14 clocks) 
		KER_COUNTER_RELOAD                                ;counter reload         (  4 clocks) 
		KER_TICK_INCREMENT                                ;increment tick counter ( 26 clocks) 
		LDI    R24               , SCH_MODE_HANDLER       ;set sch mode           (  1 clock ) 
		KER_RUN_SCHEDULER                                 ;run scheduler          ( 92 clocks) 
		KER_CPU_USAGE                                     ;calc cpu usage         ( 26 clocks) 
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 14 clocks) 
		KER_CONTEXT_RESTORE_HANDLER                       ;restore context        ( 67 clocks) 
	    KER_DEBUG_PIN_CLEAR                               ;debug pin clear        (  2 clocks) 
		RETI                                              ;return from interrupt  (  4 clocks) 
;;====================================ISR execution end=====================================;; 





;;================================SysTick reg init starting=================================;; 
;used registers          : R18, R19, R22, R24, R26(XL), R27(XH), R30(ZL), R31(ZH)              
;arg registers           : R24(Prescaler), R22(ReloadVal)                                      
;return registers        : None                                                                
;unsafe access registers : R18, R19, R22, R24, R26(XL), R27(XH), R30(ZL), R31(ZH)              
Kernel_SysTick_Reg_Init:                                  ;total 11.5uS @8MHz     ( 92 clocks) 
        CLI                                               ;disable global int     (  1 clock ) 
		KER_DEBUG_PIN_INIT                                ;debug pin init         (  4 clocks) 
        KER_PUSH_MSP_ZP                                   ;push MSP and ZP        ( 18 clocks) 
		;clear reg                                                                             
		LDI   R18                , 0x00                   ;set 0x00 to R18        (  1 clock ) 
		;clear tick counter                                                                    
		STS   KerBase+OFB_TICK0  , R18                    ;clear  KerBase[0]      (  2 clocks) 
		STS   KerBase+OFB_TICK1  , R18                    ;clear  KerBase[1]      (  2 clocks) 
		STS   KerBase+OFB_TICK2  , R18                    ;clear  KerBase[2]      (  2 clocks) 
		STS   KerBase+OFB_TICK3  , R18                    ;clear  KerBase[3]      (  2 clocks) 
		STS   KerBase+OFB_TICK4  , R18                    ;clear  KerBase[4]      (  2 clocks) 
		;clear system registers                                                                
		STS   KerBase+OFB_PRS    , R18                    ;clear  KerBase[5]      (  2 clocks) 
		STS   KerBase+OFB_RLD    , R18                    ;clear  KerBase[6]      (  2 clocks) 
		STS   KerBase+OFB_TID    , R18                    ;clear  KerBase[7]      (  2 clocks) 
		STS   KerBase+OFB_NTSK   , R18                    ;clear  KerBase[8]      (  2 clocks) 
		STS   KerBase+OFB_LPR    , R18                    ;clear  KerBase[9]      (  2 clocks) 
        STS   KerBase+OFB_PTID   , R18                    ;clear  KerBase[10]     (  2 clocks) 
		STS   KerBase+OFB_UTC    , R18                    ;clear  KerBase[11]     (  2 clocks) 
		STS   KerBase+OFB_UATC   , R18                    ;clear  KerBase[12]     (  2 clocks) 
		STS   KerBase+OFB_USAGE  , R18                    ;clear  KerBase[13]     (  2 clocks) 
		;clear all timer registers                                                             
		STS   SRTCCR0A           , R18                    ;clear TCCR0A           (  2 clocks) 
		STS   SRTCCR0B           , R18                    ;clear TCCR0B           (  2 clocks) 
		STS   SRTIMSK0           , R18                    ;clear TIMSK0           (  2 clocks) 
		STS   SRTIFR0            , R18                    ;clear TIFR0            (  2 clocks) 
		STS   SROCR0A            , R18                    ;clear OCR0A            (  2 clocks) 
		STS   SROCR0B            , R18                    ;clear OCR0B            (  2 clocks) 
		STS   SRTCNT0            , R18                    ;clear TCNT0            (  2 clocks) 
		;save values for future use                                                            
		STS   KerBase+OFB_PRS    , R24                    ;KerBase[5] prescaler   (  2 clocks) 
		STS   KerBase+OFB_RLD    , R22                    ;KerBase[6] reload val  (  2 clocks) 
        KER_POP_MSP_ZP                                    ;pop MSP and ZP         ( 18 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================SysTick reg init end===================================;; 





;;===============================kernel task create starting================================;; 
;used registers          : R16, R17, R22, R24, R25, R26(XL), R27(XH), R30(ZL), R31(ZH)         
;arg registers           : R25:R24(FuncPtr), R22(TaskPriority)                                 
;return registers        : None                                                                
;unsafe access registers : R16, R17, R22, R24, R25, R26(XL), R27(XH), R30(ZL), R31(ZH)         
Kernel_Task_Create:                                       ;total 20.38uS @8MHz    (163 clocks) 
        KER_PUSH_MSP_ZP                                   ;push MSP and ZP        ( 18 clocks) 
		;set priority to KerSchPr+task_id                                                      
		LDI   ZL                 , lo8(KerSchPr)          ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchPr)          ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_BYTES                           ;calc offset            (  5 clocks) 
		ST    Z                  , R22                    ;save priority          (  2 clocks) 
		;set task status to KerSchSts+task_id                                                  
		LDI   ZL                 , lo8(KerSchSts)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_BYTES                           ;calc offset            (  5 clocks) 
		LDI   R16                , TASK_READY             ;set status as ready    (  1 clock ) 
		ST    Z                  , R16                    ;save status            (  2 clocks) 
		;stack pointer for current task (KerStack + KER_STK_SZ*(task_id+1) - 1) ->stack top    
		LDS   R16                , KerBase+OFB_TID        ;load task_id           (  2 clocks) 
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
		KER_CONTEXT_SAVE_HANDLER                          ;save context           ( 68 clocks) 
		;read stack pointer of current task (necessary when restore)                           
		IN    R17                , IOSPL                  ;read SPL               (  1 clock ) 
        IN    R18                , IOSPH                  ;read SPH               (  1 clock ) 
		;calculate the address where current task's SP will be stored and store SP             
		LDS   R16                , KerBase+OFB_TID        ;load task_id           (  2 clocks) 
		MOV   R19                , R16                    ;copy task_id           (  1 clock ) 
		LSL   R19                                         ;left shift to multiply (  1 clock ) 
		LDI   ZL                 , lo8(KerPSP)            ;fetch base pos low     (  1 clock ) 
		LDI   ZH                 , hi8(KerPSP)            ;fetch base pos high    (  1 clock ) 
		ADD   ZL                 , R19                    ;add offset to array    (  1 clock ) 
		LDI   R16                , 0x00                   ;clear reg              (  1 clock ) 
		ADC   ZH                 , R16                    ;add carry if any       (  1 clock ) 
		ST    Z+                 , R17                    ;SPL at KerPSp+offset   (  2 clocks) 
		ST    Z                  , R18                    ;SPH at KerPSp+offset   (  2 clocks) 
		;increment task_id                                                                     
		LDS   R16                , KerBase+OFB_TID        ;load task_id           (  2 clocks) 
		INC   R16                                         ;increment task_id      (  1 clock ) 
		STS   KerBase+OFB_TID    , R16                    ;store task_id          (  2 clocks) 
		;increment ntask                                                                       
		LDS   R16                , KerBase+OFB_NTSK       ;load ntask             (  2 clocks) 
		INC   R16                                         ;increment ntask        (  1 clock ) 
		STS   KerBase+OFB_NTSK   , R16                    ;store ntask            (  2 clocks) 
		KER_POP_MSP_ZP                                    ;pop MSP and ZP         ( 18 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================kernel task create end==================================;; 





;;=================================kernel start tasks starting==============================;; 
;used registers          : R0~R31                                                              
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R16, R17, R18, R24, R25, R30(ZL), R31(ZH)                           
Kernel_Start_Tasks:                                       ;total 11.38uS @8MHz    ( 91 clocks) 
		LDI    R24               , SCH_MODE_THREAD        ;set sch mode           (  1 clock ) 
		KER_RUN_SCHEDULER                                 ;run scheduler          ( 92 clocks) 
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 14 clocks) 
		KER_CONTEXT_RESTORE_THREAD                        ;restore context        ( 68 clocks) 
		;config timer for system tick                                                          
		KER_TIMER_INIT                                    ;init timer, int enable ( 12 clocks) 
		;execute return to jump to highest priority task                                       
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================kernel start tasks end==================================;; 





;;===================================kernel init starting===================================;; 
;used registers          : R1, R16, R17, R22, R24, R25, R26(XL), R27(XH), R30(ZL), R31(ZH)     
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : R1, R16, R17, R22, R24, R25, R26(XL), R27(XH), R30(ZL), R31(ZH)     
Kernel_Init:                                              ;total 38.63uS @8MHz    (309 clocks) 
		CLR   R1                                          ;gcc expects            (  1 clock ) 
        ;store stack top (for MSP) addr to KerSSZ+OFM_MSPI0:1                                  
		LDI   R16                , lo8(KerSSZ+OFM_MSPS)   ;load low address       (  1 clock ) 
		LDI   R17                , hi8(KerSSZ+OFM_MSPS)   ;load high address      (  1 clock ) 
        STS   KerSSZ+OFM_MSPI+0  , R16                    ;set mspi to stack top  (  2 clocks) 
		STS   KerSSZ+OFM_MSPI+1  , R17                    ;set mspi to stack top  (  2 clocks) 
		KER_PUSH_MSP_ZP                                   ;push MSP and ZP        ( 18 clocks) 
		;init timer for kernel                                                                 
		LDI   R24                , 0x03                   ;set prescaler          (  1 clock ) 
		LDI   R22                , 0x82                   ;set reload val         (  1 clock ) 
		CALL  Kernel_SysTick_Reg_Init                     ;init timer             ( 92 clocks) 
		;create idle task at task_id 0, priority 0xFF (lowest)                                 
		LDI   R24                , lo8(Kernel_Task_Idle)  ;load func addr low     (  1 clock ) 
		LDI   R25                , hi8(Kernel_Task_Idle)  ;load func addr high    (  1 clock ) 
		LSR   R25                                         ;right shift to divide  (  1 clock ) 
		ROR   R24                                         ;rotate right th carry  (  1 clock ) 
		LDI   R22                , 0xFF                   ;set max val            (  1 clock ) 
		CALL  Kernel_Task_Create                          ;init idle task         (163 clocks) 
		KER_POP_MSP_ZP                                    ;pop MSP and ZP         ( 18 clocks) 
		;execute return to jump to task0, pushed while task init                               
		RET                                               ;return from subroutine (  4 clocks) 
;;======================================kernel init end=====================================;; 





;;=================================kernel idle task starting================================;; 
;used registers          : None                                                                
;arg registers           : None                                                                
;return registers        : None                                                                
;unsafe access registers : None                                                                
Kernel_Task_Idle:                                         ;total 0.5uS @8MHz      (  4 clocks) 
    _IDLE_LOOP:                                           ;forever loop                        
		RJMP  _IDLE_LOOP                                  ;return from subroutine (  4 clocks) 
;;==================================kernel idle task end====================================;; 





;;================================kernel task sleep starting================================;; 
;used registers          : R0~R31                                                              
;arg registers           : R25:R24(SleepTime)                                                  
;return registers        : None                                                                
;unsafe access registers : R16, R17, R18, R24, R25, R30(ZL), R31(ZH)                           
Kernel_Task_Sleep:                                        ;total 35.5uS @8MHz     (284 clocks) 
        ;save current context                                                                  
        KER_CONTEXT_SAVE_THREAD                           ;save context           ( 69 clocks) 
		KER_SAVE_CURR_TASK_SP                             ;save current task SP   ( 14 clocks) 
		;create next task wakeup time (args R25:R24)                                           
		LDI   ZL                 , lo8(KerSchSlp)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSlp)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_WORD                            ;offset calc            (  6 clocks) 
		STD   Z+0                , R24                    ;save sleep time low    (  2 clocks) 
		STD   Z+1                , R25                    ;save sleep time high   (  2 clocks) 
		;update task scheduler status as blocked                                               
		LDI   ZL                 , lo8(KerSchSts)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_BYTES                           ;offset calc            (  5 clocks) 
        LDI   R16                , TASK_BLOCKED           ;block task until cnt=0 (  1 clock ) 
		STD   Z+0                , R16                    ;save block flag        (  2 clocks) 
		;run scheduler, load next task sp, restore context                                     
		LDI    R24               , SCH_MODE_THREAD        ;set sch mode           (  1 clock ) 
		KER_RUN_SCHEDULER                                 ;run scheduler          ( 92 clocks) 
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 14 clocks) 
		KER_CONTEXT_RESTORE_THREAD                        ;restore context        ( 68 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;=================================kernel task sleep end====================================;; 





;;========================kernel task constant latency starting=============================;; 
;used registers          : R16, R24, R25, R30(ZL), R31(ZH)                                     
;arg registers           : R25:R24(SleepTime)                                                  
;return registers        : None                                                                
;unsafe access registers : R16, R24, R25, R30(ZL), R31(ZH)                                     
Kernel_Task_Constant_Latency:                             ;total 35.5uS @8MHz     ( 26 clocks) 
		;create next task wakeup time (args R25:R24)                                           
		CLI                                               ;disable interrupt      (  1 clock ) 
		LDI   ZL                 , lo8(KerSchSlp)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSlp)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_WORD                            ;offset calc            (  6 clocks) 
		STD   Z+0                , R24                    ;save sleep time low    (  2 clocks) 
		STD   Z+1                , R25                    ;save sleep time high   (  2 clocks) 
		;update task scheduler status as constant latency                                      
		LDI   ZL                 , lo8(KerSchSts)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_BYTES                           ;offset calc            (  5 clocks) 
        LDI   R16                , TASK_CONS_LAT          ;save as cons_lat       (  1 clock ) 
		STD   Z+0                , R16                    ;save block flag        (  2 clocks) 
		SEI                                               ;enable interrupt       (  1 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;=============================kernel task constant latency end=============================;; 





;;=======================kernel task constant latency sleep starting========================;; 
;used registers          : R16, R24, R25, R30(ZL), R31(ZH)                                     
;arg registers           : R25:R24(SleepTime)                                                  
;return registers        : None                                                                
;unsafe access registers : R16, R24, R25, R30(ZL), R31(ZH)                                     
Kernel_Task_Constant_Latency_Sleep:                       ;total 35.5uS @8MHz     ( 26 clocks) 
		;save current context                                                                  
        KER_CONTEXT_SAVE_THREAD                           ;save context           ( 69 clocks) 
		KER_SAVE_CURR_TASK_SP                             ;save current task SP   ( 14 clocks) 
		;update task scheduler status as blocked                                               
		LDI   ZL                 , lo8(KerSchSts)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;load high byte         (  1 clock ) 
		KER_CALC_ADDR_OFF_BYTES                           ;offset calc            (  5 clocks) 
        LDI   R16                , TASK_BLOCKED           ;blocked until cnt=0    (  1 clock ) 
		STD   Z+0                , R16                    ;save block flag        (  2 clocks) 
		;run scheduler, load next task sp, restore context                                     
		LDI    R24               , SCH_MODE_THREAD        ;set sch mode           (  1 clock ) 
		KER_RUN_SCHEDULER                                 ;run scheduler          ( 92 clocks) 
		KER_LOAD_TASK_ID_AND_SP                           ;load next task id, SP  ( 14 clocks) 
		KER_CONTEXT_RESTORE_THREAD                        ;restore context        ( 68 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;=============================kernel task constant latency end=============================;; 





;;===========================kernel task sleep time get starting============================;; 
;used registers          : R16, R24, R25, R30(ZL), R31(ZH)                                     
;arg registers           : R24(TaskID)                                                         
;return registers        : R25:R24(SleepTime)                                                  
;unsafe access registers : R16, R24, R25, R30(ZL), R31(ZH)                                     
Kernel_Task_Sleep_Time_Get:                               ;total 1.88uS @8MHz     ( 15 clocks) 
		MOV   R16                , R24                    ;copy                   (  1 clock ) 
		LSL   R16                                         ;x2                     (  1 clock ) 
		LDI   ZL                 , lo8(KerSchSlp)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSlp)         ;load high byte         (  1 clock ) 
		ADD   ZL                 , R16                    ;add low bytes          (  1 clock ) 
		LDI   R16                , 0x00                   ;load 0                 (  1 clock ) 
		ADC   ZH                 , R16                    ;add high byte+carry    (  1 clock ) 
		LDD   R24                , Z+0                    ;load sleep time        (  2 clocks) 
		LDD   R25                , Z+1                    ;load sleep time        (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;==============================kernel task sleep time get end==============================;; 





;;==============================kernel task status get starting=============================;; 
;used registers          : R16, R24, R30(ZL), R31(ZH)                                          
;arg registers           : R24(TaskID)                                                         
;return registers        : R24(TaskSts)                                                        
;unsafe access registers : R16, R24, R30(ZL), R31(ZH)                                          
Kernel_Task_Status_Get:                                   ;total 1.50uS @8MHz     ( 12 clocks) 
		MOV   R16                , R24                    ;copy                   (  1 clock ) 
		LDI   ZL                 , lo8(KerSchSts)         ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchSts)         ;load high byte         (  1 clock ) 
		ADD   ZL                 , R16                    ;add low bytes          (  1 clock ) 
		LDI   R16                , 0x00                   ;load 0                 (  1 clock ) 
		ADC   ZH                 , R16                    ;add high byte+carry    (  1 clock ) 
		LD    R24                , Z                      ;load task status       (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;================================kernel task status get end================================;; 





;;================================kernel ntask get starting=================================;; 
;used registers          : R24                                                                 
;arg registers           : None                                                                
;return registers        : R24(NTask)                                                          
;unsafe access registers : R24                                                                 
Kernel_NTask_Get:                                         ;total 0.75uS @8MHz     (  6 clocks) 
		LDS   R24                 , KerBase+OFB_NTSK      ;load ntask             (  2 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===================================kernel ntask get end===================================;; 





;;=============================kernel task priority get starting============================;; 
;used registers          : R16, R24, R30(ZL), R31(ZH)                                          
;arg registers           : R24(TaskID)                                                         
;return registers        : R24(TaskPriority)                                                   
;unsafe access registers : R16, R24, R30(ZL), R31(ZH)                                          
Kernel_Task_Prio_Get:                                     ;total 1.50uS @8MHz     ( 12 clocks) 
		;get priority of the task id, arg (task_id->R24), return R24                           
		MOV   R16                , R24                    ;copy task_id           (  1 clock ) 
		LDI   ZL                 , lo8(KerSchPr)          ;load low byte          (  1 clock ) 
		LDI   ZH                 , hi8(KerSchPr)          ;load high byte         (  1 clock ) 
		ADD   ZL                 , R16                    ;add low bytes          (  1 clock ) 
		LDI   R16                , 0x00                   ;clear reg              (  1 clock ) 
		ADC   ZH                 , R16                    ;add high byte+carry    (  1 clock ) 
		LD    R24                , Z                      ;load priority          (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;================================kernel task priority get end==============================;; 





;;============================kernel lowest priority get starting===========================;; 
;used registers          : R24                                                                 
;arg registers           : None                                                                
;return registers        : R24(LowestPriorityVal)                                              
;unsafe access registers : R24                                                                 
Kernel_Lowest_Prio_Get:                                   ;total 0.75uS @8MHz     (  6 clocks) 
		LDS   R24                , KerBase+OFB_LPR        ;load lowest priority   (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;===============================kernel lowest priority get end=============================;; 





;;===========================kernel high priority task id starting==========================;; 
;used registers          : R24                                                                 
;arg registers           : None                                                                
;return registers        : R24(HighstPriorityTaskID)->UserTaskID (Excluding Idle Task)         
;unsafe access registers : R24                                                                 
Kernel_High_Prio_Task_ID_Get:                             ;total 0.88uS @8MHz     (  7 clocks) 
		LDS   R24                , KerBase+OFB_PTID       ;load priority tak_id   (  2 clocks) 
		DEC   R24                                         ;decrement by 1         (  1 clock ) 
		RET                                               ;return from subroutine (  4 clocks) 
;;==============================kernel high priority task id end============================;; 





;;=========================kernel abs high priority task id starting========================;; 
;used registers          : R24                                                                 
;arg registers           : None                                                                
;return registers        : R24(HighstPriorityTaskID)->AbsoluteTaskID (Including Idle Task)     
;unsafe access registers : R24                                                                 
Kernel_Abs_High_Prio_Task_ID_Get:                         ;total 0.75uS @8MHz     (  6 clocks) 
		LDS   R24                , KerBase+OFB_PTID       ;load priority tak_id   (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;============================kernel abs high priority task id end==========================;; 





;;================================kernel cpu usage get starting=============================;; 
;used registers          : R24                                                                 
;arg registers           : None                                                                
;return registers        : R24(CurrentCpuUsage)->In percentage                                 
;unsafe access registers : R24                                                                 
Kernel_CPU_Usage_Get:                                     ;total 0.75uS @8MHz     (  6 clocks) 
		;get cpu usage, return R24                                                             
		LDS   R24                , KerBase+OFB_USAGE      ;load cpu usage         (  2 clocks) 
		RET                                               ;return from subroutine (  4 clocks) 
;;==================================kernel cpu usage get end================================;; 