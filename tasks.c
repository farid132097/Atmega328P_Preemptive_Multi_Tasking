

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"


//#define  CONSTANT_LAT_TEST

void Tasks_Task1(void){
  
  uint32_t vcc=0, temp;
  uint8_t  val[10];
  val[0]='v';
  val[1]='d';
  val[2]='d';
  val[3]=' ';
  val[8]='\r';
  val[9]='\n';

  DDRC |= (1<<1);
  Debug_Init(0);

  ADMUX  =0x00;
  ADCSRA =0x00;
  ADMUX |=(1<<REFS0)|(1<<MUX1) |(1<<MUX2) |(1<<MUX3);
  ADCSRA|=(1<<ADPS0)|(1<<ADPS2);
  ADCSRA|=(1<<ADEN) ;
  Kernel_Task_Sleep(5);
  
  while(1){
    
    PORTC ^= (1<<1);
    
    ADCSRA |= (1<<ADSC);
    while((ADCSRA & (1<<ADIF))==0);
    vcc = ADCW;
    ADCSRA |= (1<<ADIF);
    temp  = 1126400; //1024*1100
    temp /= vcc;
    vcc   = temp;

    val[4] = (vcc/1000)%10 + 48;
    val[5] = (vcc/100)%10 + 48;
    val[6] = (vcc/10)%10 + 48;
    val[7] = (vcc/1)%10 + 48;
    
    for(uint8_t i=0;i<10;i++){
      Debug_Tx_Byte( val[i] );
    }
    Kernel_Task_Sleep(10);
    
  }
}

void Tasks_Task2(void){
  
  DDRC |= (1<<2);

  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    PORTC ^= (1<<2);
    Kernel_Task_Constant_Latency(20);
    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('2');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

    PORTC ^= (1<<2);
    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('2');
    }
    Kernel_Task_Sleep(20);

    #endif
	
  }
}

void Tasks_Task3(void){
  
  DDRC |= (1<<3);

  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    PORTC ^= (1<<3);
    Kernel_Task_Constant_Latency(30);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('3');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

    PORTC ^= (1<<3);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('3');
    }
    Kernel_Task_Sleep(30);

    #endif
	
  }
}

void Tasks_Task4(void){
  
  DDRC |= (1<<4);

  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    PORTC ^= (1<<4);
    Kernel_Task_Constant_Latency(40);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('4');
    }
    Kernel_Task_Constant_Latency_Sleep(); 

    #else

    PORTC ^= (1<<4);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('4');
    }
    Kernel_Task_Sleep(40); 

    #endif
	
  }
}

void Tasks_Task5(void){
  
  DDRC |= (1<<5);

  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    PORTC ^= (1<<5);
    Kernel_Task_Constant_Latency(50);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('5');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

    PORTC ^= (1<<5);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('5');
    }
    Kernel_Task_Sleep(50); 

    #endif
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    Kernel_Task_Constant_Latency(60);
    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('6');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

    for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('6');
    }
    Kernel_Task_Sleep(60); 

    #endif
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){

    #ifdef CONSTANT_LAT_TEST

    Kernel_Task_Constant_Latency(70);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('7');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('7');
    }
    Kernel_Task_Sleep(70); 

    #endif
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){

    #ifdef CONSTANT_LAT_TEST

    Kernel_Task_Constant_Latency(80);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('8');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('8');
    }
    Kernel_Task_Sleep(80); 

    #endif
	
  }
}

void Tasks_Task9(void){
  
  Debug_Init(0);
  
  while(1){
    
    #ifdef CONSTANT_LAT_TEST

    Kernel_Task_Constant_Latency(90);
	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('9');
    }
    Kernel_Task_Constant_Latency_Sleep();

    #else

	  for(uint8_t i=0;i<200;i++){
      Debug_Tx_Byte('9');
    }
    Kernel_Task_Sleep(90); 

    #endif
	
  }
}

