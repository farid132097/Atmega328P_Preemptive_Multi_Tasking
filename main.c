

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"






int main(void) {
    
	
	//Debug_Init();
	//Debug_Tx_Dbg();
	Kernel_SysTick_Reg_Init(1000);
	
	
	Kernel_Task_Init(Tasks_Task0, 0, 0);
	Kernel_Task_Init(Tasks_Task1, 1, 0);
	Kernel_Task_Init(Tasks_Task2, 2, 0);
	Kernel_Task_Start();
	
	
    while(1){
		
     
    }
}
