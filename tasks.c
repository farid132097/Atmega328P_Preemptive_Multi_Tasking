

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"
#include "nrf24l01p.h"



void Tasks_Disable_Peripherals(void){
  
}


void Tasks_Task1(void){
  
  Debug_Init(0);
  
  while(1){
    
    Debug_Tx_Byte(1);
    Kernel_Task_Sleep(100/KER_TICK_TIME);
    
  }
}

void Tasks_Task2(void){
  
  Debug_Init(0);
  
  while(1){
    
    Debug_Tx_Byte(2);
    Kernel_Task_Sleep(200/KER_TICK_TIME);
    
  }
}

void Tasks_Task3(void){
  
  Debug_Init(0);
  
  while(1){
    
    Debug_Tx_Byte(3);
    Kernel_Task_Sleep(400/KER_TICK_TIME);
    
  }
}


