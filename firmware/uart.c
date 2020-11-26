#include <uart.h>

void init_uart(void)
{
#ifdef ENABLE_UART16550
    UART_FCR = COM_FCR_CONFIG;
    UART_LCR = COM_LCR_DLAB;
    UART_DLL = COM_DLL_VAL;
    UART_DLM = 0;
    UART_LCR = COM_LCR_CONFIG;
    UART_MCR = 0;
#endif
}

void _putchar(char ch)
{
    while (!(UART_LSR & COM_LSR_THRE));
    UART_THR = ch;
}
