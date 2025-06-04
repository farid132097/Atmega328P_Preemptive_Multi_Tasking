

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "systick.h"
#include "states.h"
#include "gpio.h"

typedef struct systick_t{
  volatile int16_t Ticks;
  volatile int16_t OVFUpdateValue;
  volatile int16_t UpdateRate;
}systick_t;

systick_t SysTick = {
  .Ticks = 0,
  .OVFUpdateValue = 0,
  .UpdateRate = 0
};


void SysTick_Enable(uint16_t UpdateRateHz){
  uint8_t  clock_div_index = 0;
  uint16_t clock_div_factor[5] = {1, 8, 64, 256, 1024};
  int32_t  temp, curr_freq;

  temp = F_CPU;
  temp /= UpdateRateHz;
	
  clock_div_index = 0;
  curr_freq = temp;
	
  while( curr_freq > 0xFF ){
	curr_freq  = temp;
	curr_freq /= clock_div_factor[clock_div_index];
	clock_div_index++;
	if(clock_div_index == 5){
	  break;
	}
  }
	
  clock_div_index -= 1;
	
  TCCR0A = 0x00;
  TCCR0B = 0x00;
  TIMSK0 = 0x00;
  TIFR0  = 0x00;
  OCR0A  = 0x00;
  OCR0B  = 0x00;
  TCNT0  = 0x00;
  OCR0A  = 0x00;
  
  if(clock_div_index == 0){
	TCCR0B = (1<<CS00);
  }
  else if(clock_div_index == 1){
	TCCR0B = (1<<CS01);
  }
  else if(clock_div_index == 2){
	TCCR0B = (1<<CS00)|(1<<CS01);
  }
  else if(clock_div_index == 3){
	TCCR0B = (1<<CS02);
  }
  else if(clock_div_index == 4){
	TCCR0B = (1<<CS00)|(1<<CS02);
  }
  
  SysTick.OVFUpdateValue = (0xFF-curr_freq);
  TCNT0  = SysTick.OVFUpdateValue;
  TIMSK0 = (1<<TOIE0);
  sei();
  SysTick.UpdateRate = UpdateRateHz;
}




/*
ISR(TIMER0_OVF_vect){
  //TCNT0  = SysTick.OVFUpdateValue;
  //task_switch();
  GPIO0_Toggle();
  //GPIO1_Toggle();
}
*/
