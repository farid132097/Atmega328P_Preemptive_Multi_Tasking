

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"

int main(void) {
    
	DDRC |= (1<<5);
	PORTC&=~(1<<5);
    Kernel_SysTick_Reg_Init();
	
    while(1){
	 
        
		
    }
}
