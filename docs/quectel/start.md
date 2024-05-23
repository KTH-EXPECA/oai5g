# How to Setup Quectel to connect to Openairinterface5G

We use the Waveshare 5G quectel module: https://www.waveshare.com/wiki/RM500Q-GL_5G_HAT

We connect it via USB3 to an Ubuntu 20.04 system.

First we start by writing a simcard for Openairinterface 5G.

## 1) Set up OAI CN5G and OAI gNB

We run them on the same Ubuntu PC.

First, follow the instructions in [NR_SA_Tutorial_OAI_5CN5G](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_OAI_CN5G.md).


Second, follow the instructions *only* of sections 3.1 & 3.2 & 4.1 & 4.2 in [NR_SA_Tutorial_COTS_UE](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md)

*Note*: In Section 3.1, do not use git checkout v4.6.0.0, instead use "git checkout v4.3.0.0"

## 2) Write Symcom Sim Cards

The simacards we have are: https://osmocom.org/projects/cellular-infrastructure/wiki/SysmoISIM-SJA5

Clone the following repo from Symcom
```
git clone https://gitea.osmocom.org/sim-card/pysim.git
```

Insert the simcard first, the card reader blinks, and

- Read the ADM value from the invoice for each simcard, insert it after `-a`.
- Insert MCC after `-x` e.g. `001` and MNC after `-y` e.g. `01`, same for all simcards.
- Insert the Operator name after `-n` e.g. `OpenAirInterface`, same for all simcards.
- Insert IMSI after `-i` e.g. `001010000000001`, you have to increase the number for each sim e.g. `001010000000002` and `001010000000003`.
- Insert KI after `-k` and OPC `-o`, they should be the same for all simcards.
- Insert ICCID after `-s` by reading it for each simcard from the invoice.
- Insert Access control code (ACC) after `--acc` (not required but so far we followed openairinterface)

More info find here: https://osmocom.org/projects/pysim/wiki/PySim-prog

You can look at the entries in openairinterface sql database: https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/tutorial_resources/oai-cn5g/database/oai_db.sql?ref_type=heads
to get KI and OPC.

Run the command as:
```
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a 85017255 -x 001 -y 01 -i 001010000000001 -s 8988211000001139297 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```

## 3) Configure Quectel module

Next, we need to configure the quectel module via AT commands. For this purpose there are python scripts next to this markdown file.
You can check all the AT commands (here)[https://files.waveshare.com/upload/7/78/Quectel_RG50xQ_RM5xxQ_Series_AT_Commands_Manual_V1.2.pdf].

We turn the module into ECM mode first by:
```
sudo python3 quectel_makeECM.py
```
or the AT command
```
at+qcfg="usbnet",1
```
Then, unplug the USB cable and replug it. The ECM driver kicks in and you should see a new interface e.g. `ex...`.

## 4) Turn off the module

Turn off the radio module by running:
```
sudo python3 quectel_off.py
```
or the AT command
```
at+cfun=0
```

## 5) Bring Up the 5G network

## 6) Turn on the module

Turn on the radio module by running:
```
sudo python3 quectel_on.py
```
or the AT command
```
at+cfun=1
```
You should see the connection happening and then run the following to check the connection and ip address:
```
sudo python3 quectel_get_ip.py
```
On the host though you will see a different ip address, e.g.
```
192.168.225.37/24
```
In this case the quectel IP address will be
```
192.168.225.1
```

## 7) Add the routing command to reach ext-dn
```
sudo ip route add 192.168.70.128/26 via 192.168.225.1
```
Now you should be able to ping the ext-dn at `192.168.70.135` from the UE host.

## 8) Check downlink and uplink bitrate for UE host

Create an iperf3 server at the Ubuntu PC where the OAICN5G is hosted:

```
docker exec -it oai-ext-dn iperf3 -s
```

(DOWLINK) Make the oai-ext-dn network function send traffic to UE for 20 seconds:

```
iperf3 -c -R 192.168.70.135 -t 20
```

(UPLINK) Send traffic from UE to the oai-ext-dn network function for 20 seconds:

```
iperf3 -c 192.168.70.135 -t 20
```
