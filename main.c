

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






int main(void) {
    
	
	Kernel_SysTick_Reg_Init(0x03, 0x82);
	
	Kernel_Task_Create(Tasks_Task0,  0);
	Kernel_Task_Create(Tasks_Task9,  0);
	Kernel_Task_Create(Tasks_Task2,  0);
	Kernel_Task_Create(Tasks_Task3,  0);
	Kernel_Task_Create(Tasks_Task4,  0);
	Kernel_Task_Create(Tasks_Task5,  0);
	Kernel_Task_Create(Tasks_Task6,  0);
	Kernel_Task_Create(Tasks_Task7,  0);
	Kernel_Task_Create(Tasks_Task8,  0);
	Kernel_Task_Create(Tasks_Task1,  0);
	
	Kernel_Start_Tasks();
	
	
    while(1){
		
     
    }
}
