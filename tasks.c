

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"

void Tasks_Task0(void){
  
  Debug_Init(0);
  
  uint16_t val = 80;
  
  
  while(1){
    
	  Debug_Tx_Byte(0);
	  //Debug_Tx_Word_Conf(val--);
    Debug_Tx_Byte(0x10+Kernel_High_Prio_Task_ID_Get());
    //Debug_Tx_Word(Kernel_Task_Sleep_Time_Get());
	  //Kernel_Task_Sleep(100);
	
  }
}

void Tasks_Task1(void){
  
  Debug_Init(0);
  DDRD |= (1<<5);
  uint16_t val = 100;
  
  while(1){
    
    PORTD ^= (1<<5);
	  Debug_Tx_Byte(1);
	  //Debug_Tx_Word_Conf(val--);
    Debug_Tx_Byte(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(5);
	
  }
}

void Tasks_Task2(void){
  
  Debug_Init(0);
  DDRD |= (1<<6);
  uint16_t val = 120;
  
  while(1){
    
    PORTD ^= (1<<6);
	  Debug_Tx_Byte(2);
    //Debug_Tx_Word_Conf(val--);
    Debug_Tx_Byte(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(17);
	
  }
}

void Tasks_Task3(void){
  
  Debug_Init(0);
  uint16_t val = 140;
  
  while(1){
    
	  Debug_Tx_Byte(3);
	  //Debug_Tx_Word_Conf(val--);
    Debug_Tx_Byte(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(24);
	
  }
}

void Tasks_Task4(void){
  
  Debug_Init(0);
  uint16_t val = 160;
  
  while(1){
    
	
	  Debug_Tx_Byte(4);
	  //Debug_Tx_Word_Conf(val--);
    Debug_Tx_Byte(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(26);
	
  }
}

void Tasks_Task5(void){
  
  Debug_Init(0);
  uint16_t val = 180;
  
  while(1){
    
    Debug_Tx_Byte_Conf(5);
	  //Debug_Tx_Word_Conf(val--);
    //Debug_Tx_Byte_Conf(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(29);
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  uint16_t val = 200;
  
  while(1){
    
	  Debug_Tx_Byte_Conf(6);
	  //Debug_Tx_Word_Conf(val--);
    //Debug_Tx_Byte_Conf(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(31);
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  uint16_t val = 220;
  
  while(1){
    
	  Debug_Tx_Byte_Conf(7);
	  //Debug_Tx_Word_Conf(val--);
    //Debug_Tx_Byte_Conf(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(38);
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  uint16_t val = 240;
  
  while(1){
    
	  Debug_Tx_Byte_Conf(8);
	  //Debug_Tx_Word_Conf(val--);
    //Debug_Tx_Byte_Conf(0x10+Kernel_High_Prio_Task_ID_Get());
	  //Kernel_Task_Sleep(42);
	
  }
}

