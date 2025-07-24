

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "debug.h"
#include "context.h"
#include "tasks.h"
#include "gpio.h"
#include "app.h"



void App_Setup(void){
    
	Debug_Init(38400);
	GPIO_Init();
	
	cli();

    init_task(0, task0);
    init_task(1, task1);

    init_main_task();
	
	sei();
	
    Context_Restore();
	
}

void App_Main_Loop(void){
    
    
}