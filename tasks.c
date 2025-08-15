

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
  
  
  while(1){
    
	
  }
}

void Tasks_Task1(void){
  
  Debug_Init(0);
  DDRD |= (1<<6);
  
  
  while(1){
    
    PORTD ^= (1<<6);
	Debug_Print_TSK(1);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(10);
	
  }
}

void Tasks_Task2(void){
  
  Debug_Init(0);
  DDRD |= (1<<7);
  
  while(1){
    
    PORTD ^= (1<<7);
	Debug_Print_TSK(2);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(17);
	
  }
}

void Tasks_Task3(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(3);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(24);
	
  }
}

void Tasks_Task4(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(4);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(26);
	
  }
}

void Tasks_Task5(void){
  
  Debug_Init(0);
  
  while(1){
    
    Debug_Print_TSK(5);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(29);
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(6);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(31);
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(7);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(38);
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(8);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(42);
	
  }
}

void Tasks_Task9(void){
  
  Debug_Init(0);
  
  while(1){
    
	Debug_Print_TSK(9);
	Debug_Tx_Word_Conf(Kernel_Task_Sleep_Time_Get());
	Debug_Tx_Byte_Conf(Kernel_Task_Sts_Get());
	Kernel_Task_Sleep(44);
	
  }
}
