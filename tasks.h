

#ifndef  _TASKS_H_
#define  _TASKS_H_


#ifndef __ASSEMBLER__    //Only accessible via C

void     Tasks_Disable_Peripherals(void);
void     Tasks_Task1(void);
void     Tasks_Task2(void);
void     Tasks_Task3(void);

#endif

#endif