

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"



void Tasks_Delay(uint16_t val){
  uint64_t curr = 0, next = 0;
  curr = Kernel_SysTick_Val_Get();
  next = curr + val;
  while( curr < next ){
    curr = Kernel_SysTick_Val_Get();
  }
}

void Tasks_Task0(void){
  
  Debug_Init();
  DDRD |= (1<<5);
  
  while(1){
    
    PORTD ^= (1<<5);
	Debug_Print_TSK0();
	Tasks_Delay(12);
	
  }
}

void Tasks_Task1(void){
  
  Debug_Init();
  DDRD |= (1<<6);
  
  while(1){
    
    PORTD ^= (1<<6);
	Debug_Print_TSK1();
	Tasks_Delay(41);
	
  }
}

void Tasks_Task2(void){
  
  Debug_Init();
  DDRD |= (1<<7);
  
  while(1){
    
    PORTD ^= (1<<7);
	Debug_Print_TSK2();
	Tasks_Delay(70);
	
  }
}