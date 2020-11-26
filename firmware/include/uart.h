#ifndef _UART_H_
#define _UART_H_

#include "stdint.h"

#define UART_BASE 0x10000000

#define UART_THR (*(volatile uint8_t *)(UART_BASE + 0))
#define UART_DLL (*(volatile uint8_t *)(UART_BASE + 0))
#define UART_IER (*(volatile uint8_t *)(UART_BASE + 1))
#define UART_DLM (*(volatile uint8_t *)(UART_BASE + 1))
#define UART_FCR (*(volatile uint8_t *)(UART_BASE + 2))
#define UART_LCR (*(volatile uint8_t *)(UART_BASE + 3))
#define UART_MCR (*(volatile uint8_t *)(UART_BASE + 4))
#define UART_LSR (*(volatile uint8_t *)(UART_BASE + 5))

// LSR 寄存器的定义
#define COM_LSR_FIFOE 0x80          /* Fifo error */
#define COM_LSR_TEMT 0x40           /* Transmitter empty */
#define COM_LSR_THRE 0x20           /* Transmit-hold-register empty */
#define COM_LSR_BI 0x10             /* Break interrupt indicator */
#define COM_LSR_FE 0x08             /* Frame error indicator */
#define COM_LSR_PE 0x04             /* Parity error indicator */
#define COM_LSR_OE 0x02             /* Overrun error indicator */
#define COM_LSR_DR 0x01             /* Receiver data ready */
#define COM_LSR_BRK_ERROR_BITS 0x1E /* BI, FE, PE, OE bits */

#define COM_FCR_CONFIG 0x7 /* FIFO Enable and FIFO Reset */

#define COM_LCR_DLAB 0x80
#define COM_LCR_WLEN8 0x03
#define COM_LCR_CONFIG (COM_LCR_WLEN8 & ~(COM_LCR_DLAB))

// QEMU 中，DLL 的值应该是 baudrate / 9600
// AXI Uart16550 中，DLL 的值应该是 clk_freq / 16 / baudrate
#define COM_DLL_VAL (115200 / 9600)

#define COM_IER_RDI 0x01

void init_uart(void);

#endif
