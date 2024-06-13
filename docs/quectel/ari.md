# Quectel Module Setup on ARI robot

Configure the dongle to be in qmi mode
```
at+qcfg="usbnet",0
```

Install busybox and udhcpc
```
sudo apt-get install udhcpc
```

Make, install and run the driver
```
wget https://api.oaibox.com/downloads/quectel/Quectel_QConnectManager_Linux_V1.6.5.1.zip
unzip Quectel_QConnectManager_Linux_V1.6.5.1.zip
cd quectel-CM/
make
cd out
sudo ./quectel-CM
```

The driver adds to the default route. Delete it to avoid conflict.
```
sudo ip route del default
```
