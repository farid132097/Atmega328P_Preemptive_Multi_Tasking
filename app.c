

#include <avr/io.h>
#include <util/delay.h>
#include "debug.h"
#include "context.h"
#include "gpio.h"
#include "app.h"

int global_var = 10;

void App_Setup(void){
    
	Debug_Init(38400);
	GPIO_Init();
	
	global_var++;
	Debug_Tx_Parameter_NL("before context save", global_var);
	
	Context_Save();
	
	global_var++;
	
	Debug_Tx_Parameter_NL("after context save", global_var);
	
	Context_Restore();
	
	Debug_Tx_Parameter_NL("after context restore", global_var);
	
	
}

void App_Main_Loop(void){
    
    Debug_Tx_Text_NL("Hello");
	_delay_ms(500);
    
}