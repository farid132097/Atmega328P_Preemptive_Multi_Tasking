

#include <avr/io.h>
#include <avr/interrupt.h>
#include "states.h"


/*

void init_stack(void (*task_func)(void), uint8_t *stack, uint8_t **sp_out) {
    uint8_t *sp = stack + STACK_SIZE - 1;
    uint16_t addr = (uint16_t)task_func;

    *sp-- = (uint8_t)(addr & 0xFF);   // Return address low
    *sp-- = (uint8_t)(addr >> 8);     // Return address high

    *sp_out = sp;
}

void task_switch(void) {
    SAVE_CONTEXT_SIMP();

    // Swap stack pointers
    uint8_t *temp = current_sp;
    current_sp = next_sp;
    next_sp = temp;

    RESTORE_CONTEXT_SIMP();
}

ISR(TIMER0_OVF_vect){
    SAVE_CONTEXT_SIMP();

    // Swap stack pointers
    uint8_t *temp = current_sp;
    current_sp = next_sp;
    next_sp = temp;

    RESTORE_CONTEXT_SIMP();
}

*/