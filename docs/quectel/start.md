# How to Setup Quectel to connect to Openairinterface5G

We use the [RM500Q-GL 5G HAT COTS UE](https://www.waveshare.com/wiki/RM500Q-GL_5G_HAT) as our COTS UE which uses the [Quectel RM502Q-AE 5G module](https://www.quectel.com/product/5g-rm50xq-series/)

We connect it via USB3 to an Ubuntu 20.04 system

We program the [green sysmocom SIM cards](https://osmocom.org/projects/cellular-infrastructure/wiki/SysmoISIM-SJA5) to register it to our OAI 5G SA network

## 1) Set up OAI CN5G and OAI gNB at the same Ubuntu PC

Follow the instructions in [NR_SA_Tutorial_OAI_5CN5G](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_OAI_CN5G.md).

Follow the instructions in sections 3.1 and 3.2 and 4.1 and 4.2 in [NR_SA_Tutorial_COTS_UE](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md)

In section 3.1, use ```git checkout v4.3.0.0``` instead of ```git checkout v4.6.0.0```

## 2) Bring Up the 5G network

## 3) Program the sysmocom SIM cards

Clone the following repository from Symcom:

```
git clone https://gitea.osmocom.org/sim-card/pysim.git
```

Take a photo of the SIM card and insert it at the SIM card reader 

(Optional) Read a few details of the SIM card

```
./pySim-read.py -p0
```

An example command to program the SIM card is as follows:

```
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a 85017255 -x 001 -y 01 -i 001010000000001 -s 8988211000001139297 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```
- The argument of `-a` is the ADM value of the SIM card (found in the invoice of the SIM card)
- The argument of `-x` sets the MCC and of `-y` sets the MCN (must match the OAI setup, same for all SIM cards)
- The argument of `-i` sets the IMSI of the SIM card (matches the entries in "oai-cn5g/database/oai_db.sql", should vary)
- The argument of `-s` sets the ICCID of the SIM card (we set to its original value found in the invoice)
- The argument of `n` sets the targt provider's name (same for all simcards)
- The argument of `-k` sets the KI of the SIM card (matches the entries in ```oai-cn5g/database/oai_db.sql```, same for all SIM cards)
- The argument of `-o` sets the OPC of the SIM card (matches the entries in ```oai-cn5g/database/oai_db.sql```, same for all SIM cards)
- The argument of `-acc` sets the ACC (we set it as in [NR_SA_Tutorial_COTS_UE](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md), same for all SIM cards)

More info regarding the arguments of the previous command can be found in [PySim-prog](https://osmocom.org/projects/pysim/wiki/PySim-prog)

An example file of the authentication database is in [oai_db.sql](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/tutorial_resources/oai-cn5g/database/oai_db.sql?ref_type=heads)

For our particular setup, the format of the command to program the SIM card is:

```
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a *ADM* -s *ICCID* -i 0010100000000*xx* -x 001 -y 01 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```

Log the command and the old IMSI and the new IMSI for bookkeeping purposes

Add new IMSI at ```oai-cn5g/database/oai_db.sql``` file in the two tables and adjust the static IP address

Add a new entry at ```oai-cn5g/conf/users.conf``` file

Insert SIM card into Quectel module

## 4) Configure Quectel module

At the Ubuntu PC where the module is connected, set the PDP context:

```
cd ~/quectel
sudo python3 set_conf.py 
```

The above command executes  ```AT+CGDCONT=1,"IP","oai"``` via the ```set_conf.py``` python script

The above command must be issued whenever a SIM card is inserted into the Quectel module

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

## 5) Turn off the module

Turn off the radio module by running:
```
sudo python3 quectel_off.py
```
or the AT command
```
at+cfun=0
```

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

For the first time and whenever rebooting:

```
sudo ip route add 192.168.70.128/26 via 192.168.225.1
```
Now you should be able to ping the ext-dn at `192.168.70.135` from the UE host.

## 8) Check downlink and uplink bitrate for UE host

Create an iperf3 server at the Ubuntu PC where the OAICN5G is hosted:

```
docker exec -it oai-ext-dn iperf3 -s
```

(Downlink) Make the oai-ext-dn network function send traffic to UE for 20 seconds:

```
iperf3 -c  192.168.70.135 -R -t 20
```

(Uplink) Send traffic from UE to the oai-ext-dn network function for 20 seconds:

```
iperf3 -c 192.168.70.135 -t 20
```
