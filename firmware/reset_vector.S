.section .text.reset_vector, "ax", @progbits
.global _reset_vector
_reset_vector:
    la sp, _end_of_stack - 0x10
    j start

.section .bss
.balign 16
_stack:
    .space 0x2000
_end_of_stack:
