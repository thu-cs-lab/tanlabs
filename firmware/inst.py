#!/usr/bin/env python3

import sys

INST19 = {'auipc', 'add', 'addi', 'and', 'andi', 'or', 'ori', 'slli', 'srli',
          'xor', 'beq', 'bne', 'jal', 'jalr', 'lb', 'lw', 'lui', 'sb', 'sw'}

insts = set()
ext_insts = set()
ext_inst_addr = []

lines = sys.stdin.readlines()[6:]
for line in lines:
    # 80000000:       00003117                auipc   sp,0x3
    line = line.strip()
    addr_inst = list(filter(lambda s: s.strip(), line.split(':', 1)))
    if len(addr_inst) <= 1:
        continue
    addr = addr_inst[0]
    inst = list(filter(lambda s: s.strip(), addr_inst[1].replace('\t', ' ').split(' ')))
    inst = inst[1]
    if inst in INST19:
        insts.add(inst)
    else:
        ext_insts.add(inst)
        ext_inst_addr.append((addr, inst))

print('Basic instructions:')
for inst in sorted(insts):
    print(' ', inst)
print('Extended instructions:')
for inst in sorted(ext_insts):
    print(' ', inst)
print('Extended instruction addresses:')
for addr, inst in ext_inst_addr:
    print('  {}: {}'.format(addr, inst))
