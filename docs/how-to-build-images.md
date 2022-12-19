# Build 5G Network Images

## Build CN Images

We only take Openairinterface images and add the env variables to them except `SMF` where we need to add `spgwu` hostname since there is no DNS service running in this case.

```
git clone https://github.com/KTH-EXPECA/oai5g-docker.git
cd ~/oai5g-docker
chmod +x build_cn_images.sh
./build_cn_images.sh
```

## Build RAN Images

Download openairinterface and checkout to `develop`.
```
git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git ~/openairinterface5g
cd ~/openairinterface5g
git checkout develop
```

Apply the changes to `radio/USRP/USERSPACE/LIB/usrp_lib.cpp` according to [here](https://github.com/samiemostafavi/autoran/blob/main/docs/oai-e320.md) to make openairinterface recognize USRP E320.

### 1. gNodeB

At ExPECA we use USRP E320 devices. These software-defined radios are very similar to B210. Hence, we use B210's configuration file as the reference.

Copy the conf file to ci-scripts folder and add the `sdr_addrs` to `RUs`.
```
cp targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf ci-scripts/conf_files/gnb.sa.band78.fr1.106PRB.usrpe320.conf
vim ci-scripts/conf_files/gnb.sa.band78.fr1.106PRB.usrpe320.conf
...
RUs = (
{
  local_rf       = "yes"
  nb_tx          = 1
  nb_rx          = 1
  att_tx         = 12;
  att_rx         = 12;
  bands          = [78];
  max_pdschReferenceSignalPower = -27;
  max_rxgain                    = 114;
  eNB_instances  = [0];
  #beamforming 1x4 matrix:
  bf_weights = [0x00007fff, 0x0000, 0x0000, 0x0000];
  clock_src = "internal";
  sdr_addrs="mgmt_addr=10.10.3.3,addr=10.40.3.3";
}
);
```
Note: it is not important which addresses you choose here since they will be overwritten by environment variables later. Just make sure `sdr_addrs="whatever";` is there.

Modify `gnb_parameters.yaml` file
```
vim docker/scripts/gnb_parameters.yaml
```
Add the following block to it
```
  - filePrefix: gnb.sa.band78.fr1.106PRB.usrpe320.conf
    outputfilename: "gnb.sa.tdd.e320.conf"
    config:
    - key: gNB_ID
      env: "@GNB_ID@"
    - key: Active_gNBs
      env: "@GNB_NAME@"
    - key: gNB_name
      env: "@GNB_NAME@"
    - key: mcc
      env: "@MCC@"
    - key: mnc
      env: "@MNC@"
    - key: mnc_length
      env: "@MNC_LENGTH@"
    - key: tracking_area_code
      env: "@TAC@"
    - key: sst
      env: "@NSSAI_SST@"
    - key: sd
      env: "@NSSAI_SD@"
    - key: tracking_area_code
      env: "@TAC@"
    - key: ipv4
      env: "@AMF_IP_ADDRESS@"
    - key: GNB_INTERFACE_NAME_FOR_NG_AMF
      env: "@GNB_NGA_IF_NAME@"
    - key: GNB_IPV4_ADDRESS_FOR_NG_AMF
      env: "@GNB_NGA_IP_ADDRESS@"
    - key: GNB_INTERFACE_NAME_FOR_NGU
      env: "@GNB_NGU_IF_NAME@"
    - key: GNB_IPV4_ADDRESS_FOR_NGU
      env: "@GNB_NGU_IP_ADDRESS@"
    - key: att_tx
      env: "@ATT_TX@"
    - key: att_rx
      env: "@ATT_RX@"
    - key: max_rxgain
      env: "@MAX_RXGAIN@"
    - key: sdr_addrs
      env: "@SDR_ADDRS@"
    - key: parallel_config
      env: "@THREAD_PARALLEL_CONFIG@"
```

Modify `generateTemplate.py` file
```
vim docker/scripts/generateTemplate.py
```
Add the following line to the `prefix_outputfile` dict:
```
"gnb.sa.band78.fr1.106PRB.usrpe320.conf": f'{data[0]["paths"]["dest_dir"]}/{outputfilename}',
```

Modify `gnb_entrypoint.sh` file
```
vim docker/scripts/gnb_entrypoint.sh
```
Add this line after the line that starts with `if [[ -v USE_SA_TDD_MONO_B2XX ]];`:
```
if [[ -v USE_SA_TDD_MONO_E320 ]]; then cp $PREFIX/etc/gnb.sa.tdd.e320.conf $PREFIX/etc/gnb.conf; fi
```

Make sure you define `USE_SA_TDD_MONO_E320` environment variable. Then according to `docker/scripts/gnb_entrypoint.sh` our desired config file will be created when the container starts.

Modify UHD version in base Dockerfile
```
vim docker/Dockerfile.base.ubuntu18
```
Change 
```
ENV UHD_VERSION=3.15.0.0
```
to
```
ENV UHD_VERSION=4.3.0.0
```

Modify UHD version in gnb and ue Dockerfiles
```
vim docker/Dockerfile.gNB.ubuntu18
vim docker/Dockerfile.nrUE.ubuntu18
```
Change
```
COPY --from=gnb-base /usr/local/lib/libuhd.so.3.15.0 /usr/local/lib
```
to
```
COPY --from=gnb-base /usr/local/lib/libuhd.so.4.3.0 /usr/local/lib
```

Build the RAN containers
```
cd ~/openairinterface
docker build --target ran-base --tag ran-base:latest --file docker/Dockerfile.base.ubuntu18 .
docker build --target ran-build --tag ran-build:latest --file docker/Dockerfile.build.ubuntu18 .
docker build --target oai-gnb --tag oai-gnb:latest --file docker/Dockerfile.gNB.ubuntu18 .
```

Tag and push them
```
docker tag oai-gnb:latest samiemostafavi/expeca-oai-gnb:latest
docker tag oai-nr-ue:latest samiemostafavi/expeca-oai-nr-ue:latest
docker image push samiemostafavi/expeca-oai-gnb:latest
```

Then make sure the following environment variables are set when running the gnodeb container:
```
USE_SA_TDD_MONO_E320
GNB_ID
GNB_NAME
MCC
MNC
MNC_LENGTH
TAC
NSSAI_SST
NSSAI_SD
AMF_IP_ADDRESS
GNB_NGA_IF_NAME
GNB_NGA_IP_ADDRESS
GNB_NGU_IF_NAME
GNB_NGU_IP_ADDRESS
ATT_TX
ATT_RX
MAX_RXGAIN
SDR_ADDRS
THREAD_PARALLEL_CONFIG
USE_ADDITIONAL_OPTIONS
```
Do not use `USE_B2XX`, `USE_X3XX`, or `USE_N3XX` if the container does not have access to internet.

### 2. nrUE

Build the RAN containers. If you have built `ran-base` and `ran-build` images for `gnodeb`, skip them here.
```
cd ~/openairinterface
docker build --target ran-base --tag ran-base:latest --file docker/Dockerfile.base.ubuntu18 .
docker build --target ran-build --tag ran-build:latest --file docker/Dockerfile.build.ubuntu18 .
docker build --target oai-nr-ue --tag oai-nr-ue:latest --file docker/Dockerfile.nrUE.ubuntu18 .
```

Tag and push it
```
docker tag oai-nr-ue:latest samiemostafavi/expeca-oai-nr-ue:latest
docker image push samiemostafavi/expeca-oai-nr-ue:latest
```
