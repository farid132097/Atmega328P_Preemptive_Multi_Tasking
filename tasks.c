

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"

void Tasks_Task0(void){
  
  Debug_Init(0);
  Kernel_Task_Sleep(5000);
  
  while(1){
    
	  Debug_Tx_Byte(0);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
    
  }
}

void Tasks_Task1(void){
  
  DDRD |= (1<<5);

  Debug_Init(0);
  Kernel_Task_Sleep(4000);
  
  while(1){
    
    PORTD ^= (1<<5);

	  Debug_Tx_Byte(1);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(2));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(2));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task2(void){
  
  DDRD |= (1<<6);

  Debug_Init(0);
  Kernel_Task_Sleep(3000);
  
  while(1){
    
    PORTD ^= (1<<6);

	  Debug_Tx_Byte(2);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(3));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(3));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task3(void){
  
  Debug_Init(0);
  Kernel_Task_Sleep(2000);
  
  while(1){
    
	  Debug_Tx_Byte(3);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(4));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(4));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task4(void){
  
  Debug_Init(0);
  Kernel_Task_Sleep(1000);
  
  while(1){
    
	
	  Debug_Tx_Byte(4);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(5));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(5));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task5(void){
  
  Debug_Init(0);
  
  while(1){
    
    Debug_Tx_Byte(5);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(6));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(6));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){
    
	  Debug_Tx_Byte(6);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(7));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(7));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){
    
	  Debug_Tx_Byte(7);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(8));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(8));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){
    
	  Debug_Tx_Byte(8);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(9));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(9));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_NTask_Get());
	
  }
}

