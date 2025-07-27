

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"

int main(void) {
    
	DDRD |= (1<<5);
	PORTD&=~(1<<5);
    Kernel_SysTick_Reg_Init(1000);
	
    while(1){
	 
        
		
    }
}
