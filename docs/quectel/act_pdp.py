#!/usr/bin/env python3

from serial import Serial

qcm = Serial('/dev/ttyUSB2', baudrate=115200, timeout=3)

on_cmd = "at+cgact=1,1\r\n".encode()

print('# Activating PDP context on quectel module ...')

qcm.write(on_cmd)

while True:
    # read_until() reads until LF
    rdata = qcm.read_until().decode()
    if not rdata:
        # Timeout occured -> no more data to read
        break
    print(rdata)

print()
print('# Done!')
