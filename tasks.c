
#include <avr/io.h>
#include <util/delay.h>
#include "systick.h"
#include "tasks.h"
#include "gpio.h"


typedef struct task_t{
  volatile uint8_t TaskStatus;
  volatile uint8_t TaskPriority;
  void     (*TaskFunctions)(void);
}task_t;


enum{
  TASK_NOT_STARTED = 0,
  TASK_STARTED     = 1,
  TASK_COMPLETED   = 2
};



task_t Tasks[3];


volatile uint8_t CurrentTask  = 0;
volatile uint8_t PreviousTask = 0;


void Task_Init(void){
  Tasks[0].TaskStatus    = TASK_NOT_STARTED;
  Tasks[0].TaskPriority  = 0;
  Tasks[0].TaskFunctions = &Task0;
  
  Tasks[1].TaskStatus    = TASK_NOT_STARTED;
  Tasks[1].TaskPriority  = 1;
  Tasks[1].TaskFunctions = &Task1;
  
  Tasks[2].TaskStatus    = TASK_NOT_STARTED;
  Tasks[2].TaskPriority  = 2;
  Tasks[2].TaskFunctions = &Task2;
}

void Task_ISR_Hanlder(void){
  if(Tasks[CurrentTask].TaskStatus == TASK_COMPLETED){
    Tasks[CurrentTask].TaskStatus = TASK_NOT_STARTED;
  }
  CurrentTask++;
  if(CurrentTask>2){
    CurrentTask = 0;
  }
}

void Task_Mainloop_Hanlder(void){
  switch (Tasks[CurrentTask].TaskStatus){
    case TASK_NOT_STARTED:
	  Tasks[CurrentTask].TaskStatus = TASK_STARTED;
	  break;
	
	case TASK_STARTED:
	  Tasks[CurrentTask].TaskFunctions();
	  Tasks[CurrentTask].TaskStatus = TASK_COMPLETED;
	  break;
  }
}












void Task0(void){
  GPIO2_Set(1);
  _delay_us(50);
  GPIO2_Set(0);
}

void Task1(void){
  GPIO3_Set(1);
  _delay_us(100);
  GPIO3_Set(0);
}

void Task2(void){
  GPIO4_Set(1);
  _delay_us(200);
  GPIO4_Set(0);
}
