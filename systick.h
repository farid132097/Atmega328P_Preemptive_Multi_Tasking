
#ifndef _SYSTICK_H_
#define _SYSTICK_H_


void    SysTick_Struct_Init(void);
void    SysTick_Reg_Init(uint16_t UpdateRateHz);
void    SysTick_ISR_Executables(void);
void    SysTick_Init(uint16_t UpdateRateHz);



#endif

