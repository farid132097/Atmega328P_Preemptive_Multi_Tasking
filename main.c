


#include <avr/io.h>
#include <util/delay.h>
#include "systick.h"
#include "tasks.h"
#include "gpio.h"






int main(void){
  
  SysTick_Enable(1000);
  GPIO_Init();
  Task_Init();
  
  
while(1){
        
		Task_Mainloop_Hanlder();
		
	}
}
