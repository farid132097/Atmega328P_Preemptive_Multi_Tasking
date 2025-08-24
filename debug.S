
#include <avr/io.h>
#include <avr/interrupt.h>
#include "debug.h"



;;===========================define hardware reg address starting===========================;; 
.equ    SRGPIOR0,     0x3E   ;manually defined GPIOR0 in SRAM
.equ    SRGPIOR1,     0x4A   ;manually defined GPIOR1 in SRAM
.equ    SRGPIOR2,     0x4B   ;manually defined GPIOR2 in SRAM
.equ    SRUDR0  ,     0xC6   ;manually defined UDR0 in SRAM
.equ    SRUBRR0H,     0xC5   ;manually defined UBRR0H in SRAM
.equ    SRUBRR0L,     0xC4   ;manually defined UBRR0L in SRAM
.equ    SRUCSR0C,     0xC2   ;manually defined UCSR0C in SRAM
.equ    SRUCSR0B,     0xC1   ;manually defined UCSR0B in SRAM
.equ    SRUCSR0A,     0xC0   ;manually defined UCSR0A in SRAM
;;==============================define hardware reg address end=============================;; 





;;===============================define text section starting===============================;; 
.section .text
;;==================================define text section end=================================;; 





;;==============================define global functions starting============================;; 
.global  Debug_Init
.global  Debug_Tx_Byte
.global  Debug_Tx_Byte_Conf
.global  Debug_Tx_Word_Conf
.global  Debug_Tx_DWord_Conf

.global  Debug_Tx_From_RAM
.global  Debug_Tx_RAM_Area
;;================================define global functions end===============================;;





;;===================================debug init starting====================================;;
Debug_Init:                                               ;total 2.38uS @8MHz     ( 19 clocks) 
        ;init registers for UART0 (Arg R25:R24->UBRRH:UBRRL)
		LDI   R16                , (1<<1)                 ;mask U2x               (  1 clock )
		STS   SRUCSR0A           , R16                    ;load val to UCSR0A     (  2 clocks)
		MOV   R16                , R25                    ;copy R25->baud rate H  (  1 clock )
		STS   SRUBRR0H           , R16                    ;load val to UBRR0H     (  2 clocks)
		MOV   R16                , R24                    ;copy R24->baud rate L  (  1 clock )
		STS   SRUBRR0L           , R16                    ;load val to UBRR0L     (  2 clocks)
		LDI   R16                , (1<<1)|(1<<2)          ;config 8 data bit      (  1 clock )
		STS   SRUCSR0C           , R16                    ;load val to UCSR0C     (  2 clocks)
		LDI   R16                , (1<<3)                 ;enable tx              (  1 clock )
		STS   SRUCSR0B           , R16                    ;load val to UCSR0B     (  2 clocks)
        RET                                               ;return from subroutine (  4 clocks) 
;;======================================debug init end======================================;;





;;====================================debug tx starting=====================================;;
Debug_Tx_Byte:                                            ;total 2.00uS+LT @8MHz  ( 16 clocks)
		;write single byte to data register (Arg R24)
		PUSH  R16                                         ;save reg               (  2 clocks)
		STS   SRUDR0             , R24                    ;load val to UDR0       (  2 clocks)

    __UDRE0_CLEARED:                                      ;undefined loop wrt ck
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16     (  2 clocks)
		SBRS  R16                , 0x05                   ;skip if UDRE0 is set   (  2 clocks)
		RJMP  __UDRE0_CLEARED                             ;wait until UDRE0 is set(  2 clocks)
		POP   R16                                         ;restore reg            (  2 clocks)
        RET                                               ;return from subroutine (  4 clocks) 
;;======================================debug tx end========================================;;





;;================================debug tx confirm starting=================================;;
Debug_Tx_Byte_Conf:                                       ;total 2.63uS+LT @8MHz  ( 21 clocks)
        ;write 1 byte, (Arg R24), Arg retained
		PUSH  R16                                         ;save reg               (  2 clocks)
		STS   SRUDR0             , R24                    ;load val to UDR0       (  2 clocks)
		
    __TXC0_CLEARED:                                       ;undefined loop wrt ck
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16     (  2 clocks)
		SBRS  R16                , 0x06                   ;skip if TXC0 is set    (  2 clocks)
		RJMP  __TXC0_CLEARED                              ;wait until TXC0 is set (  2 clocks)
		LDS   R16                , SRUCSR0A               ;load UCSR0A to R16     (  2 clocks)
		ORI   R16                , (1<<6)                 ;mask bit 6             (  1 clock )
		STS   SRUCSR0A           , R16                    ;write reg with bit msk (  2 clocks)
		POP   R16                                         ;restore reg            (  2 clocks)
        RET                                               ;return from subroutine (  4 clocks) 
;;===================================debug tx confirm end===================================;;





;;==============================debug tx word confirm starting==============================;;
Debug_Tx_Word_Conf:                                       ;total 6.38uS+LT @8MHz  ( 51 clocks)
        ;write 2 bytes, (Arg R24, R25), Args retained
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks)
		PUSH  R24                                         ;save reg               (  2 clocks)
		MOV   R24                , R25                    ;copy R25 to R24        (  1 clock )
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks)
		POP   R24                                         ;restore reg            (  2 clocks)
        RET                                               ;return from subroutine (  4 clocks) 
;;================================debug tx word confirm end=================================;;





;;==============================debug tx dword confirm starting=============================;; 
Debug_Tx_DWord_Conf:                                      ;total 12.38uS+LT @8MHz ( 99 clocks) 
        ;write 4 bytes, (Args R25:R22), Args retained
		STS   SRGPIOR1           , R24                    ;store R24 val          (  2 clocks) 
		MOV   R24                , R22                    ;copy R22 to R24        (  1 clock ) 
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks) 
		MOV   R24                , R23                    ;copy R23 to R24        (  1 clock ) 
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks) 
		LDS   R24                , SRGPIOR1               ;restore R24            (  2 clocks) 
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks) 
		STS   SRGPIOR1           , R24                    ;store R24 val          (  2 clocks) 
		MOV   R24                , R25                    ;copy R22 to R24        (  1 clock ) 
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks) 
		LDS   R24                , SRGPIOR1               ;restore R24 val        (  2 clocks) 
        RET                                               ;return from subroutine (  4 clocks) 
;;================================debug tx dword confirm end================================;; 





;;=============================debug tx confirm from ram starting===========================;; 
Debug_Tx_From_RAM:                                        ;total 4.38uS+LT @8MHz  ( 35 clocks) 
        ;print data from RAM address (Args R25:R24)
		MOV   R16                , R30                    ;copy R30 to R16        (  1 clock ) 
		MOV   R17                , R31                    ;copy R31 to R17        (  1 clock ) 
		MOV   R18                , R24                    ;copy R24 to R18        (  1 clock ) 
		MOV   R30                , R24                    ;copy R22 to R24        (  1 clock ) 
		MOV   R31                , R25                    ;copy R22 to R24        (  1 clock ) 
		LD    R24                , Z                      ;load val to R24        (  2 clocks) 
		CALL  Debug_Tx_Byte_Conf                          ;send via uart          ( 21 clocks) 
		MOV   R30                , R16                    ;copy R16 to R30        (  1 clock ) 
		MOV   R31                , R17                    ;copy R17 to R31        (  1 clock ) 
		MOV   R24                , R18                    ;copy R18 to R24        (  1 clock ) 
        RET                                               ;return from subroutine (  4 clocks) 
;;================================debug tx confirm from ram end=============================;; 





;;=============================debug tx confirm ram area starting===========================;; 
Debug_Tx_RAM_Area:                                        ;5.5uS+LT x R22 @8MHz  ( 44 clocks) 
        ;print data from RAM address (arguments R24:R25, R22)
	__DUMP_BYTES:
	    CALL  Debug_Tx_From_RAM                           ;send via uart from ram ( 35 clocks) 
		SUBI  R24                , 0x01                   ;decrement from LSByte  (  1 clock )
        SBCI  R25                , 0x00                   ;decrement if carry     (  1 clock )
		SUBI  R22                , 0x01                   ;decrement              (  1 clock )
		BRNE  __DUMP_BYTES                                ;iterate loops          (  2 clocks)
        RET                                               ;return from subroutine (  4 clocks) 
;;===============================debug tx confirm ram area end==============================;;





