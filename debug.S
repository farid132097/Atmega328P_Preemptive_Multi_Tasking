
#include <avr/io.h>
#include <avr/interrupt.h>
#include "debug.h"




;define hardware register addresses macros 
.equ    SRGPIOR0,     0x3E   ;manually defined GPIOR0 in SRAM
.equ    SRGPIOR1,     0x4A   ;manually defined GPIOR1 in SRAM
.equ    SRGPIOR2,     0x4B   ;manually defined GPIOR2 in SRAM
.equ    SRUDR0  ,     0xC6   ;manually defined UDR0 in SRAM
.equ    SRUBRR0H,     0xC5   ;manually defined UBRR0H in SRAM
.equ    SRUBRR0L,     0xC4   ;manually defined UBRR0L in SRAM
.equ    SRUCSR0C,     0xC2   ;manually defined UCSR0C in SRAM
.equ    SRUCSR0B,     0xC1   ;manually defined UCSR0B in SRAM
.equ    SRUCSR0A,     0xC0   ;manually defined UCSR0A in SRAM


;Code section start
.section .text

.global  Debug_Init
.global  Debug_Tx_Byte
.global  Debug_Tx_Byte_Conf
.global  Debug_Tx_Word_Conf
.global  Debug_Tx_DWord_Conf

.global  Debug_Tx_From_RAM
.global  Debug_Tx_RAM_Area


;;========================================Debug Init========================================;;
Debug_Init:
        ;init registers for UART0
		LDI   R16                , (1<<1)                 ;mask U2x,                (1 clock )
		STS   SRUCSR0A           , R16                    ;load val to UCSR0A,      (2 clocks)
		LDI   R16                , 0x00                   ;clear R16,               (1 clock )
		STS   SRUBRR0H           , R16                    ;load val to UBRR0H,      (2 clocks)
		LDI   R16                , 0x03                   ;set 0x03, 250k baud,     (1 clock )
		STS   SRUBRR0L           , R16                    ;load val to UBRR0L,      (2 clocks)
		LDI   R16                , (1<<1)|(1<<2)          ;config 8 data bit        (1 clock )
		STS   SRUCSR0C           , R16                    ;load val to UCSR0C,      (2 clocks)
		LDI   R16                , (1<<3)                 ;enable tx,               (1 clock )
		STS   SRUCSR0B           , R16                    ;load val to UCSR0B,      (2 clocks)
        RET                                               ;return from subroutine,  (4 clocks) 


;;=========================================Debug Tx=========================================;;
Debug_Tx_Byte:
		;write single byte to data register (Arg R24)
		STS   SRGPIOR0           , R16                    ;store R16 val,           (2 clocks)
		STS   SRUDR0             , R24                    ;load val to UDR0,        (2 clocks)
		
    __WAIT0:
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16,      (2 clocks)
		SBRS  R16                , 0x05                   ;skip if UDRE0 is set,    (2 clocks)
		RJMP  __WAIT0                                     ;wait until UDRE0 is set, (2 clocks)
		LDS   R16                , SRGPIOR0               ;restore R16 val,         (2 clocks)
        RET                                               ;return from subroutine,  (4 clocks) 


;;=========================================Debug Tx=========================================;;
Debug_Tx_Byte_Conf:
        ;write single byte to data register and wait until tx is complete (Arg R24)
		STS   SRGPIOR0           , R16                    ;store R16 val,           (2 clocks)
		STS   SRUDR0             , R24                    ;load val to UDR0,        (2 clocks)
		
    __WAIT1:
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16,      (2 clocks)
		SBRS  R16                , 0x06                   ;skip if TXC0 is set,     (2 clocks)
		RJMP  __WAIT1                                     ;wait until TXC0 is set,  (2 clocks)
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16,      (2 clocks)
		ORI   R16                , (1<<6)                 ;mask bit 6,              (1 clock )
		STS   SRUCSR0A           , R16                    ;load val to UCSR0B,      (2 clocks)
		LDS   R16                , SRGPIOR0               ;restore R16 val,         (2 clocks)
        RET                                               ;return from subroutine,  (4 clocks) 

;;======================================Debug Tx Word=======================================;;
Debug_Tx_Word_Conf:
        ;write 2 bytes to data register and wait until tx is complete (Arg R24, R25)
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
		MOV   R24                , R25                    ;copy R25 to R24          (1 clock )
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
        RET                                               ;return from subroutine,  (4 clocks) 

;;=====================================Debug Tx DWord=======================================;;
Debug_Tx_DWord_Conf:
        ;write 4 bytes to data register and wait until tx is complete (Arg R22-R25)
		STS   SRGPIOR1           , R24                    ;store R24 val,           (2 clocks)
		MOV   R24                , R22                    ;copy R22 to R24          (1 clock )
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
		MOV   R24                , R23                    ;copy R23 to R24          (1 clock )
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
		LDS   R24                , SRGPIOR1               ;restore R24              (2 clocks)
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
		MOV   R24                , R25                    ;copy R22 to R24          (1 clock )
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
        RET                                               ;return from subroutine,  (4 clocks) 



;;===================================Debug Tx RAM Area======================================;;
Debug_Tx_From_RAM:
        ;print data from RAM address (Arg R24-R25)
		MOV   R16                , R30                    ;copy R30 to R16          (1 clock )
		MOV   R17                , R31                    ;copy R31 to R17          (1 clock )
		MOV   R18                , R24                    ;copy R24 to R18          (1 clock )
		MOV   R30                , R24                    ;copy R22 to R24          (1 clock )
		MOV   R31                , R25                    ;copy R22 to R24          (1 clock )
		LD    R24                , Z                      ;load val to R24          (2 clocks)
		CALL  Debug_Tx_Byte_Conf                          ;send via uart
		MOV   R30                , R16                    ;copy R16 to R30          (1 clock )
		MOV   R31                , R17                    ;copy R17 to R31          (1 clock )
		MOV   R24                , R18                    ;copy R18 to R24          (1 clock )
        RET                                               ;return from subroutine,  (4 clocks) 


;;===================================Debug Tx RAM Area======================================;;
Debug_Tx_RAM_Area:
        ;print data from RAM address (arguments R24:R25, R22)
	__DUMP_BYTES:
	    CALL  Debug_Tx_From_RAM                           ;send via uart from ram
		SUBI  R24                , 0x01                   ;decrement from LSByte
        SBCI  R25                , 0x00                   ;decrement if carry
		SUBI  R22                , 0x01                   ;decrement
		BRNE  __DUMP_BYTES
        RET                                               ;return from subroutine,  (4 clocks) 
