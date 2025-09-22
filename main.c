

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"


    
int main(void) {
    
	Kernel_Init();

	Kernel_Task_Create(Tasks_Task1,  0);
	Kernel_Task_Create(Tasks_Task2,  3);
	Kernel_Task_Create(Tasks_Task3,  2);
	Kernel_Task_Create(Tasks_Task4,  1);
	Kernel_Task_Create(Tasks_Task5,  4);
	//Kernel_Task_Create(Tasks_Task6,  6);
	//Kernel_Task_Create(Tasks_Task7,  5);
	//Kernel_Task_Create(Tasks_Task8,  8);
	//Kernel_Task_Create(Tasks_Task9,  7);
	
	Kernel_Start_Tasks();
	
	
    while(1){
		
        
    }
}
