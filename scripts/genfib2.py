#!/usr/bin/env python3

import random
import sys

# Usage:
#   python3 genfib2.py fib_shuffled.txt fib_shuffled2.txt

with open(sys.argv[1], 'r') as fin, \
     open(sys.argv[2], 'w') as fout:
    for l in fin:
        net, prefix_len, nexthop_ip, nexthop_iface = l.strip().split()
        nexthop_iface = random.randint(0, 3)
        fout.write(f'{net} {prefix_len} {nexthop_ip} {nexthop_iface}\n')
