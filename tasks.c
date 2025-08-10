

#include <avr/io.h>
#include <util/delay.h>
#include "kernel.h"
#include "tasks.h"


void Tasks_Task0(void){
  DDRD |= (1<<5);
  
  while(1){
    PORTD ^= (1<<5);
	_delay_ms(50);
  }
}

void Tasks_Task1(void){
  DDRD |= (1<<6);
  
  while(1){
    PORTD ^= (1<<6);
	_delay_ms(60);
  }
}

void Tasks_Task2(void){
  DDRD |= (1<<7);
  
  while(1){
    PORTD ^= (1<<7);
	_delay_ms(70);
  }
}