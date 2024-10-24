#!/usr/bin/env python3

# Parse RIBs from https://archive.routeviews.org/route-views6/bgpdata/
# and generate a shuffled FIB.

import ipaddress
import json
import mrtparse
import tqdm
import random

interfaces = {}

def rand_interface(nexthop):
    if nexthop not in interfaces:
        interfaces[nexthop] = random.randint(0, 3)
    return interfaces[nexthop]

def find_path_attribute(path, required_attr):
    for attr in path['path_attributes']:
        if required_attr in attr['type'].values():
            return attr
    return None

def cmp_path(a, b):
    as_path_a = find_path_attribute(a, 'AS_PATH')
    as_path_b = find_path_attribute(b, 'AS_PATH')
    if as_path_a['value'][0]['length'] < as_path_b['value'][0]['length']:
        return True
    elif as_path_a['value'][0]['length'] > as_path_b['value'][0]['length']:
        return False
    return a['peer_index'] < b['peer_index']

rib = []
for e in tqdm.tqdm(mrtparse.Reader('./rib.20241024.1200.bz2')):
    if 'TABLE_DUMP_V2' not in e.data['type'].values() \
       or 'RIB_IPV6_UNICAST' not in e.data['subtype'].values():
        print(e.data['subtype'])
        print(json.dumps(e.data, indent=2))
        continue
    if e.data['length'] > 48:
        continue
    if rib:
        ipa = ipaddress.IPv6Address(rib[-1]['prefix'])
        ipb = ipaddress.IPv6Address(e.data['prefix'])
        assert ipa < ipb or (ipa == ipb and rib[-1]['length'] <= e.data['length'])
    # dedup
    if rib and rib[-1]['prefix'] == e.data['prefix'] \
       and rib[-1]['length'] == e.data['length']:
        rib[-1]['rib_entries'].extend(e.data['rib_entries'])
        print('{}/{} dup!'.format(e.data['prefix'], e.data['length']))
    else:
        rib.append(e.data)

lines = []
prefixlen_count = [0] * 129
for e in tqdm.tqdm(rib):
    min_path = e['rib_entries'][0]
    for path in e['rib_entries']:
        if cmp_path(path, min_path):
            min_path = path
    nexthop = find_path_attribute(min_path, 'MP_REACH_NLRI')['value']['next_hop'][0]
    lines.append('{} {} {} {}\n'.format(e['prefix'], e['length'],
                                        nexthop, rand_interface(nexthop)))
    prefixlen_count[e['length']] += 1

with open('prefixlen.csv', 'w') as f:
    for prefixlen, count in enumerate(prefixlen_count):
        print(prefixlen, count)
        f.write(f'{prefixlen},{count}\n')

random.shuffle(lines)

with open('fib_shuffled.txt', 'w') as f:
    for l in lines:
        f.write(l)
