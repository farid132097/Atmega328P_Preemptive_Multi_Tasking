

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"

int64_t cur = 0, next = 0;

int main(void) {
    
	DDRD |= (1<<5);
    Kernel_SysTick_Reg_Init(1000);
	//Kernel_Task0_Init();
	//Kernel_Task1_Init();
	
	//Kernel_Test_Task0();
	
    while(1){
	    
        //cur   = Kernel_SysTick_Val_Get();
		//next  = cur + 200;
		
		//while(next < Kernel_SysTick_Val_Get());
		
		if(Kernel_SysTick_Val_Get() %70000 == 0){
		  PORTD ^= (1<<5);
		}
		
    }
}
