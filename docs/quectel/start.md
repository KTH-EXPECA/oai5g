# How to Setup Quectel RM502Q-AE connect to Openairinterface5G

We use the Waveshare 5G quectel module: https://www.waveshare.com/wiki/RM500Q-GL_5G_HAT

We connect it via USB3 to an Ubuntu 20.04 system.

First we start by writing a simcard for Openairinterface 5G.

## Writing the Symcom Sim Card

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

Run the command as:
```
./pySim-prog.py -p 0 -t sysmoISIM-SJA5 -a 85017255 -x 001 -y 01 -i 001010000000001 -s 8988211000001139297 -n OpenAirInterface -k fec86ba6eb707ed08905757b1bb44b8f -o C42449363BBAD02B66D16BC975D77CC1 --acc 0001
```

## Configure Quectel module

Next, we need to configure the quectel module via AT commands. For this purpose there are python scripts next to this markdown file.

