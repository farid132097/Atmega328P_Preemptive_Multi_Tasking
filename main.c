

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "systick.h"
#include "app.h"

int main(void) {
    
    //SysTick_Init(1000);
	App_Setup();
	
    while(1){
	 
        App_Main_Loop();
		
    }
}
