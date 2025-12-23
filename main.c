

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"



int main(void) {
    
	Kernel_Init();
    
	Kernel_Task_Create(Tasks_Task1,  3);
	Kernel_Task_Create(Tasks_Task2,  2);
	Kernel_Task_Create(Tasks_Task3,  1);
	
	Kernel_Start_Tasks();
	
    while(1){
		
        
    }
}

