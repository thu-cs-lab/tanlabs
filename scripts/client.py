#!/usr/bin/env python3

import binascii
import ipaddress
import json
import socket
import struct
import time

SERVER_IP = '10.8.8.100'
SERVER_PORT = 60000

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
    if mac is not None:
        write_reg_raw(regid_base + REGID_CONF_MAC, ensure_mac(mac))
    if mac_dst is not None:
        write_reg_raw(regid_base + REGID_CONF_MAC_DST, ensure_mac(mac_dst))
    if ip_src is not None:
        ip_raw = ensure_ip(ip_src).packed
        write_reg_raw(regid_base + REGID_CONF_IP_SRC_HI, ip_raw[:8])
        write_reg_raw(regid_base + REGID_CONF_IP_SRC_LO, ip_raw[8:])
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
    for i in range(4):
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
        iface['recv_latency'] = read_reg(regid_base + REGID_RECV_LATENCY)
        s['interfaces'].append(iface)
    return s

def print_sample(s):
    print('Sample Ticks:', s['ticks'])
    print('# En Tx#bytes    Tx#packets Rx#bytes    Rx#l3_bytes Rx#packets Rx#error   RxLatency')
    for i, iface in enumerate(s['interfaces']):
        print('{} {: <2} {: <11} {: <10} {: <11} {: <11} {: <10} {: <10} {: <9}'.format(
              i, int(iface['enable']), iface['send_nbytes'], iface['send_npackets'],
              iface['recv_nbytes'], iface['recv_nbytes_l3'], iface['recv_npackets'],
              iface['recv_nerror'], iface['recv_latency']))

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

set_interface(0, True, '54:57:44:32:30:30', '54:57:44:32:30:31',
              '2a0e:aa06:497::1', '2a0e:aa06:497:1::1', 46 + 14, 0)
set_interface(1, True, '54:57:44:32:30:31', '54:57:44:32:30:30',
              '2a0e:aa06:497:1::1', '2a0e:aa06:497::1', 46 + 14, 0)
set_interface(2, True, '54:57:44:32:30:32', '54:57:44:32:30:33',
              '2a0e:aa06:497:2::1', '2a0e:aa06:497:3::1', 46 + 14, 0)
set_interface(3, True, '54:57:44:32:30:33', '54:57:44:32:30:32',
              '2a0e:aa06:497:3::1', '2a0e:aa06:497:2::1', 46 + 14, 0)

reset_counters()
time.sleep(1.0)
print_sample(sample())

# exit(0)

while True:
    time.sleep(1.0)
    print_sample(sample())