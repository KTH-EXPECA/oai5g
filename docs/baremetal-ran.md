# Baremetal RAN

Clone repo and checkout `expeca-main` branch, commit `680da84`.
```
git clone git@github.com:KTH-EXPECA/openairinterface5g.git
cd ~/openairinterface5g
git checkout expeca-main
```

Make sure python3.6 is installed and enabled in the environment.

Ask for building UHD 4.3.0.0 from source
```
export BUILD_UHD_FROM_SOURCE=True
export UHD_VERSION=4.3.0.0
```

Build
```
./build_oai -I -w USRP
./build_oai -w USRP --eNB --UE --nrUE --gNB
```
Use `-c` to clean the workspace and start from the scratch
```
./build_oai -c -w USRP --gNB
```


RUN

gNodeB
```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpe320.conf --sa --usrp-tx-thread-config 1 -E --gNBs.[0].min_rxtxtime 6
```

NOTE: do not use `--continues-tx` option.

nrUE
```
sudo ./nr-uesoftmodem -r 106 --numerology 1 --band 78 -C 3619200000 --nokrnmod --sa -E --uicc0.imsi 001010000000001 -uicc0.nssai_sd 1 --usrp-args "mgmt_addr=10.30.10.80,addr=10.30.1.80" --ue-fo-compensation --ue-rxgain 120 --ue-txgain 0 --ue-max-power 0
```
