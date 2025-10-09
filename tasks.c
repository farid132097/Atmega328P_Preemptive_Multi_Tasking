

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"
#include "nrf24l01p.h"

void Tasks_Disable_Peripherals(void){
  
}

//will be used with AVR USB V3.0 Board
void Tasks_Task1(void){
  
  //Pull-up for USB bus
  DDRD  &=~ ((1<<3)|(1<<2));
  PORTD |=  (1<<3)|(1<<2);
  
  //LED pin
  DDRD  |=  (1<<4);
  PORTD &=~ (1<<4);
  
  //VsenseEn
  DDRC  |=  (1<<1);
  PORTC &=~ (1<<1);
  
  Debug_Init(0);
  nRF24L01P_Init();
  
  while(1){
    
    //LED on
    PORTD|= (1<<4);

    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte(i);
    }

    //LED off
    PORTD&=~(1<<4);

    Kernel_Task_Sleep(5000/KER_TICK_TIME);
    
  }
}

void Tasks_Task2(void){
  
  //DDRC |= (1<<2);

  Debug_Init(0);
  
  while(1){
    

    //PORTC ^= (1<<2);

	  Debug_Tx_Byte(2);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(2));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(2));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());

    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task3(void){
  
  //DDRC |= (1<<3);

  Debug_Init(0);
  
  while(1){

    //PORTC ^= (1<<3);

	  Debug_Tx_Byte(3);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(3));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(3));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task4(void){
  
  //DDRC |= (1<<4);

  Debug_Init(0);
  
  while(1){

    //PORTC ^= (1<<4);

	  Debug_Tx_Byte(4);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(4));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(4));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task5(void){
  
  //DDRC |= (1<<5);

  Debug_Init(0);
  
  while(1){

    //PORTC ^= (1<<5);

	  Debug_Tx_Byte(5);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(5));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(5));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){

    Debug_Tx_Byte(6);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(6));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(6));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){

	  Debug_Tx_Byte(7);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(7));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(7));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){
    
	  Debug_Tx_Byte(8);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(8));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(8));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}

void Tasks_Task9(void){
  
  Debug_Init(0);
  
  while(1){
    
	  Debug_Tx_Byte(9);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(9));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(9));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    Kernel_Task_Sleep(7000/KER_TICK_TIME);
	
  }
}