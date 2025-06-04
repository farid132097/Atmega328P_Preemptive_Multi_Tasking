

#include <avr/io.h>
#include "states.h"




void init_stack(TCB *tcb, uint8_t *stack, void (*task_func)(void)) {
    uint8_t *sp = stack + STACK_SIZE - 1;

    // Initial return address (PC) = address of task_func
    uint16_t addr = (uint16_t)task_func;
    *sp-- = (addr & 0xFF);
    *sp-- = (addr >> 8) & 0xFF;

    // Push initial registers (r0 to r31) and SREG onto stack with default values
    // Set SREG with interrupts enabled (I-bit = 1)
    *sp-- = 0x80; // SREG

    for (int i = 0; i < 32; i++) {
        *sp-- = 0; // R0-R31 = 0
    }

    tcb->stackPointer = sp + 1;
}

void task_switch(void) {
    SAVE_CONTEXT1();

    // Switch task pointers
    TCB *temp = currentTask;
    currentTask = nextTask;
    nextTask = temp;

    RESTORE_CONTEXT1();
}
