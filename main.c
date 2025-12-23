

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"



int main(void) {
    
	Kernel_Init();

	Kernel_Task_Create(Tasks_Task1,  5);
	Kernel_Task_Create(Tasks_Task2,  1);
	Kernel_Task_Create(Tasks_Task3,  2);
	
	Kernel_Start_Tasks();
	
    while(1){
		
        
    }
}

