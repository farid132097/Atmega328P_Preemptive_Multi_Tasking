
#ifndef  _KERNEL_H_
#define  _KERNEL_H_


//Enable/disable kernel debug via gpio
#define  KER_DBG_ENABLE



/*
 * Define IO address of the DDR & PORT. In standard header,
 * it defined as SRAM mapped address. Instructions associated
 * with SRAM mapped address requires higher clock cycle to execute.
 */
#ifdef   KER_DBG_ENABLE
#define  KER_DBG_DDR     0x04   //DDRB IO address
#define  KER_DBG_PORT    0x05   //PORTB IO address
#define  KER_DBG_PIN     0x01   //PORTB1 pin
#endif

#ifndef __ASSEMBLER__           //Only accessible via C


extern void      Kernel_SysTick_Reg_Init(uint8_t presclaer_reg, uint8_t reload_val);
extern uint64_t  Kernel_SysTick_Val_Get(void);
extern uint64_t  Kernel_SysTick_Val_Safely_Get(void);
extern uint8_t   Kernel_Interrupt_Sts_Get(void);
extern void      Kernel_Init(void);
extern void      Kernel_Task_Create(void (*func)(void), uint8_t priority);
extern void      Kernel_Start_Tasks(void);
extern void      Kernel_Task_Sleep(uint16_t val);
extern uint16_t  Kernel_Task_Sleep_Time_Get(void);
extern uint8_t   Kernel_Task_Sts_Get(void);
extern void      Kernel_Task_Yeild(void);

#endif

#endif