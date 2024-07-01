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
Wait until the ip is assigned (takes up to 20 sec)

Detach from the screen by `Ctrl+A` and then `d`.

Wheneve needed, resume the screen session by
```
screen -r quectel
```

Wheneve needed, kill the screen session by `Ctrl+A` and then `k`.
