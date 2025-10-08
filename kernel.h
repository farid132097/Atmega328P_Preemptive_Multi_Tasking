
/*
 * File          : kernel.h
 * Author        : MD. Faridul Islam (faridmdislam@gmail.com)
 * Description   : AVR kernel for bare-metal RTOS
 * Created       : Jul 27, 2025, 9:30 PM
 * Last Modified : Sep 02, 2025, 8:42 PM
 */



#ifndef  _KERNEL_H_
#define  _KERNEL_H_



//Enable or disable kernel debug via gpio
#define  KER_DBG_ENABLE

//Uncomment only one
//#define  KER_TIMER0_AS_TICK_SRC
//#define  KER_WDT_AS_TICK_SRC
#define  KER_TOSC_AS_TICK_SRC

//Uncomment only one
//#define  KER_WDT_TICK_16MS
//#define  KER_WDT_TICK_32MS
//#define  KER_WDT_TICK_64MS
//#define  KER_WDT_TICK_125MS
//#define  KER_WDT_TICK_250MS
//#define  KER_WDT_TICK_500MS
#define  KER_WDT_TICK_1000MS

//Uncomment if idle times need to be in sleep
#define  KER_IDLE_AS_SLEEP


//Do not change below section
#ifdef KER_TIMER0_AS_TICK_SRC
#define  KER_SLEEP_MODE_IDLE
#endif

#ifdef KER_WDT_AS_TICK_SRC
#define  KER_SLEEP_MODE_POWER_DOWN
#endif

#ifdef KER_TOSC_AS_TICK_SRC
#define  KER_SLEEP_MODE_POWER_SAVE
#endif


/*
 * Define IO address of the DDR & PORT. In standard header,
 * it defined as SRAM mapped address. Instructions associated
 * with SRAM mapped address requires higher clock cycle to execute.
 */
#ifdef   KER_DBG_ENABLE
#define  KER_DBG_DDR     0x0A   //DDRD IO address
#define  KER_DBG_PORT    0x0B   //PORTD IO address
#define  KER_DBG_PIN     0x05   //PORTD5 pin
#endif



#ifndef __ASSEMBLER__           //Only accessible via C
extern void      Kernel_SysTick_Reg_Init(uint8_t presclaer_reg, uint8_t reload_val);
extern uint64_t  Kernel_SysTick_Val_Get(void);
extern uint64_t  Kernel_SysTick_Val_Safely_Get(void);
extern uint8_t   Kernel_Interrupt_Sts_Get(void);
extern void      Kernel_Init(void);
extern void      Kernel_Task_Create(void (*func)(void), uint8_t priority);
extern void      Kernel_Start_Tasks(void);
extern void      Kernel_Task_Idle(void);
extern void      Kernel_Task_Sleep(uint16_t val);
extern void      Kernel_Task_Constant_Latency(uint16_t val);
extern void      Kernel_Task_Constant_Latency_Sleep(void);
extern uint16_t  Kernel_Task_Sleep_Time_Get(uint8_t task_id);
extern uint8_t   Kernel_Task_Status_Get(uint8_t task_id);
extern uint8_t   Kernel_NTask_Get(void);
extern uint8_t   Kernel_Task_Prio_Get(uint8_t task_id);
extern uint8_t   Kernel_Lowest_Prio_Get(void);
extern uint8_t   Kernel_High_Prio_Task_ID_Get(void);
extern uint8_t   Kernel_Abs_High_Prio_Task_ID_Get(void);
extern uint8_t   Kernel_CPU_Usage_Get(void);
#endif



#endif

