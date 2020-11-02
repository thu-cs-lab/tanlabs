#!/usr/bin/env python3

import socket
import struct
import time

SERVER_IP = '10.8.8.100'
SERVER_PORT = 60000

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.connect((SERVER_IP, SERVER_PORT))

def read_reg(regid):
    sock.send(struct.pack('>QQ', regid, 0))
    resp = sock.recv(16)
    resp_regid, regvalue = struct.unpack('>QQ', resp)
    if resp_regid != regid:
        print('no such register', regid)
    return regvalue

def write_reg(regid, regvalue):
    sock.send(struct.pack('>QQ', regid | (1 << 63), regvalue))
    resp = sock.recv(16)
    resp_regid, regvalue = struct.unpack('>QQ', resp)
    if resp_regid != regid:
        print('no such register', regid)

print(read_reg(7777))
print(read_reg(1))
print(read_reg(2))
write_reg(2, 1234567890)
print(read_reg(7777))
print(read_reg(1))
print(read_reg(2))

begin_ticks = read_reg(1)
time.sleep(1.0)
end_ticks = read_reg(1)
print(end_ticks - begin_ticks)
