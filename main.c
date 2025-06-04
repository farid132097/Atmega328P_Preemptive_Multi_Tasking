#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

typedef void (*TaskFunc)(void);

volatile TaskFunc current_task;
volatile uint8_t task_flag = 0;  // Set by timer ISR to switch tasks

void task1(void) {
    PORTD ^= (1 << PD5);  // Toggle PD5 LED
    _delay_ms(10);        // Short delay
}

void task2(void) {
    PORTD ^= (1 << PD6);  // Toggle PD6 LED
    _delay_ms(10);
}

void timer0_init(void) {
    // Normal mode, prescaler 64
    TCCR0A = 0x00;
    TCCR0B = (1 << CS01) | (1 << CS00);

    TIMSK0 = (1 << TOIE0);  // Enable Timer0 overflow interrupt
    TCNT0 = 0;              // Reset timer counter
}

ISR(TIMER0_OVF_vect) {
    task_flag = 1;  // Signal main loop to switch tasks
}

int main(void) {
    DDRD |= (1 << PD5) | (1 << PD6);   // Set PD5 and PD6 as outputs
    PORTD &= ~((1 << PD5) | (1 << PD6)); // Start with pins low

    current_task = task1;    // Start with task1

    timer0_init();
    sei();                  // Enable global interrupts

    while (1) {
        if (task_flag) {
            task_flag = 0;
            // Switch tasks
            if (current_task == task1)
                current_task = task2;
            else
                current_task = task1;
        }
        current_task();  // Run current task
    }
}
