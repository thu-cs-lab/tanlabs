#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <uart.h>

extern uint32_t _bss_begin[];
extern uint32_t _bss_end[];

void start(void)
{
    for (uint32_t *p = _bss_begin; p != _bss_end; ++p)
    {
        *p = 0;
    }

    init_uart();

    printf("hello, world\n");

    while (true);
}
