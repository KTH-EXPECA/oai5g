# Baremetal RAN

Clone repo and checkout `expeca-main` branch, commit `680da84`.
```
git clone git@github.com:KTH-EXPECA/openairinterface5g.git
cd openairinterface5g
git checkout expeca-main
```

Make sure python3.6 is installed and enabled in the environment.

Ask for building UHD 4.3.0.0 from source
```
export BUILD_UHD_FROM_SOURCE=True \
    && export UHD_VERSION=4.3.0.0
```

## Build
First step that builds the common libraries for RAN, needs to be run on both machines ( ue node and gnb node)
```
cd cmake_targets/
./build_oai -I -w USRP
```

Second step, builds specific executables for the radio. On UE node, run `--nrUE`, on gnb node run `--gNB`:
```
./build_oai -w USRP --gNB
./build_oai -w USRP --nrUE
```

Use `-c` to clean the workspace and start from the scratch
```
./build_oai -c -w USRP --gNB
```
Use `--enable-latseq` to enable LATSEQ latency measurement framework on the relevant branches.
```
./build_oai -w USRP --enable-latseq --gNB
```

## RUN

gNodeB
```
cd cmake_targets/ran_build/build
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpe320.conf --sa --usrp-tx-thread-config 1 -E --gNBs.[0].min_rxtxtime 6
```

NOTE: do not use `--continues-tx` option.

nrUE
```
cd cmake_targets/ran_build/build
sudo ./nr-uesoftmodem -r 106 --numerology 1 --band 78 -C 3619200000 --nokrnmod --sa -E --uicc0.imsi 001010000000001 --uicc0.nssai_sd 1 --usrp-args "mgmt_addr=10.30.10.80,addr=10.30.1.80" --ue-fo-compensation --ue-rxgain 120 --ue-txgain 0 --ue-max-power 0
```

Measure bandwidth
```
iperf3 -c 12.1.1.1 -u -b 100M --get-server-output
docker exec 5gcn-7-spgwu iperf3 -c 12.1.1.19 -u -b 100M --get-server-output
```

Measure latency
```
irtt client -i 10ms -d 15m -l 100 -o /home/wlab/irtt_data/sdr5g/rtts_0.json --fill=rand 12.1.1.1
```
or 
```
irtt client --tripm=oneway -i 10ms -f 5ms -g m1/feanor -l 100 -m 1 -d 10m -o d --outdir=/tmp/ 12.1.1.1
```


## Options

* Switch RLC to unacknowledged mode:
  ```
  --gNBs.[0].um_on_default_drb 1
  ```
* Set max number of harq retransmissions:
  ```
  --MACRLCs.[0].ul_harq_round_max 5
  --MACRLCs.[0].dl_harq_round_max 5
  ```
* Set max MCS index:
  ```
  --MACRLCs.[0].dl_max_mcs 28
  --MACRLCs.[0].ul_max_mcs 28
  ```
* Set UL configured grant:
  ```
  --MACRLCs.[0].min_grant_mcs 28
  --MACRLCs.[0].min_grant_prb 20
  ```

gBodeB run with options:
```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpe320.conf --sa --usrp-tx-thread-config 1 -E --gNBs.[0].min_rxtxtime 6 --MACRLCs.[0].ul_harq_round_max 5 --MACRLCs.[0].dl_harq_round_max 5 --MACRLCs.[0].dl_max_mcs 28 --MACRLCs.[0].ul_max_mcs 28 --MACRLCs.[0].min_grant_mcs 28 --MACRLCs.[0].min_grant_prb 20
```

More info: https://gitlab.eurecom.fr/oaiworkshop/summerworkshop2023/-/tree/main/ran#macrlcs-section

