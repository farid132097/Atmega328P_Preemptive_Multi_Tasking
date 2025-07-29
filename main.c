

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"

int main(void) {
    
    Kernel_SysTick_Reg_Init(1000);
	Kernel_Test_Task0();
	
    while(1){
	    
        
		
    }
}
