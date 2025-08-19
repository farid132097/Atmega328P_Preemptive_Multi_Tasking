

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






int main(void) {
    
	
	Kernel_SysTick_Reg_Init(0x03, 0x82);
	
	Kernel_Task_Create(Tasks_Task0,  0);
	Kernel_Task_Create(Tasks_Task2,  1);
	Kernel_Task_Create(Tasks_Task3,  2);
	Kernel_Task_Create(Tasks_Task4,  3);
	Kernel_Task_Create(Tasks_Task5,  4);
	Kernel_Task_Create(Tasks_Task6,  5);
	Kernel_Task_Create(Tasks_Task7,  6);
	Kernel_Task_Create(Tasks_Task8,  7);
	Kernel_Task_Create(Tasks_Task1,  8);
	
	Kernel_Start_Tasks();
	
	
    while(1){
		
     
    }
}
