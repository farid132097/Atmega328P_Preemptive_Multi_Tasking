

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"


int main(void) {
    
	
	//Debug_Init();
	Kernel_SysTick_Reg_Init(1000);
	Kernel_Task_Init(&Tasks_Task0, 1, 0);
	Kernel_Task_Init(&Tasks_Task1, 2, 0);
	Kernel_Task_Start();
	
	//Kernel_Task0_Init();
	//Kernel_Task1_Init();
	
    while(1){
		
     
    }
}
