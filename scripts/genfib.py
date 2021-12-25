#!/usr/bin/env python3

import ipaddress
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

rib = []
for e in mrtparse.Reader('./scripts/rib.20211221.0000.bz2'):
    if e.data['type'][1] != 'TABLE_DUMP_V2' or e.data['subtype'][1] != 'RIB_IPV6_UNICAST':
        print(e.data['subtype'][1])
        print(json.dumps(e.data, indent=2))
        continue
    if e.data['prefix_length'] > 48:
        continue
    if rib:
        ipa = ipaddress.IPv6Address(rib[-1]['prefix'])
        ipb = ipaddress.IPv6Address(e.data['prefix'])
        assert ipa < ipb or (ipa == ipb and rib[-1]['prefix_length'] <= e.data['prefix_length'])
    # dedup
    if rib and rib[-1]['prefix'] == e.data['prefix'] \
       and rib[-1]['prefix_length'] == e.data['prefix_length']:
        rib[-1]['rib_entries'].extend(e.data['rib_entries'])
        print('{}/{} dup!'.format(e.data['prefix'], e.data['prefix_length']))
    else:
        rib.append(e.data)
    if len(rib) % 1000 == 0:
        print(len(rib))

lines = []
prefixlen_count = [0] * 129
for e in rib:
    min_path = e['rib_entries'][0]
    for path in e['rib_entries']:
        if cmp_path(path, min_path):
            min_path = path
    nexthop = None
    for attr in min_path['path_attributes']:
        if attr['type'][1] == 'MP_REACH_NLRI':
            nexthop = attr['value']['next_hop'][0]
    assert nexthop is not None
    lines.append('{} {} {} {}\n'.format(e['prefix'], e['prefix_length'],
                                        nexthop, rand_interface(nexthop)))
    prefixlen_count[e['prefix_length']] += 1
    if len(lines) % 1000 == 0:
        print(len(lines))

for prefixlen, count in enumerate(prefixlen_count):
    print(prefixlen, count)

random.shuffle(lines)

with open('fib_shuffled.txt', 'w') as f:
    for l in lines:
        f.write(l)
