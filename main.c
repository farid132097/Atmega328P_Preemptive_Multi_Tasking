

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






int main(void) {
    
	Kernel_Init();
	//Kernel_SysTick_Reg_Init(0x03, 0x82);
	
	Kernel_Task_Create(Tasks_Task0,  6);
	Kernel_Task_Create(Tasks_Task1,  0);
	Kernel_Task_Create(Tasks_Task2,  8);
	Kernel_Task_Create(Tasks_Task3,  5);
	Kernel_Task_Create(Tasks_Task4,  4);
	Kernel_Task_Create(Tasks_Task5,  2);
	Kernel_Task_Create(Tasks_Task6,  3);
	Kernel_Task_Create(Tasks_Task7,  1);
	Kernel_Task_Create(Tasks_Task8,  7);
	
	Kernel_Start_Tasks();
	
	
    while(1){
		
     
    }
}
