

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"
#include "debug.h"

void Tasks_Task1(void){
  
  uint32_t vcc=0, temp;
  uint8_t  val[4];

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

    val[0] = (vcc/1000)%10 + 48;
    val[1] = (vcc/100)%10 + 48;
    val[2] = (vcc/10)%10 + 48;
    val[3] = (vcc/1)%10 + 48;
    
    for(uint8_t i=0;i<4;i++){
      Debug_Tx_Byte( val[i] );
    }
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(10);
    
  }
}

void Tasks_Task2(void){
  
  DDRC |= (1<<2);

  Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<2);

	  /*Debug_Tx_Byte(2);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(2));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(2));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(20);
	
  }
}

void Tasks_Task3(void){
  
  DDRC |= (1<<3);

  Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<3);

	  /*Debug_Tx_Byte(3);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(3));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(3));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(30);
	
  }
}

void Tasks_Task4(void){
  
  DDRC |= (1<<4);

  Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<4);

	  /*Debug_Tx_Byte(4);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(4));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(4));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(40);
	
  }
}

void Tasks_Task5(void){
  
  DDRC |= (1<<5);

  Debug_Init(0);
  
  while(1){
    
    PORTC ^= (1<<5);

	  /*Debug_Tx_Byte(5);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(5));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(5));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(50);
	
  }
}

void Tasks_Task6(void){
  
  Debug_Init(0);
  
  while(1){
    
    /*Debug_Tx_Byte(6);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(6));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(6));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(60);
	
  }
}

void Tasks_Task7(void){
  
  Debug_Init(0);
  
  while(1){
    
	  /*Debug_Tx_Byte(7);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(7));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(7));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(70);
	
  }
}

void Tasks_Task8(void){
  
  Debug_Init(0);
  
  while(1){
    
	  /*Debug_Tx_Byte(8);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(8));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(8));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(80);
	
  }
}

void Tasks_Task9(void){
  
  Debug_Init(0);
  
  while(1){
    
	  /*Debug_Tx_Byte(9);
    Debug_Tx_Word(Kernel_Task_Sleep_Time_Get(9));
    Debug_Tx_Byte(0x20+Kernel_Task_Status_Get(9));
    Debug_Tx_Byte(0x10+Kernel_Abs_High_Prio_Task_ID_Get());
    Debug_Tx_Byte(Kernel_Lowest_Prio_Get());
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');*/
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()/10) + 48);
    Debug_Tx_Byte( (Kernel_CPU_Usage_Get()%10) + 48);
    Debug_Tx_Byte('%');
    Debug_Tx_Byte('\r');
    Debug_Tx_Byte('\n');
    Kernel_Task_Sleep(90);
	
  }
}

