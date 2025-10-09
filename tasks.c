

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"

void Tasks_Task1(void){
  
  //turn off HDC1080 VDD
  DDRD |= (1<<2);
  PORTD&=~(1<<2);
  
  //Logic low to SCL & SDA
  DDRC |= (1<<4)|(1<<5);
  PORTC&=~((1<<4)|(1<<5));
  
  //Test with AVRUSB board
  //Pull-up for USB bus
  //DDRD &=~((1<<3)|(1<<2));
  //PORTD|= (1<<3)|(1<<2);
  //LED pin
  //DDRD |= (1<<4);
  //PORTD&=~(1<<4);

  //DDRC |= (1<<1);


  Debug_Init(0);
  
  while(1){
    
    /*Debug_Tx_Byte(TCCR2A);
    Debug_Tx_Byte(TCCR2B);
    Debug_Tx_Byte(TCNT2);
    Debug_Tx_Byte(TIMSK2);
    Debug_Tx_Byte(TIFR2);
    Debug_Tx_Byte(ASSR);*/
    Kernel_Task_Constant_Latency(60000/KER_TICK_TIME);

    //PORTC ^= (1<<1);
    
    //LED on
    PORTD|= (1<<4);

	  Debug_Tx_Byte(1);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte(i);
    }

    //LED off
    PORTD&=~(1<<4);

    //Kernel_Task_Sleep(10);
    Kernel_Task_Constant_Latency_Sleep();
    
  }
}

void Tasks_Task2(void){
  
  //DDRC |= (1<<2);

  Debug_Init(0);
  
  while(1){
    
    Kernel_Task_Constant_Latency(3000);

    //PORTC ^= (1<<2);

	  Debug_Tx_Byte(2);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(2));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(2));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());

    //Kernel_Task_Sleep(20);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task3(void){
  
  //DDRC |= (1<<3);

  Debug_Init(0);
  
  while(1){
    
    Kernel_Task_Constant_Latency(3000);

    //PORTC ^= (1<<3);

	  Debug_Tx_Byte(3);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(3));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(3));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(30);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task4(void){
  
  //DDRC |= (1<<4);

  Debug_Init(0);
  
  while(1){
    
    Kernel_Task_Constant_Latency(3000);

    //PORTC ^= (1<<4);

	  Debug_Tx_Byte(4);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(4));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(4));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(40);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task5(void){
  
  //DDRC |= (1<<5);

  Debug_Init(0);
  
  while(1){

    Kernel_Task_Constant_Latency(3000);
    
    //PORTC ^= (1<<5);

	  Debug_Tx_Byte(5);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(5));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(5));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(50);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){

    Kernel_Task_Constant_Latency(3000);
    
    Debug_Tx_Byte(6);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(6));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(6));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(60);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){

    Kernel_Task_Constant_Latency(3000);
    
	  Debug_Tx_Byte(7);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(7));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(7));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(70);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){

    Kernel_Task_Constant_Latency(3000);
    
	  Debug_Tx_Byte(8);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(8));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(8));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(80);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}

void Tasks_Task9(void){
  
  Debug_Init(0);
  
  while(1){

    Kernel_Task_Constant_Latency(3000);
    
	  Debug_Tx_Byte(9);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(1));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(1));
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(9));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(9));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    
    //Kernel_Task_Sleep(90);
    Kernel_Task_Constant_Latency_Sleep();
	
  }
}