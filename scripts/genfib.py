#!/usr/bin/env python3

import json
import mrtparse
import random

interfaces = {}

def rand_interface(nexthop):
    if nexthop not in interfaces:
        interfaces[nexthop] = random.randint(0, 3)
    return interfaces[nexthop]

def cmp_path(a, b):
    assert a['path_attributes'][1]['type'][1] == 'AS_PATH'
    assert b['path_attributes'][1]['type'][1] == 'AS_PATH'
    if a['path_attributes'][1]['length'] < b['path_attributes'][1]['length']:
        return True
    elif a['path_attributes'][1]['length'] > b['path_attributes'][1]['length']:
        return False
    return a['peer_index'] < b['peer_index']

lines = []
prefixlen_count = [0] * 129
for e in mrtparse.Reader('./scripts/rib.20211221.0000.bz2'):
    if e.data['type'][1] != 'TABLE_DUMP_V2' or e.data['subtype'][1] != 'RIB_IPV6_UNICAST':
        print(e.data['subtype'][1])
        print(json.dumps(e.data, indent=2))
        continue
    if e.data['prefix_length'] > 48:
        continue
    min_path = e.data['rib_entries'][0]
    for path in e.data['rib_entries']:
        if cmp_path(path, min_path):
            min_path = path
    nexthop = None
    for attr in min_path['path_attributes']:
        if attr['type'][1] == 'MP_REACH_NLRI':
            nexthop = attr['value']['next_hop'][0]
    assert nexthop is not None
    lines.append('{} {} {} {}\n'.format(e.data['prefix'], e.data['prefix_length'],
                                        nexthop, rand_interface(nexthop)))
    prefixlen_count[e.data['prefix_length']] += 1
    if len(lines) % 1000 == 0:
        print(len(lines))

for prefixlen, count in enumerate(prefixlen_count):
    print(prefixlen, count)

random.shuffle(lines)

with open('fib_shuffled.txt', 'w') as f:
    for l in lines:
        f.write(l)
