#define END_OF_STACK 0x80800000

.section .text.reset_vector, "ax", @progbits
.global _reset_vector
_reset_vector:
    li sp, END_OF_STACK - 0x10
    j start
