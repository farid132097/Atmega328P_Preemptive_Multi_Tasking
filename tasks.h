

#ifndef _TASKS_H_
#define _TASKS_H_


void    init_task(uint8_t tid, void (*entry)(void));
void    init_main_task(void);
void    switch_task(void);
void    task0(void);
void    task1(void);



#endif


