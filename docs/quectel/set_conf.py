#!/usr/bin/env python3


from serial import Serial

qcm = Serial('/dev/ttyUSB2', baudrate=115200, timeout=3)

on_cmd = "at+cgdcont=1,\"IP\",\"oai\"\r\n".encode()

print('# Switching ON quectel module ...')

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

