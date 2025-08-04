
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


extern void      Kernel_SysTick_Reg_Init(uint16_t tick_rate);
extern uint64_t  Kernel_SysTick_Val_Get(void);
extern uint8_t   Kernel_Interrupt_Sts_Get(void);

extern void      Kernel_Test_Task0(void);
extern void      Kernel_Test_Task1(void);
extern void      Kernel_Test_Task2(void);

extern void      Kernel_Task0_Init(void);
extern void      Kernel_Task1_Init(void);
extern void      Kernel_Task2_Init(void);

extern void      Kernel_Task_Debug(void);
extern void      Kernel_Task_Debug1(void);

#endif

#endif

