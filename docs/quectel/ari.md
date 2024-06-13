# Quectel Module Setup on ARI robot

Make sure the dongle is in qmi mode
```
at+qcfg="usbnet",0
```

Make sure busybox and udhcpc are installed
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

Then check if you got IP on wwan0 like this:
```
8: wwan0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 1000
    link/none 
    inet 172.16.0.160/26 scope global wwan0
       valid_lft forever preferred_lft forever
    inet6 fe80::1872:ba86:62c3:2fd5/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
```

NOTE: if connection manager didnt work, unplug the dongle and replug it, right after wwan0 shows up, run `sudo ./quectel-CM` command.

The driver adds to the default route. Delete it to avoid conflict.
```
sudo ip route del default
```

Add edge network route
```
sudo ip route add 10.70.70.0/24 via 172.16.0.161
```

