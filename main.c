

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"



//#define  TEST_TASK



int main(void) {
    
	
	//Debug_Init();
	Kernel_SysTick_Reg_Init(1000);
	
	#ifdef TEST_TASK
	
	Kernel_Task_Init(Tasks_Task0, 0, 0);
	Kernel_Task_Init(Tasks_Task1, 1, 0);
	Kernel_Task_Start();
	
	#else
	
	Kernel_Task0_Init_Arg(Tasks_Task0, 0, 0);
	Kernel_Task1_Init_Arg(Tasks_Task1, 1, 0);
	Kernel_Start();
	
	#endif
	
	
    while(1){
		
     
    }
}
