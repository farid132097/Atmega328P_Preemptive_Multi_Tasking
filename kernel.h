
#ifndef  _KERNEL_H_
#define  _KERNEL_H_

#ifndef F_CPU
#define F_CPU 8000000
#endif

//define kernel tick rate in Hz
#define  KER_TR  1000

//define kernel tick rate in Hz
#define  KER_PRS 0x03

#define  KER_RLD 0x83

//enable/disable kernel debug via gpio
#define  KER_DBG_ENABLE


#ifdef   KER_DBG_ENABLE
/*
 * Define IO address of the DDR & PORT. In standard header,
 * it defined as SRAM mapped address. Instructions associated
 * with SRAM mapped address requires higher clock cycle to execute.
 */
#define  KER_DBG_DDR  0x0A   //DDRD IO address
#define  KER_DBG_PORT 0x0B   //PORTD IO address
#define  KER_DBG_PIN  0x05   //PORTD5 pin
#endif


#ifndef __ASSEMBLER__        //Only accessible via C
extern void      Kernel_SysTick_Reg_Init(uint16_t tick_rate);
extern uint64_t  Kernel_SysTick_Val_Get(void);
#endif

#endif