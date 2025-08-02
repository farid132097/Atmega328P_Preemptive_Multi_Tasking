
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
		;print using UART0->TX
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

