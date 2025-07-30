

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"

uint64_t cur = 0, next = 0;

int main(void) {
    
	DDRD |= (1<<5);
    Kernel_SysTick_Reg_Init(1000);
	Kernel_Task0_Init();
	Kernel_Task1_Init();
	
	//Kernel_Test_Task0();
	
    while(1){
	    
        
		/*
		while(next > cur){
		  cur = Kernel_SysTick_Val_Get();  
		}
		next  = Kernel_SysTick_Val_Get() + 50;
		PORTD ^= (1<<5);
		*/
		
    }
}
