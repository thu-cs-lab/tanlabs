#!/usr/bin/env python3

import binascii
import datetime
import ipaddress
import json
import pyroute2
import socket
import struct
import time

import pandas
import matplotlib.pyplot as plt
import seaborn as sb

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
REGID_IFACE_WIDTH = 3
REGID_IFACE_SHIFT = 8
REGID_IFACE_FLAG = REGID_IFACE_SHIFT + REGID_IFACE_WIDTH
REGID_CONF_ENABLE = 0
REGID_CONF_MAC = 1
REGID_CONF_MAC_DST = 2
REGID_CONF_IP_SRC_HI = 3
REGID_CONF_IP_SRC_LO = 4
REGID_CONF_IP_DST_HI = 5
REGID_CONF_IP_DST_LO = 6
REGID_CONF_PACKET_LEN = 7
REGID_CONF_GAP_LEN = 8
REGID_SEND_NBYTES = 9
REGID_SEND_NPACKETS = 10
REGID_RECV_NBYTES = 11
REGID_RECV_NBYTES_L3 = 12
REGID_RECV_NPACKETS = 13
REGID_RECV_NERROR = 14
REGID_RECV_LATENCY = 15

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

def set_interface(iface, enable=None, mac=None, mac_dst=None,
                  ip_src=None, ip_dst=None, packet_len=None, gap_len=None):
    regid_base = (iface << REGID_IFACE_SHIFT) | (1 << REGID_IFACE_FLAG)
    cp_iface = IFACE_PREFIX + str(iface)
    cp_netns = NETNS_PREFIX + str(iface)
    if mac is not None:
        mac = ensure_mac(mac)
        write_reg_raw(regid_base + REGID_CONF_MAC, mac)
        with pyroute2.NetNS(cp_netns) as ip:
            dev = ip.link_lookup(ifname=cp_iface)[0]
            ip.link('set', index=dev, address=':'.join('{:02x}'.format(b) for b in mac))
    if mac_dst is not None:
        write_reg_raw(regid_base + REGID_CONF_MAC_DST, ensure_mac(mac_dst))
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
            ip.addr('add', index=dev, address='fe80::' + str(iface + 1), prefixlen=64)
            ip.addr('add', index=dev, address=str(ip_src), prefixlen=64)  # FIXME: prefixlen
    if ip_dst is not None:
        ip_raw = ensure_ip(ip_dst).packed
        write_reg_raw(regid_base + REGID_CONF_IP_DST_HI, ip_raw[:8])
        write_reg_raw(regid_base + REGID_CONF_IP_DST_LO, ip_raw[8:])
    if packet_len is not None:
        write_reg(regid_base + REGID_CONF_PACKET_LEN, packet_len)
    if gap_len is not None:
        write_reg(regid_base + REGID_CONF_GAP_LEN, gap_len)
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
        f.write('Packet Length,Bandwidth,Latency\n')
        for packet_len in [46, 128, 256, 512, 1024, 1500]:
            for i in range(NINTERFACES):
                set_interface(i, packet_len=packet_len + 14)
            reset_counters()
            time.sleep(1.0)
            print('Packet Length:', packet_len)
            d = test()
            print_delta(d)
            f.write('{},{},{}\n'.format(packet_len, d['recv_bps'], d['recv_latency']))

    sb.set_theme(style='whitegrid', font='DejaVu Serif', font_scale=1.2)
    data = pandas.read_csv(f'{name}.csv')
    g = sb.catplot(data=data, kind='bar',
                   x='Packet Length', y='Bandwidth',
                   ci=None, palette='dark', legend=False, alpha=0.75, height=5)
    g.despine(left=True)
    g.set_axis_labels('Packet Length (bytes)', 'Bandwidth (bps)')
    g.set_xticklabels(rotation=0, horizontalalignment='center')
    g.fig.tight_layout()
    g.savefig(f'{name}-bandwidth.pdf')

    g = sb.catplot(data=data, kind='bar',
                   x='Packet Length', y='Latency',
                   ci=None, palette='dark', legend=False, alpha=0.75, height=5)
    g.despine(left=True)
    g.set_axis_labels('Packet Length (bytes)', 'Latency (s)')
    g.set_xticklabels(rotation=0, horizontalalignment='center')
    g.fig.tight_layout()
    g.savefig(f'{name}-latency.pdf')


print('Current Ticks:', read_reg(REGID_TICKS))
print('Scratch:', read_reg(REGID_SCRATCH))
begin_ticks = read_reg(REGID_TICKS)
time.sleep(1.0)
end_ticks = read_reg(REGID_TICKS)
print('Estimated Frequency:', end_ticks - begin_ticks, 'Hz')

set_interface(0, False)
set_interface(1, False)
set_interface(2, False)
set_interface(3, False)

# set_interface(0, True, '54:57:44:32:30:30', '54:57:44:32:30:31',
#               '2a0e:aa06:497::1', '2a0e:aa06:497:1::1', 46 + 14, 0)
# set_interface(1, True, '54:57:44:32:30:31', '54:57:44:32:30:30',
#               '2a0e:aa06:497:1::1', '2a0e:aa06:497::1', 46 + 14, 0)
# set_interface(2, True, '54:57:44:32:30:32', '54:57:44:32:30:33',
#               '2a0e:aa06:497:2::1', '2a0e:aa06:497:3::1', 46 + 14, 0)
# set_interface(3, True, '54:57:44:32:30:33', '54:57:44:32:30:32',
#               '2a0e:aa06:497:3::1', '2a0e:aa06:497:2::1', 46 + 14, 0)
# set_interface(3, True, '54:57:44:32:30:33', '00:12:1e:5e:40:22',
#               '2001:250:200:7::2', '2a0e:aa06:496:2::1', 46 + 14, 125000)

set_interface(0, True, '54:57:44:32:30:30', '54:57:44:32:5f:30',
              '2a0e:aa06:491::2', '2a0e:aa06:491:1::2', 46 + 14, 0)
set_interface(1, True, '54:57:44:32:30:31', '54:57:44:32:5f:31',
              '2a0e:aa06:491:1::2', '2a0e:aa06:491::2', 46 + 14, 0)
set_interface(2, True, '54:57:44:32:30:32', '54:57:44:32:5f:32',
              '2a0e:aa06:491:2::2', '2a0e:aa06:491:3::2', 46 + 14, 0)
set_interface(3, True, '54:57:44:32:30:33', '54:57:44:32:5f:33',
              '2a0e:aa06:491:3::2', '2a0e:aa06:491:2::2', 46 + 14, 0)

# set_interface(0, True, '54:57:44:32:30:30', '54:57:44:32:5f:30',
#               '2a0e:aa06:497::2', '2a0e:aa06:497:1::2', 46 + 14, 0)
# set_interface(1, True, '54:57:44:32:30:31', '54:57:44:32:5f:31',
#               '2a0e:aa06:497:1::2', '2a0e:aa06:497::2', 46 + 14, 0)
# set_interface(2, True, '54:57:44:32:30:32', '54:57:44:32:5f:32',
#               '2a0e:aa06:497:2::2', '2a0e:aa06:497:3::2', 46 + 14, 0)
# set_interface(3, True, '54:57:44:32:30:33', '54:57:44:32:5f:33',
#               '2a0e:aa06:497:3::2', '2a0e:aa06:497:2::2', 46 + 14, 0)

test_all()

set_interface(0, False)
set_interface(1, False)
set_interface(2, False)
set_interface(3, False)
