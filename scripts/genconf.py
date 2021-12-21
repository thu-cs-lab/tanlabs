#!/usr/bin/env python3

import random
import sys

# Usage:
#   python3 genconf.py fib_shuffled.txt 0 20000

skip = int(sys.argv[2])
n = int(sys.argv[3])

routes = [[], [], [], []]
with open(sys.argv[1], 'r') as f:
    for l in f:
        if skip:
            skip -= 1
            continue
        if not n:
            break
        net, prefix_len, nexthop_ip, nexthop_iface = l.strip().split()
        nexthop_iface = int(nexthop_iface)
        routes[nexthop_iface].append((net, prefix_len, nexthop_ip, nexthop_iface))
        n -= 1

for i in range(4):
    with open('./conf/rib-{}.conf'.format(i), 'w') as f:
        for net, prefix_len, nexthop_ip, nexthop_iface in routes[i]:
            f.write('route {}/{} unreachable;\n'.format(net, prefix_len))
