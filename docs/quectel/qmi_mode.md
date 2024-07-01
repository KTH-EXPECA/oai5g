# Run Quectel in QMI mode

Switch to QMI mode by running the following AT command:
```
at+qcfg="usbnet",0
```
Unplug and replug the quectel module USB cable.

Download and install the driver
```
wget https://api.oaibox.com/downloads/quectel/Quectel_QConnectManager_Linux_V1.6.5.1.zip
unzip Quectel_QConnectManager_Linux_V1.6.5.1.zip
cd quectel-CM
make
```

Create a new screen session to run the driver
```
screen -S quectel
cd quectel-CM/out
./quectel-CM
```
Wait until the ip is assigned (takes up to 20 sec), read the gateway address e.g. `10.0.0.13` in this example:
```
udhcpc: started, v1.27.2
udhcpc: sending discover
udhcpc: sending select for 10.0.0.14
udhcpc: lease of 10.0.0.14 obtained, lease time 7200
[07-01_18:44:53:704] ip -4 address flush dev wwp0s20f0u2i4
[07-01_18:44:53:706] ip -4 address add 10.0.0.14/30 dev wwp0s20f0u2i4
[07-01_18:44:53:709] ip -4 route add default via 10.0.0.13 dev wwp0s20f0u2i4
```

Detach from the screen by `Ctrl+A` and then `d`.

Add the route to ext-dn via `10.0.0.13` or whichever IP you read from previous step.
```
sudo ip route add 192.168.70.128/26 via 10.0.0.13
```

Whenever needed, resume the screen session by
```
screen -r quectel
```

Whenever needed, kill the screen session by `Ctrl+A` and then `k`.
