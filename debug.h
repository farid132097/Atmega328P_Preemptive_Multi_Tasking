

#ifndef  _DEBUG_H_
#define  _DEBUG_H_









#ifndef __ASSEMBLER__           //Only accessible via C


extern void      Debug_Init(void);
extern void      Debug_Tx_Byte(uint8_t data);
extern void      Debug_Tx_Byte_Conf(uint8_t data);

#endif

#endif


