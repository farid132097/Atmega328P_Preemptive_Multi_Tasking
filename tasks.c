
#include <avr/io.h>
#include <util/delay.h>
#include "systick.h"
#include "context.h"
#include "tasks.h"
#include "gpio.h"


#define   NUM_TASKS 2
#define   STACK_SIZE 64

uint8_t   stacks[NUM_TASKS][STACK_SIZE];
uint16_t  task_sp[NUM_TASKS];       // Saved stack pointer for each task
volatile  uint8_t current_task = 0;


void init_task(uint8_t tid, void (*entry)(void)) {
    uint8_t *stack = &stacks[tid][STACK_SIZE];
    
    // Simulate CALL to entry()
    stack -= 2;
    stack[0] = (uint16_t)entry & 0xFF;
    stack[1] = ((uint16_t)entry >> 8) & 0xFF;

    // Push fake register values (R0–R31 + SREG)
    for (int i = 0; i < 33; i++) {
        *(--stack) = 0;
    }

    task_sp[tid] = (uint16_t)stack;
}

void init_main_task(void){
    current_task = 0;
    SP = task_sp[0];
}

void switch_task(void) {
    Context_Save();

    task_sp[current_task] = SP;
    current_task = (current_task + 1) % NUM_TASKS;
    SP = task_sp[current_task];

    Context_Restore();
}

void task0(void) {
    while (1) {
        GPIO0_Toggle();
        _delay_ms(100);
    }
}

void task1(void) {
    while (1) {
        GPIO1_Toggle();
        _delay_ms(150);
    }
}