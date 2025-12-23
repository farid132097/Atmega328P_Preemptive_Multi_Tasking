

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"



void Tasks_Disable_Peripherals(void){
  
}


void Tasks_Task1(void){
  
  uint8_t temp;
  DDRC  |= (1<<0);
  PORTC &=~(1<<0);
  
  while(1){
    
    temp = SREG;
    cli();
    PORTC |= (1<<0);
    _delay_us(2);
    PORTC &=~(1<<0);
    SREG = temp;
    Kernel_Task_Sleep(50/KER_TICK_TIME);
    
  }
}

void Tasks_Task2(void){
  
  uint8_t temp;
  DDRC  |= (1<<1);
  PORTC &=~(1<<1);
  
  while(1){
    
    temp = SREG;
    cli();
    PORTC |= (1<<1);
    _delay_us(2);
    PORTC &=~(1<<1);
    SREG = temp;
    Kernel_Task_Sleep(20/KER_TICK_TIME);
    
  }
}

void Tasks_Task3(void){
  
  uint8_t temp;
  DDRC  |= (1<<2);
  PORTC &=~(1<<2);
  
  while(1){
    
    temp = SREG;
    cli();
    PORTC |= (1<<2);
    _delay_us(2);
    PORTC &=~(1<<2);
    SREG = temp;
    Kernel_Task_Sleep(40/KER_TICK_TIME);
    
  }
}

