#!/usr/bin/env python3

import binascii
import datetime
import ipaddress
import json
import os
import pyroute2
import random
import re
import socket
import struct
import subprocess
import time
import tqdm

import pandas
import matplotlib.pyplot as plt
import seaborn as sb

DIR = os.path.dirname(os.path.realpath(__file__))

SERVER_IP = '10.8.8.100'
SERVER_PORT = 60000

NINTERFACES = 4
IFACE_PREFIX = 'tanlabs-if'
NETNS_PREFIX = 'tanlabs'

SERVER_FREQ = 125000000.0

# Global registers.
REGID_INVALID = 0
REGID_TICKS = 1
REGID_SCRATCH = 2
REGID_RESET_COUNTERS = 3
REGID_SAMPLE = 4
REGID_TICKS_SAMPLE = 5
# Per-interface registers.
REGID_IFACE_FLAG = 62
REGID_IFACE_WIDTH = 3
REGID_IFACE_SHIFT = 48
REGID_IP_DST_RAM_FLAG = 47
REGID_REGID_WIDTH = 8
REGID_IP_DST_RAM_WIDTH = 47
REGID_CONF_ENABLE = 0
REGID_CONF_MAC = 1
REGID_CONF_MAC_DST = 2
REGID_CONF_IP_SRC_HI = 3
REGID_CONF_IP_SRC_LO = 4
REGID_CONF_IP_DST_HI = 5
REGID_CONF_IP_DST_LO = 6
REGID_CONF_PACKET_LEN = 7
REGID_CONF_GAP_LEN = 8
REGID_CONF_USE_VAR_IP_DST = 9
REGID_CONF_USE_LFSR_IP_DST = 10
REGID_CONF_IP_DST_PTR_MASK = 11
REGID_IP_DST_PTR = 12
REGID_SEND_NBYTES = 13
REGID_SEND_NPACKETS = 14
REGID_RECV_NBYTES = 15
REGID_RECV_NBYTES_L3 = 16
REGID_RECV_NPACKETS = 17
REGID_RECV_NERROR = 18
REGID_RECV_LATENCY = 19

REGEX_ND = re.compile(r'Target link-layer address: ([0-9A-Fa-f:]+)\n')

IFA_F_NODAD = 0x02

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.connect((SERVER_IP, SERVER_PORT))
sock.settimeout(1.0)

class NoSuchRegisterError(Exception):
    pass

class NoSuchWritableRegisterError(Exception):
    pass

def do_command(data):
    delay = 0.1
    for retry in range(16):
        sock.send(data)
        try:
            resp = sock.recv(16)
            if len(resp) == 16:
                return resp
        except socket.timeout as e:
            if (retry == 15):
                raise e from None
            time.sleep(delay)
        if delay < 1:
            delay *= 2

def read_reg_raw(regid):
    resp = do_command(struct.pack('>QQ', regid, 0))
    resp_regid, regvalue = struct.unpack('>Q8s', resp)
    if resp_regid != regid:
        raise NoSuchRegisterError(regid)
    return regvalue

def write_reg_raw(regid, regvalue):
    resp = do_command(struct.pack('>Q8s', regid | (1 << 63), regvalue))
    resp_regid, regvalue = struct.unpack('>Q8s', resp)
    if resp_regid != regid:
        raise NoSuchWritableRegisterError(regid)

def read_reg(regid):
    return struct.unpack('>Q', read_reg_raw(regid))[0]

def write_reg(regid, regvalue):
    write_reg_raw(regid, struct.pack('>Q', regvalue))

def read_ip_dst(iface, index):
    regid_base = (iface << REGID_IFACE_SHIFT) \
                 | (1 << REGID_IFACE_FLAG) | (1 << REGID_IP_DST_RAM_FLAG)
    hi = read_reg_raw(regid_base + 2 * index)
    lo = read_reg_raw(regid_base + 2 * index + 1)
    return hi + lo

def write_ip_dst(iface, index, addr):
    regid_base = (iface << REGID_IFACE_SHIFT) \
                 | (1 << REGID_IFACE_FLAG) | (1 << REGID_IP_DST_RAM_FLAG)
    write_reg_raw(regid_base + 2 * index, addr[:8])
    write_reg_raw(regid_base + 2 * index + 1, addr[8:])

def ensure_mac(mac):
    if isinstance(mac, str):
        mac = binascii.a2b_hex(mac.replace(':', '').replace('-', ''))
    if isinstance(mac, bytes):
        if len(mac) != 6:
            raise TypeError('should be a 6-byte MAC address.')
        return mac
    else:
        raise TypeError('should be a MAC address.')

def ensure_ip(ip):
    if isinstance(ip, str):
        return ipaddress.IPv6Address(ip)
    elif isinstance(ip, ipaddress.IPv6Address):
        return ip
    else:
        raise TypeError('should be an IPv6 address.')

def reset_counters():
    write_reg(REGID_RESET_COUNTERS, 1)
    write_reg(REGID_RESET_COUNTERS, 0)

def do_nd(netns, iface, ip):
    args = ['ip', 'netns', 'exec', netns, 'ndisc6', str(ip), iface]
    print(' '.join(args))
    out = ''
    with subprocess.Popen(args, stdout=subprocess.PIPE, env={}) as p:
        out = p.stdout.read().decode()
    m = REGEX_ND.search(out)
    if not m:
        return None
    return m.group(1)

def set_interface(iface, enable=None, ip_src=None, ip_dst=None, packet_len=None, gap_len=None,
                  mac=None, mac_dst=None, gateway=None,
                  use_var_ip_dst=None, use_lfsr_ip_dst=None, ip_dst_ptr_mask=None, ip_dst_ptr=None):
    regid_base = (iface << REGID_IFACE_SHIFT) | (1 << REGID_IFACE_FLAG)
    cp_iface = IFACE_PREFIX + str(iface)
    cp_netns = NETNS_PREFIX + str(iface)
    if ip_src is not None:
        ip_src = ensure_ip(ip_src)
        ip_raw = ip_src.packed
        write_reg_raw(regid_base + REGID_CONF_IP_SRC_HI, ip_raw[:8])
        write_reg_raw(regid_base + REGID_CONF_IP_SRC_LO, ip_raw[8:])
        # FIXME: Should we set interface's IP address here?
        # It can be different from source IP address.
        with pyroute2.NetNS(cp_netns) as ip:
            dev = ip.link_lookup(ifname=cp_iface)[0]
            ip.flush_addr(index=dev)
            ip.addr('add', index=dev, address='fe80::fff' + str(iface + 1), prefixlen=64,
                    flags=IFA_F_NODAD)
            ip.addr('add', index=dev, address=str(ip_src), prefixlen=64,  # FIXME: prefixlen
                    flags=IFA_F_NODAD)
    if ip_dst is not None:
        ip_raw = ensure_ip(ip_dst).packed
        write_reg_raw(regid_base + REGID_CONF_IP_DST_HI, ip_raw[:8])
        write_reg_raw(regid_base + REGID_CONF_IP_DST_LO, ip_raw[8:])
    if packet_len is not None:
        write_reg(regid_base + REGID_CONF_PACKET_LEN, packet_len)
    if gap_len is not None:
        write_reg(regid_base + REGID_CONF_GAP_LEN, gap_len)
    if mac is not None:
        mac = ensure_mac(mac)
        write_reg_raw(regid_base + REGID_CONF_MAC, mac)
        with pyroute2.NetNS(cp_netns) as ip:
            dev = ip.link_lookup(ifname=cp_iface)[0]
            ip.link('set', index=dev, address=':'.join('{:02x}'.format(b) for b in mac))
    if mac_dst is not None:
        write_reg_raw(regid_base + REGID_CONF_MAC_DST, ensure_mac(mac_dst))
    if gateway is not None:
        gateway = ensure_ip(gateway)
        gateway_mac = do_nd(cp_netns, cp_iface, gateway)
        if not gateway_mac:
            print('Warning: cannot find MAC address for', str(gateway))
        else:
            print(str(gateway), '->', gateway_mac)
        set_interface(iface, mac_dst=gateway_mac)
    if use_lfsr_ip_dst is not None:
        write_reg(regid_base + REGID_CONF_USE_LFSR_IP_DST, int(use_lfsr_ip_dst))
    if use_var_ip_dst is not None:
        write_reg(regid_base + REGID_CONF_USE_VAR_IP_DST, int(use_var_ip_dst))
    if ip_dst_ptr_mask is not None:
        write_reg(regid_base + REGID_CONF_IP_DST_PTR_MASK, int(ip_dst_ptr_mask))
    if ip_dst_ptr is not None:
        write_reg(regid_base + REGID_IP_DST_PTR, int(ip_dst_ptr))
    # Set enable at the end.
    if enable is not None:
        write_reg(regid_base + REGID_CONF_ENABLE, int(enable))

def sample():
    write_reg(REGID_SAMPLE, 1)
    s = {'ticks': read_reg(REGID_TICKS_SAMPLE), 'interfaces': []}
    for i in range(NINTERFACES):
        regid_base = (i << REGID_IFACE_SHIFT) | (1 << REGID_IFACE_FLAG)
        iface = {}
        iface['enable'] = bool(read_reg(regid_base + REGID_CONF_ENABLE))
        iface['mac'] = read_reg_raw(regid_base + REGID_CONF_MAC)[:6]
        iface['mac_dst'] = read_reg_raw(regid_base + REGID_CONF_MAC_DST)[:6]
        iface['ip_src'] = ipaddress.IPv6Address(read_reg_raw(regid_base + REGID_CONF_IP_SRC_HI)
                                                + read_reg_raw(regid_base + REGID_CONF_IP_SRC_LO))
        iface['ip_dst'] = ipaddress.IPv6Address(read_reg_raw(regid_base + REGID_CONF_IP_DST_HI)
                                                + read_reg_raw(regid_base + REGID_CONF_IP_DST_LO))
        iface['packet_len'] = read_reg(regid_base + REGID_CONF_PACKET_LEN)
        iface['gap_len'] = read_reg(regid_base + REGID_CONF_GAP_LEN)
        iface['send_nbytes'] = read_reg(regid_base + REGID_SEND_NBYTES)
        iface['send_npackets'] = read_reg(regid_base + REGID_SEND_NPACKETS)
        iface['recv_nbytes'] = read_reg(regid_base + REGID_RECV_NBYTES)
        iface['recv_nbytes_l3'] = read_reg(regid_base + REGID_RECV_NBYTES_L3)
        iface['recv_npackets'] = read_reg(regid_base + REGID_RECV_NPACKETS)
        iface['recv_nerror'] = read_reg(regid_base + REGID_RECV_NERROR)
        iface['recv_latency'] = read_reg(regid_base + REGID_RECV_LATENCY) / SERVER_FREQ
        s['interfaces'].append(iface)
    return s

def sample_delta(a, b):
    duration = (b['ticks'] - a['ticks']) / SERVER_FREQ
    d = {'duration': duration, 'interfaces': []}
    ifa = a['interfaces']
    ifb = b['interfaces']
    d['send_pps'] = 0
    d['send_bps'] = 0
    d['recv_pps'] = 0
    d['recv_bps'] = 0
    d['recv_nerror'] = 0
    d['recv_latency'] = 0
    for i, _ in enumerate(ifa):
        iface = {}
        send_packets = ifb[i]['send_npackets'] - ifa[i]['send_npackets']
        send_overheads = send_packets * (4 + 12 + 8)
        iface['send_pps'] = send_packets / duration
        d['send_pps'] += iface['send_pps']
        iface['send_bps'] = 8 * (send_overheads + ifb[i]['send_nbytes'] - ifa[i]['send_nbytes']) / duration
        d['send_bps'] += iface['send_bps']
        recv_packets = ifb[i]['recv_npackets'] - ifa[i]['recv_npackets']
        recv_overheads = recv_packets * (4 + 12 + 8)
        iface['recv_pps'] = recv_packets / duration
        d['recv_pps'] += iface['recv_pps']
        iface['recv_bps'] = 8 * (recv_overheads + ifb[i]['recv_nbytes'] - ifa[i]['recv_nbytes']) / duration
        d['recv_bps'] += iface['recv_bps']
        iface['recv_nerror'] = ifb[i]['recv_nerror'] - ifa[i]['recv_nerror']
        d['recv_nerror'] += iface['recv_nerror']
        iface['recv_latency'] = ifb[i]['recv_latency']
        d['recv_latency'] += ifb[i]['recv_latency']
        d['interfaces'].append(iface)
    d['recv_latency'] /= len(ifa)
    return d

def print_sample(s):
    print('Sample Ticks:', s['ticks'])
    print('# En Tx#bytes    Tx#packets Rx#bytes    Rx#l3_bytes Rx#packets Rx#error   RxLatency')
    for i, iface in enumerate(s['interfaces']):
        print('{} {: <2} {: <11} {: <10} {: <11} {: <11} {: <10} {: <10} {: <9}'.format(
              i, int(iface['enable']), iface['send_nbytes'], iface['send_npackets'],
              iface['recv_nbytes'], iface['recv_nbytes_l3'], iface['recv_npackets'],
              iface['recv_nerror'], iface['recv_latency']))

def print_delta(d):
    print('Duration:', d['duration'])
    print('# Tx/pps   Tx/bps      Rx/pps   Rx/bps      Rx#error   RxLatency')
    for i, iface in enumerate(d['interfaces']):
        print('{} {: <8} {: <11} {: <8} {: <11} {: <10} {: <9}'.format(
              i, int(iface['send_pps']), int(iface['send_bps']),
              int(iface['recv_pps']), int(iface['recv_bps']),
              iface['recv_nerror'], iface['recv_latency']))
    print('T {: <8} {: <11} {: <8} {: <11} {: <10} {: <9}'.format(
          int(d['send_pps']), int(d['send_bps']),
          int(d['recv_pps']), int(d['recv_bps']),
          d['recv_nerror'], d['recv_latency']))

def test(duration=1.0, sample_interval=0.1):
    begin = datetime.datetime.now()
    begin_sample = sample()
    s = begin_sample
    last_sample = None
    latency = []
    while (datetime.datetime.now() - begin).total_seconds() < duration:
        time.sleep(sample_interval)
        last_sample, s = s, sample()
        for iface in s['interfaces']:
            latency.append(iface['recv_latency'])
        print_delta(sample_delta(last_sample, s))
    end_sample = sample()
    for iface in end_sample['interfaces']:
            latency.append(iface['recv_latency'])
    result = sample_delta(begin_sample, end_sample)
    result['recv_latency'] = sum(latency) / len(latency)
    return result

def test_all(name='results'):
    with open(f'{name}.csv', 'w') as f:
        f.write('Packet Length,Throughput,Latency\n')
        for packet_len in [46, 128, 256, 512, 1024, 1500]:
            for i in range(NINTERFACES):
                set_interface(i, packet_len=packet_len + 14)
            reset_counters()
            time.sleep(1.0)
            print('Packet Length:', packet_len)
            d = test()
            print_delta(d)
            f.write('{},{},{}\n'.format(packet_len, d['recv_bps'] / 1e9, d['recv_latency'] * 1e6))

def plot_test_all(name='results'):
    sb.set_theme(style='whitegrid', font='DejaVu Serif', font_scale=1.2)
    data = pandas.read_csv(f'{name}.csv')
    g = sb.catplot(data=data, kind='bar',
                   x='Packet Length', y='Throughput',
                   errorbar=None, palette='dark', legend=False, alpha=0.75, height=5)
    g.despine(left=True)
    g.set_axis_labels('Packet Length (bytes)', 'Throughput (Gbps)')
    g.set_xticklabels(rotation=0, horizontalalignment='center')
    g.fig.tight_layout()
    for ext in ['pdf', 'png', 'svg']:
        g.savefig(f'{name}-throughput.{ext}')

    g = sb.catplot(data=data, kind='bar',
                   x='Packet Length', y='Latency',
                   errorbar=None, palette='dark', legend=False, alpha=0.75, height=5)
    g.despine(left=True)
    g.set_axis_labels('Packet Length (bytes)', 'Latency (us)')
    g.set_xticklabels(rotation=0, horizontalalignment='center')
    g.fig.tight_layout()
    for ext in ['pdf', 'png', 'svg']:
        g.savefig(f'{name}-latency.{ext}')

def get_send_iface(i):
    send_iface = i + 1
    if send_iface == NINTERFACES:
        send_iface = 0
    return send_iface

def read_interface_ips(packed=False):
    interfaces = [[] for _ in range(NINTERFACES)]
    with open(os.path.dirname(DIR) + '/conf/testip.txt', 'r') as f:
        for l in f:
            if not l.strip():
                continue
            ip, nexthop_ip, nexthop_iface = l.strip().split()
            if packed:
                ip = ipaddress.IPv6Address(ip).packed
            interfaces[int(nexthop_iface)].append(ip)
    return interfaces

def test_ip(name='results'):
    set_interface(0, False, gap_len=int(SERVER_FREQ / 10000), use_var_ip_dst=False)
    set_interface(1, False, gap_len=int(SERVER_FREQ / 10000), use_var_ip_dst=False)
    set_interface(2, False, gap_len=int(SERVER_FREQ / 10000), use_var_ip_dst=False)
    set_interface(3, False, gap_len=int(SERVER_FREQ / 10000), use_var_ip_dst=False)

    interfaces = read_interface_ips()

    send_npackets = 0
    recv_npackets = 0
    for i, iface in enumerate(interfaces):
        send_iface = get_send_iface(i)
        begin_sample = sample()
        for ip in iface:
            set_interface(send_iface, True, ip_dst=ip, packet_len=random.randint(46, 1500) + 14)
            time.sleep(1 / 10000)
        set_interface(send_iface, False)
        time.sleep(0.1)
        end_sample = sample()
        send_npackets += end_sample['interfaces'][send_iface]['send_npackets'] \
                         - begin_sample['interfaces'][send_iface]['send_npackets']
        recv_npackets += end_sample['interfaces'][i]['recv_npackets'] \
                         - begin_sample['interfaces'][i]['recv_npackets']
        print_delta(sample_delta(begin_sample, end_sample))
    ratio = recv_npackets / send_npackets if send_npackets else 1.0
    print('{}%'.format(ratio * 100))
    return ratio

def next_power_of_2(x):
    if x == 0:
        return 0
    return 1 << (x - 1).bit_length()

def download_ip(lfsr=True):
    interfaces = read_interface_ips(True)

    print('Downloading the destination IP addresses to the tester...')
    for i, ips in enumerate(interfaces):
        ips += ips[:next_power_of_2(len(ips)) - len(ips)]
        send_iface = get_send_iface(i)
        set_interface(send_iface, False)
        if ips:
            set_interface(send_iface, use_var_ip_dst=True, use_lfsr_ip_dst=lfsr,
                          ip_dst_ptr=0x2aa4a59850c62789 if lfsr else 0,
                          ip_dst_ptr_mask=len(ips) - 1)
        for j, ip in tqdm.tqdm(list(enumerate(ips))):
            write_ip_dst(send_iface, j, ip)

def test_ip_strict(lfsr=True):
    interfaces = read_interface_ips(True)

    for i, ips in enumerate(interfaces):
        send_iface = get_send_iface(i)
        set_interface(send_iface, False)
        if ips:
            set_interface(send_iface, use_var_ip_dst=True, use_lfsr_ip_dst=lfsr,
                          ip_dst_ptr=0x2aa4a59850c62789 if lfsr else 0,
                          ip_dst_ptr_mask=next_power_of_2(len(ips)) - 1)

    print('Testing (per interface)...')
    ratios = [0.0] * NINTERFACES
    for i, ips in enumerate(interfaces):
        send_iface = get_send_iface(i)
        if ips:
            set_interface(send_iface, True, None, None, 46 + 14, 0)
        begin_sample = sample()
        time.sleep(1)
        end_sample = sample()
        set_interface(send_iface, False)
        print_delta(sample_delta(begin_sample, end_sample))
        send_npackets = end_sample['interfaces'][send_iface]['send_npackets'] \
                        - begin_sample['interfaces'][send_iface]['send_npackets']
        recv_npackets = end_sample['interfaces'][i]['recv_npackets'] \
                        - begin_sample['interfaces'][i]['recv_npackets']
        ratios[i] = recv_npackets / send_npackets if send_npackets else 1.0
    print(' '.join(map(lambda r: str(r * 100) + '%', ratios)))

    print('Testing (all interfaces)...')
    for i, ips in enumerate(interfaces):
        send_iface = get_send_iface(i)
        if ips:
            set_interface(send_iface, True, None, None, 46 + 14, 0)
    begin_sample = sample()
    time.sleep(3)
    end_sample = sample()
    for i in range(NINTERFACES):
        set_interface(i, False)
    print_delta(sample_delta(begin_sample, end_sample))
    send_npackets = 0
    recv_npackets = 0
    for i in range(NINTERFACES):
        send_iface = get_send_iface(i)
        send_npackets += end_sample['interfaces'][send_iface]['send_npackets'] \
                         - begin_sample['interfaces'][send_iface]['send_npackets']
        recv_npackets += end_sample['interfaces'][i]['recv_npackets'] \
                         - begin_sample['interfaces'][i]['recv_npackets']
    ratio = recv_npackets / send_npackets if send_npackets else 1.0
    print('{}%'.format(ratio * 100))
    return ratio


print('Current Ticks:', read_reg(REGID_TICKS))
print('Scratch:', read_reg(REGID_SCRATCH))
begin_ticks = read_reg(REGID_TICKS)
time.sleep(1.0)
end_ticks = read_reg(REGID_TICKS)
print('Estimated Frequency:', end_ticks - begin_ticks, 'Hz')

if __name__ == '__main__':
    set_interface(0, False, mac='8C-1F-64-69-10-01')
    set_interface(1, False, mac='8C-1F-64-69-10-02')
    set_interface(2, False, mac='8C-1F-64-69-10-03')
    set_interface(3, False, mac='8C-1F-64-69-10-04')

    #set_interface(0, gateway='2a0e:aa06:497::1')
    #set_interface(1, gateway='2a0e:aa06:497:1::1')
    #set_interface(2, gateway='2a0e:aa06:497:2::1')
    #set_interface(3, gateway='2a0e:aa06:497:3::1')

    regid_base = (0 << REGID_IFACE_SHIFT) | (1 << REGID_IFACE_FLAG)
    write_reg(REGID_SAMPLE, 1)
    print(hex(read_reg(regid_base + REGID_IP_DST_PTR)))
    set_interface(0, use_var_ip_dst=True, use_lfsr_ip_dst=False, ip_dst_ptr=0xfff, ip_dst_ptr_mask=0)
    set_interface(1, use_var_ip_dst=True, use_lfsr_ip_dst=True, ip_dst_ptr_mask=3)
    print(hex(read_reg(regid_base + REGID_CONF_USE_VAR_IP_DST)))
    write_reg(REGID_SAMPLE, 1)
    print(hex(read_reg(regid_base + REGID_IP_DST_PTR)))
    write_reg(REGID_SAMPLE, 1)
    print(hex(read_reg(regid_base + REGID_IP_DST_PTR)))

    write_ip_dst(0, 0, b'1abcdefg2abcdefg')
    write_ip_dst(0, 1, b'3abcdefg4abcdefg')
    write_ip_dst(1, 0, b'5abcdefg6abcdefg')
    write_ip_dst(1, 1, b'7abcdefg8abcdefg')
    print(read_ip_dst(0, 0))
    print(read_ip_dst(0, 1))
    print(read_ip_dst(1, 0))
    print(read_ip_dst(1, 1))

    set_interface(0, True, '2a0e:aa06:497::2', None, 46 + 14, 0)
    set_interface(1, True, '2a0e:aa06:497:1::2', None, 46 + 14, 0)
    set_interface(2, True, '2a0e:aa06:497:2::2', None, 46 + 14, 0)
    set_interface(3, True, '2a0e:aa06:497:3::2', None, 46 + 14, 0)

    input()
    write_reg(REGID_SAMPLE, 1)
    print(hex(read_reg(regid_base + REGID_IP_DST_PTR)))
    set_interface(0, ip_dst_ptr_mask=1)
    input()
    set_interface(0, ip_dst_ptr_mask=3)
    input()
    set_interface(0, use_lfsr_ip_dst=True)
    exit(0)

    set_interface(0, True, '2a0e:aa06:497::2', '2a0e:aa06:497:1::2', 46 + 14, 0)
    set_interface(1, True, '2a0e:aa06:497:1::2', '2a0e:aa06:497::2', 46 + 14, 0)
    set_interface(2, True, '2a0e:aa06:497:2::2', '2a0e:aa06:497:3::2', 46 + 14, 0)
    set_interface(3, True, '2a0e:aa06:497:3::2', '2a0e:aa06:497:2::2', 46 + 14, 0)

    test_all()
    plot_test_all()

    set_interface(0, False)
    set_interface(1, False)
    set_interface(2, False)
    set_interface(3, False)

    print('Press ENTER to test various destination IP addresses...')
    input()
    print('Testing various destination IP addresses...')

    test_ip()

    set_interface(0, False)
    set_interface(1, False)
    set_interface(2, False)
    set_interface(3, False)