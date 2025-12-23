

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"



void Tasks_Disable_Peripherals(void){
  
}


void Tasks_Task1(void){
  
  DDRC |= (1<<0);
  //Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<0);
    //Debug_Tx_Byte(1);
    Kernel_Task_Sleep(50/KER_TICK_TIME);
    
  }
}

void Tasks_Task2(void){
  
  DDRC |= (1<<1);
  //Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<1);
    //Debug_Tx_Byte(2);
    Kernel_Task_Sleep(20/KER_TICK_TIME);
    
  }
}

void Tasks_Task3(void){
  
  DDRC |= (1<<2);
  //Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<2);
    //Debug_Tx_Byte(3);
    Kernel_Task_Sleep(40/KER_TICK_TIME);
    
  }
}


