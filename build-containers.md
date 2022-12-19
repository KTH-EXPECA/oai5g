# Build 5G Containers

The building blocks of our 5g network are containers.


## Radio Access Network

### GNodeB

Make sure that the config file `gnb.sa.band78.fr1.106PRB.usrpb210.conf` is modified with `sdr_addrs` in it. In addition to that, `usrp_lib.c` must be modified as well to work with E320 SDRs.

Copy the conf file to ci-scripts folder
```
cp targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf ci-scripts/conf_files/
```

Modify the following block in the file `docker/scripts/gnb_parameters.yaml`. Change the number of PRBs from 51 to 106, change `outputfilename`, and add `key: sdr_addrs` to the configs. Make sure you delete the other `filePrefix` with `outputfilename: "gnb.sa.fdd.conf"`
	
```
- filePrefix: gnb.sa.band78.fr1.106PRB.usrpb210.conf
  outputfilename: "gnb.sa.fdd.conf"
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
  - key: sdr_addrs
    env: "@SDR_ADDRS@"
  - key: parallel_config
    env: "@THREAD_PARALLEL_CONFIG@"
```

Make sure the following env variables are set when running the container:
```
USE_SA_TDD_MONO_B2XX
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
SDR_ADDRS
THREAD_PARALLEL_CONFIG
USE_ADDITIONAL_OPTIONS
```
Do not use `USE_B2XX`, `USE_X3XX`, or `USE_N3XX` if the container does not have access to internet.

Modify the file `docker/scripts/generateTemplate.py` and replace `gnb.sa.band78.fr1.51PRB.usrpb210.conf` with `gnb.sa.band78.fr1.106PRB.usrpb210.conf`.

Make sure you use `USE_SA_TDD_MONO_B2XX` env variable. Then the entrypoint file at `docker/scripts/gnb_entrypoint.sh` kicks in and creates the config file when the container starts. 

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

### NR-UE

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
