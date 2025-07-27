
#ifndef  _KERNEL_H_
#define  _KERNEL_H_

//define kernel tick rate in Hz
#define  KERNEL_TR 1000L

extern void  Kernel_SysTick_Reg_Init(uint16_t tick_rate);


#endif