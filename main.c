

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "kernel.h"
#include "debug.h"
#include "tasks.h"



 

    
int main(void) {
    
	Kernel_Init();

	Kernel_Task_Create(Tasks_Task1,  3);
	Kernel_Task_Create(Tasks_Task2,  0);
	Kernel_Task_Create(Tasks_Task3,  2);
	Kernel_Task_Create(Tasks_Task4,  1);
	Kernel_Task_Create(Tasks_Task5,  4);
	
    Debug_Init(0);
    Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(0));
    Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(1));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(2));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(3));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(4));
	Debug_Tx_Byte_Conf(Kernel_Task_Prio_Get(5));
	
	Debug_Tx_Byte_Conf(Kernel_NTask_Get());
    Debug_Tx_Byte_Conf(Kernel_High_Prio_Task_ID_Get());
	Debug_Tx_Byte_Conf(Kernel_Abs_High_Prio_Task_ID_Get());
    
	Kernel_Start_Tasks();
	
	
    while(1){
		
        
    }
}
