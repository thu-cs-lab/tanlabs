SECTIONS
{
    RAM_BASE = 0x80000000;
    ENTRY(_reset_vector)
    ASSERT(_reset_vector == RAM_BASE, "Error: reset vector should be at RAM_BASE.")

    . = RAM_BASE;
    .text :
    {
        *(.text.reset_vector)
        *(.text*)
    }
    .rodata :
    {
        *(.rodata*)
        *(.srodata*)
    }
    .data :
    {
        *(.data*)
        *(.sdata*)
    }
    . = ALIGN(0x10);
    _bss_begin = .;
    .bss :
    {
        *(.bss*)
        *(.sbss*)
    }
    . = ALIGN(0x10);
    _bss_end = .;
    /DISCARD/ :
    {
        *(.note.gnu.build-id)
    }
}
