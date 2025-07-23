

#include <avr/io.h>
#include <util/delay.h>
#include "debug.h"
#include "context.h"
#include "gpio.h"
#include "app.h"

int global_var = 10;

void App_Setup(void){
    
	Debug_Init(38400);
	GPIO_Init();
	
	
}

void App_Main_Loop(void){
    
    Debug_Tx_Text_NL("Hello");
	
	//PORTC|=(1<<5);
	
	asm volatile (
	  "LDS     R18,  0x28  \n\t"
	  "LDI     R19,  0x20  \n\t"
	  "ADD     R18,  R19   \n\t"
	  "STS     0x28, R18   \n\t"
	);
	
	_delay_ms(500);
	
	//PORTC&=~(1<<5);
	
	asm volatile (
	  "LDS     R18,  0x28   \n\t"
	  "LDI     R19,  0x20   \n\t"
	  "SUB     R18,  R19    \n\t"
	  "STS     0x28, R18    \n\t"
	);
    
	
}