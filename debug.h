

#ifndef  _DEBUG_H_
#define  _DEBUG_H_









#ifndef __ASSEMBLER__           //Only accessible via C


extern void      Debug_Init(void);
extern void      Debug_Tx_Byte(uint8_t data);
extern void      Debug_Tx_Byte_Conf(uint8_t  data);
extern void      Debug_Tx_Word_Conf(uint16_t data);
extern void      Debug_Tx_DWord_Conf(uint32_t data);

extern void      Debug_Tx_From_RAM(uint16_t addr);
extern void      Debug_Tx_RAM_Area(uint16_t strt_addr, uint8_t len);

extern void      Debug_Print_TSK(uint8_t index);

#endif

#endif


