

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"

//uint64_t cur = 0, next = 0;

int main(void) {
    
	
	Debug_Init();
    //Kernel_SysTick_Reg_Init(1000);
	Kernel_Task_Debug();
	//Kernel_Task0_Init();
	//Kernel_Task1_Init();
	//sei();
	
	
	
    while(1){
		
		/*
		while(next > cur){
		  cur = Kernel_SysTick_Val_Get();  
		}
		next  = Kernel_SysTick_Val_Get() + 50;
		Debug_Tx_Byte('A');
		*/
    }
}
