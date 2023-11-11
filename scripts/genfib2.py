#!/usr/bin/env python3

import random
import sys

# Usage:
#   python3 genfib2.py fib_shuffled.txt fib_shuffled2.txt

nexthop_ips = [f'fe80::8e1f:64ff:fe69:100{i + 1}' for i in range(4)]

with open(sys.argv[1], 'r') as fin, \
     open(sys.argv[2], 'w') as fout:
    for l in fin:
        net, prefix_len, nexthop_ip, nexthop_iface = l.strip().split()
        nexthop_iface = random.randint(0, 3)
        nexthop_ip = nexthop_ips[nexthop_iface]
        fout.write(f'{net} {prefix_len} {nexthop_ip} {nexthop_iface}\n')
