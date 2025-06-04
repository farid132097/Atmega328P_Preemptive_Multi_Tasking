


#include <avr/io.h>
#include <util/delay.h>
#include "systick.h"
#include "states.h"
#include "tasks.h"
#include "gpio.h"



void task1(void) {
    
	
	
    while (1) {
        GPIO0_Toggle();
		_delay_ms(100);
    }
}

void task2(void) {
	
	
	
    while (1) {
        GPIO1_Toggle();
		_delay_ms(500);
    }
}


int main(void){
  
  SysTick_Enable(100);
  GPIO_Init();
  
  currentTask = &task1_tcb;
  nextTask = &task2_tcb;

  init_stack(&task1_tcb, task1_stack, task1);
  init_stack(&task2_tcb, task2_stack, task2);

  // Start first task by restoring its context
  RESTORE_CONTEXT1();
  
while(1){
        
		
		
	}
}
