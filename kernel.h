
#ifndef  _KERNEL_H_
#define  _KERNEL_H_

#ifndef F_CPU
#define F_CPU 8000000
#endif

//define kernel tick rate in Hz
#define  KER_TR 1000

//preprossor calculations for internal use
#define KER_CLK                   (F_CPU / KER_TR)
#define KER_CALC_RLD(clk, div)    ((0xFF - ((clk) / (div))) & 0xFF)
#define KER_WITHIN_8BIT(clk, div) (((clk) / (div)) <= 0xFF)

#if KER_WITHIN_8BIT(KER_CLK,1)
  #define KER_RLD   KER_CALC_RLD(KER_CLK, 1)
  #define KER_PRS   0x01
#elif KER_WITHIN_8BIT(KER_CLK,8)
  #define KER_RLD   KER_CALC_RLD(KER_CLK, 8)
  #define KER_PRS   0x02
#elif KER_WITHIN_8BIT(KER_CLK,64)
  #define KER_RLD   KER_CALC_RLD(KER_CLK, 64)
  #define KER_PRS   0x03
#elif KER_WITHIN_8BIT(KER_CLK,256)
  #define KER_RLD   KER_CALC_RLD(KER_CLK, 256)
  #define KER_PRS   0x04
#elif KER_WITHIN_8BIT(KER_CLK,1024)
  #define KER_RLD   KER_CALC_RLD(KER_CLK, 1024)
  #define KER_PRS   0x05
#else 
  #warning "Kernel clock out of range"
#endif

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