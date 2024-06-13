# Quectel Module Setup on ARI robot

Configure the dongle to be in qmi mode
```
at+qcfg="usbnet",0
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
