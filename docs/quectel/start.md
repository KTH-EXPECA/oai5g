# How to Setup Quectel RM502Q-AE connect to Openairinterface5G

We use the Waveshare 5G quectel module: https://www.waveshare.com/wiki/RM500Q-GL_5G_HAT

We connect it via USB3 to an Ubuntu 20.04 system.

First we start by writing a simcard for Openairinterface 5G.

## Writing the Sim Card

```
git clone https://gitea.osmocom.org/sim-card/pysim.git
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a 85017255 -x 001 -y 01 -i 001010000000001 -s 8988211000001139297 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```



Next, we need to configure the quectel module via AT commands. For this purpose there are python scripts next to this markdownfile.

## 
