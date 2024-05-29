# How to connect a Quectel module to the OAI 5G network

We use the [RM500Q-GL 5G HAT COTS UE](https://www.waveshare.com/wiki/RM500Q-GL_5G_HAT) as our COTS UE which uses the [Quectel RM502Q-AE 5G module](https://www.quectel.com/product/5g-rm50xq-series/)

We connect it via USB3 to an Ubuntu 20.04 system

We program the [blue sysmocom SIM cards](https://osmocom.org/projects/cellular-infrastructure/wiki/SysmoISIM-SJA5) to register it to our OAI 5G SA network

## 1) Set up OAI 5G CN and OAI gNB at the same Ubuntu PC

Follow the instructions in [NR_SA_Tutorial_OAI_5CN5G](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_OAI_CN5G.md)

Follow the instructions in sections 3.1 and 3.2 and 4.1 and 4.2 in [NR_SA_Tutorial_COTS_UE](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md)

In section 3.1, use ```git checkout v4.3.0.0``` instead of ```git checkout v4.6.0.0```

## 2) Bring up the 5G network

At the Ubuntu PC that hosts both the OAI CN5G and OAI gNB, go to the ```oai-cn5g``` directory, in our case:

```
cd /home/wlab/COTS_UE_GUIDE/oai-cn5g
```

Start the OAI CN5G:

```
docker compose up -d
```

The OAI CN5G is stopped by issuing ```docker compose up -d```

Next, go to the directory that contains the ```nr-softmodem``` file, in our case:

```
cd /home/wlab/COTS_UE_GUIDE/custom-openairinterface5g/cmake_targets/ran_build/build
```

Start the OAI gNB:

```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf --sa -E --continuous-tx
```

## 3) Program the sysmocom SIM cards

Clone the following repository from Symcom:

```
git clone https://gitea.osmocom.org/sim-card/pysim.git
cd pysim
```

Take a photo of the SIM card

Insert it at the SIM card reader (gold side of the chip must be close to the HID logo of the reader)

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
- The argument of `n` sets the provider's name (same for all simcards)
- The argument of `-k` sets the KI of the SIM card (matches the entries in ```oai-cn5g/database/oai_db.sql```, same for all SIM cards)
- The argument of `-o` sets the OPC of the SIM card (matches the entries in ```oai-cn5g/database/oai_db.sql```, same for all SIM cards)
- The argument of `-acc` sets the ACC (we set it as in [NR_SA_Tutorial_COTS_UE](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md), same for all SIM cards)

More info regarding the arguments of the previous command can be found in [PySim-prog](https://osmocom.org/projects/pysim/wiki/PySim-prog)

An example file of the authentication database is in [oai_db.sql](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/tutorial_resources/oai-cn5g/database/oai_db.sql?ref_type=heads)

For our particular setup, the format of the command to program the SIM card is:

```
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a *ADM* -s *ICCID* -i 0010100000000*xx* -x 001 -y 01 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```

Log the issued command, the old IMSI and the new IMSI for bookkeeping purposes

Add new IMSI to the two tables in the ```oai-cn5g/database/oai_db.sql``` file and adjust the static IP address

Add a new entry to  the ```oai-cn5g/conf/users.conf``` file

Insert SIM card into Quectel module

## 4) Configure Quectel module

We need to configure the quectel module via [AT commands](https://files.waveshare.com/upload/7/78/Quectel_RG50xQ_RM5xxQ_Series_AT_Commands_Manual_V1.2.pdf)

We issue the AT commands via [python scripts](https://github.com/KTH-EXPECA/openairinterface5g-docs/tree/main/docs/quectel)

Create a folder called mkdir and then download the previous scripts in it:

```
mkdir quectel
cd quectel
```

Create a Python virtual enviroment and activate it:

```
python -m virtualenv venv
source venv/bin/activate
pip install pyserial
```

At the Ubuntu PC where the module is connected, turn the module into ECM mode:

```
sudo ./venv/bin/python makeECM.py
```
The above command issues ```at+qcfg="usbnet",1``` via the python script

Unplug the USB cable, replug it and check the IP interfaces:

```
ip a
```

A new interface with a name starting with "ex" should appear with an IP address of the form "192.168.225.xx"

If the IP didnt show up, probably needs to be set manually via netplan:
```
    enp0s20f0u1i4:
      dhcp4: no
      addresses: [192.168.225.37/24]
      gateway4: 192.168.225.1
```

In that case, the Quectel IP address on the USB interface is  "192.168.225.1"

The above setup allows the exchange of IP traffic between the Quectel module and the Ubuntu PC via the USB cable

Set the PDP context to enable data exchange via the 5G network:

```
cd ~/quectel
sudo ./venv/bin/python set_conf.py 
```

The above command issues  ```at+cgdcont=1,"IP","oai"``` via the python script

The above command must be issued whenever a SIM card is inserted into the Quectel module

Reboot the radio module:

```
sudo ./venv/bin/python off.py 
sudo ./venv/bin/python on.py 
```

The above commands issue ```at+cfun=0``` and ```at+cfun=1``` respectively

Check the 5G connection to see if the Quectel module gets an IP address for communication with the gNB:

```
sudo ./venv/bin/python get_ip.py
```

Typically this 5G IP should be of the form "10.0.0.x"

At this point, the text "LCID 4" should be printed at the terminal in the Ubuntu PC where the gNB is launched

Text "LCID 4" stands for the logical channel ID 4 in 5G which is the dedicated traffic channel that carries data between the UE and the gNB  

If text "LCID 4" is not printed, then no data can be sent between the UE and the gNB

Possible fixes: re-run "set_conf.py", reboot Quectel module, reboot gNB, reboot CN5G 

## 6)  Reach the ext-dn of the 5G CN to run ping and iperf tests

At the Ubuntu PC where the module is connected, issue the following command:

```
sudo ip route add 192.168.70.128/26 via 192.168.225.1
```

The above command needs to be re-issued whenever the Ubuntu PC is rebooted

Now you should be able to ping the ext-dn at "192.168.70.135" from the Ubuntu PC where the Quectel module is connected:

```
ping 192.168.70.135
```

Create an iperf3 server at the Ubuntu PC where the OAI-CN5G is hosted:

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

The downlink bitrate should be around 80 Mbps and the uplink bitrate should be around 15 Mbps

## 7) Run OpenRTiST on the 5G netwowrk


# 7a) Set up the OpenRTiST server

The OpenRTiST server is hosted by the Ubuntu PC that hosts the 5G gNB and CN

Download the OpenRTiST repository:

```
git clone https://github.com/cmusatyalab/openrtist.git
cd openrtist/server
```

Create a Python3.7 virtual enviroment and activate it:

```
python3.7 -m venv venv
source venv/bin/activate
```

Install OpenRTiST server dependencies:

```
pip install -r requirements.txt
```

Run the server with --timing argument to see performance on terminal:

```
python main.py --timing
```

Open a new terminal and check the ip address of the demo-oai interface:

```
ip a
```

In our case, it is "192.168.70.129", we use this IP address later on


# 7b) Set up the OpenRTiST server

The OpenRTiST client is hosted by the Ubuntu PC where the Quectel module is connected

Download the customized OpenRTiST repository that uses a video file and timestamps frames:

```
git clone https://github.com/samiemostafavi/openrtist.git
cd openrtist/python-client
```

Create a Python3.8 virtual enviroment and activate it:

```
python3.8 -m venv venv
source venv/bin/activate
```

Install "poetry" and then use it to install the OpenRTiST client dependencies:

```
pip install poetry
poetry install
```

Set the "QT_QPA_PLATFORM" variable to offscreen to avoid display errors:

```
export QT_QPA_PLATFORM=offscreen
```

Add a route to the "demo-oai" interface of the Ubuntu PC that hosts the OpenRTiST server:

```
sudo ip route add 192.168.70.129/32 via 192.168.225.1
```

The above command uses "192.168.70.129" since that is the IP address of the "demo-oai" interface in our case

Run the OpenRTiST client to connect to the OpenRTiST server via the 5G network:

```
./src/openrtist/sinfonia_wrapper.py -v ./Big_Buck_Bunny_1080_10s_5MB.mp4 -c 192.168.70.129:9099 -o ./res.json --quiet True -u 100
```

- The argument of `-v` selects the video file
- The argument of `-c` sets the OpenRTiST server IP address and port (it is of the form "demo-oai IP address":9099)
- The argument of `-o` creates a file that logs performance metrics such as frame roundtrip delay 
- The argument of `--quiet` selects the display mode (if "True" then display is off)
- The argument of `-u` sets the playback duration (loops the video file if duration exceeds duration of video file)
