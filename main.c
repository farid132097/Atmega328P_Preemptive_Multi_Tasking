

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






int main(void) {
    
	
	Kernel_SysTick_Reg_Init(0x03, 0x82);
	
	Kernel_Task_Init(Tasks_Task0, 0, 0);
	Kernel_Task_Init(Tasks_Task1, 1, 0);
	Kernel_Task_Init(Tasks_Task2, 2, 0);
	Kernel_Task_Init(Tasks_Task3, 3, 0);
	Kernel_Task_Init(Tasks_Task4, 4, 0);
	Kernel_Start_Tasks();
	
	
    while(1){
		
     
    }
}
