#!/usr/bin/env python3

import math
import os
import sys

# Usage:
#   python3 calc-tc.py <# of routes> <update timer>
# e.g., RIPng 5040 routes in 3s: 278.507kbps

n = int(sys.argv[1])
timer = int(sys.argv[2])

RTE_PER_PACKET = int((1500 - 40 - 8 - 4) / 20)

num_packets = int(math.ceil(n / RTE_PER_PACKET))
num_bytes = (40 + 8 + 4) * num_packets + 20 * n

sys.stderr.write(f'{num_bytes / 1024} KiB\n')
sys.stderr.write(f'{num_bytes * 8 / timer / 1000} kbps\n')
print(int(math.ceil(num_bytes * 8 / timer)))
