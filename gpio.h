

#define  GPIO0_DDR  DDRD
#define  GPIO0_PORT PORTD
#define  GPIO0_bp   5U

#define  GPIO1_DDR  DDRD
#define  GPIO1_PORT PORTD
#define  GPIO1_bp   6U

#define  GPIO2_DDR  DDRC
#define  GPIO2_PORT PORTC
#define  GPIO2_bp   0U

#define  GPIO3_DDR  DDRC
#define  GPIO3_PORT PORTC
#define  GPIO3_bp   1U

#define  GPIO4_DDR  DDRC
#define  GPIO4_PORT PORTC
#define  GPIO4_bp   2U


void GPIO_Init(void);

void GPIO0_Set(uint8_t val);
void GPIO0_Toggle(void);

void GPIO1_Set(uint8_t val);
void GPIO1_Toggle(void);

void GPIO2_Set(uint8_t val);
void GPIO2_Toggle(void);

void GPIO3_Set(uint8_t val);
void GPIO3_Toggle(void);

void GPIO4_Set(uint8_t val);
void GPIO4_Toggle(void);
