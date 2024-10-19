

#include <avr/io.h>
#include <util/delay.h>
#include "gpio.h"


void GPIO_Init(void){
  GPIO0_DDR  |=  (1<<GPIO0_bp);
  GPIO0_PORT &=~ (1<<GPIO0_bp);
  
  GPIO1_DDR  |=  (1<<GPIO1_bp);
  GPIO1_PORT &=~ (1<<GPIO1_bp);
  
  GPIO2_DDR  |=  (1<<GPIO2_bp);
  GPIO2_PORT &=~ (1<<GPIO2_bp);
  
  GPIO3_DDR  |=  (1<<GPIO3_bp);
  GPIO3_PORT &=~ (1<<GPIO3_bp);
  
  GPIO4_DDR  |=  (1<<GPIO4_bp);
  GPIO4_PORT &=~ (1<<GPIO4_bp);
}

void GPIO0_Set(uint8_t val){
  if(val == 0){
    GPIO0_PORT &=~ (1<<GPIO0_bp);
  }
  else{
    GPIO0_PORT |=  (1<<GPIO0_bp);
  }
}

void GPIO1_Set(uint8_t val){
  if(val == 0){
    GPIO1_PORT &=~ (1<<GPIO1_bp);
  }
  else{
    GPIO1_PORT |=  (1<<GPIO1_bp);
  }
}

void GPIO2_Set(uint8_t val){
  if(val == 0){
    GPIO2_PORT &=~ (1<<GPIO2_bp);
  }
  else{
    GPIO2_PORT |=  (1<<GPIO2_bp);
  }
}

void GPIO3_Set(uint8_t val){
  if(val == 0){
    GPIO3_PORT &=~ (1<<GPIO3_bp);
  }
  else{
    GPIO3_PORT |=  (1<<GPIO3_bp);
  }
}

void GPIO4_Set(uint8_t val){
  if(val == 0){
    GPIO4_PORT &=~ (1<<GPIO4_bp);
  }
  else{
    GPIO4_PORT |=  (1<<GPIO4_bp);
  }
}

