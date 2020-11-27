TRIPLE = riscv64-unknown-elf-
GCC = $(TRIPLE)gcc
OBJCOPY = $(TRIPLE)objcopy
OBJDUMP = $(TRIPLE)objdump
QEMU = qemu-system-riscv32

DEFINES = -DPRINTF_DISABLE_SUPPORT_FLOAT -DPRINTF_DISABLE_SUPPORT_EXPONENTIAL \
          -DPRINTF_DISABLE_SUPPORT_LONG_LONG
CFLAGS = -fno-builtin -nostdlib -nostdinc -static -Wl,--gc-sections,--print-gc-sections -O2 -Wall \
         -Iinclude $(DEFINES) -march=rv32i -mabi=ilp32 -DRV32
LDFLAGS = -z separate-code

-include Makefile.config

override EN_UART16550 ?= n
ifeq ($(EN_UART16550), y)
	CFLAGS += -DENABLE_UART16550
endif

HEADERS=$(wildcard include/*.h)
SOURCES=$(wildcard *.c *.S)
OBJECTS=$(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.S,%.o,$(wildcard *.S))
TARGET=kernel.elf

.PHONY: all
all: $(OBJECTS) $(TARGET) kernel.bin

.PHONY: viasm
viasm: $(TARGET)
	$(OBJDUMP) -xd $< | vi -

.PHONY: inst
inst: $(TARGET)
	$(OBJDUMP) -Mno-aliases -d $< | ./inst.py

%.asm: %.elf
	$(OBJDUMP) -xd $< > $@

%.bin: %.elf
	$(OBJCOPY) -S --adjust-vma -0x80000000 -O binary $< $@

%.o: %.c $(HEADERS)
	$(GCC) $(CFLAGS) -c $< -o $@

%.o: %.S $(HEADERS)
	$(GCC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS) linker.ld
	$(GCC) -Tlinker.ld $(CFLAGS) $(LDFLAGS) $(OBJECTS) -lgcc -o $@

sim: $(TARGET)
	$(QEMU) -machine virt -nographic -m 8M -kernel $(TARGET) -S -s -bios none

.PHONY: clean
clean:
	-rm *.o *.elf *.bin *.asm $(TARGET)
