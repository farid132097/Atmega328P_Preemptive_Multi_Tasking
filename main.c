

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"



 


int main(void) {
    
	Kernel_Init();
	
	Kernel_Task_Create(Tasks_Task0,  4);
	Kernel_Task_Create(Tasks_Task1,  0);
	Kernel_Task_Create(Tasks_Task2,  1);
	Kernel_Task_Create(Tasks_Task3,  2);
	Kernel_Task_Create(Tasks_Task4,  3);
	
	//Kernel_Task_Create(Tasks_Task6,  3);
	//Kernel_Task_Create(Tasks_Task7,  1);
	//Kernel_Task_Create(Tasks_Task8,  7);
	
    /*
    Debug_Init(0);
    Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(0));
    Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(1));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(2));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(3));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(4));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(5));
    */

	Kernel_Start_Tasks();
	
	
    while(1){
		
     
    }
}
