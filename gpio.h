

#ifndef _GPIO_H_
#define _GPIO_H_


#define  GPIO0_DDR  DDRD
#define  GPIO0_PORT PORTD
#define  GPIO0_bp   4U

#define  GPIO1_DDR  DDRC
#define  GPIO1_PORT PORTC
#define  GPIO1_bp   5U

#define  GPIO2_DDR  DDRC
#define  GPIO2_PORT PORTC
#define  GPIO2_bp   4U

#define  GPIO3_DDR  DDRC
#define  GPIO3_PORT PORTC
#define  GPIO3_bp   3U

#define  GPIO4_DDR  DDRC
#define  GPIO4_PORT PORTC
#define  GPIO4_bp   2U

void     GPIO_Struct_Init(void);
void     GPIO_Reg_Init(void);

void     GPIO0_Set(uint8_t val);
void     GPIO0_Toggle(void);

void     GPIO1_Set(uint8_t val);
void     GPIO1_Toggle(void);

void     GPIO2_Set(uint8_t val);
void     GPIO2_Toggle(void);

void     GPIO3_Set(uint8_t val);
void     GPIO3_Toggle(void);

void     GPIO4_Set(uint8_t val);
void     GPIO4_Toggle(void);
\
void     GPIO_Init(void);


#endif

