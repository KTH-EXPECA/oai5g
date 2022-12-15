# oai5g-docker

## Core Network

Execution order and conditions:

On worker-3, we choose interface `ens5f0`
network: 192.168.70.128/26

1. mysql
	```
	name: 5gcn-mysql
	image: samiemostafavi/expeca-mysql
	ip: 192.168.70.131/26
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.131/26
	```
2. nrf
	```
	name: 5gcn-nrf
	image: samiemostafavi/expeca-nrf
	ip: 192.168.70.130
	environment variables: NRF_INTERFACE_NAME_FOR_SBI=net1
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.130/26
	```
3. udr
	```
	name: 5gcn-udr
	image: samiemostafavi/expeca-udr
	ip: 192.168.70.136
	environment variables: UDR_INTERFACE_NAME_FOR_NUDR=net1,USE_FQDN_DNS=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.136/26
	```
4. udm
	```
	name: 5gcn-udm
	image: samiemostafavi/expeca-udm
	ip: 192.168.70.137
	environment variables: SBI_IF_NAME=net1,USE_FQDN_DNS=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.137/26
	```
5. ausf
	```
	name: 5gcn-ausf
	ip: 192.168.70.138
	image: samiemostafavi/expeca-ausf
	environment variables: SBI_IF_NAME=net1,USE_FQDN_DNS=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.138/26
	```
6. amf
	```
	name: 5gcn-amf
	ip: 192.168.70.132
	image: samiemostafavi/expeca-amf
	environment variables: AMF_INTERFACE_NAME_FOR_NGAP=net1,AMF_INTERFACE_NAME_FOR_N11=net1,USE_FQDN_DNS=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.132/26
	```
7. smf
	```
	name: 5gcn-smf
	ip: 192.168.70.133
	image: samiemostafavi/expeca-smf
	environment variables: USE_FQDN_DNS=no,SMF_INTERFACE_NAME_FOR_N4=net1,SMF_INTERFACE_NAME_FOR_SBI=net1
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.133/26
	```
8. spgwu
	
	This service is responsible for the 5G egress point. It must be running with more capabalities and permissions compared to the other services:
	```
	cap_add:
	    - NET_ADMIN
	    - SYS_ADMIN
	cap_drop:
	    - ALL
	privileged: true
	```
	Create the container in Openstack with the following parameters
	```
	name: 5gcn-spgwu
	ip: 192.168.70.134
	image: samiemostafavi/expeca-spgwu
	environment variables: SGW_INTERFACE_NAME_FOR_S1U_S12_S4_UP=net1,SGW_INTERFACE_NAME_FOR_SX=net1,PGW_INTERFACE_NAME_FOR_SGI=net1,USE_FQDN_NRF=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.134/26,capabilities.privileged=true,capabilities.add.1=NET_ADMIN,capabilities.add.2=SYS_ADMIN,capabilities.drop.1=ALL
	```
	
## Radio Access Network

### Build containers

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

Modify the file `docker/scripts/generateTemplate.py` and replace `gnb.sa.band78.fr1.51PRB.usrpb210.conf` with `gnb.sa.band78.fr1.106PRB.usrpb210.conf`.

Make sure you use `USE_SA_TDD_MONO_B2XX` env variable. Then the entrypoint file at `docker/scripts/gnb_entrypoint.sh` kicks in and creates the config file when the container starts. 

Build the RAN containers
```
cd ~/openairinterface
docker build --target ran-base --tag ran-base:latest --file docker/Dockerfile.base.ubuntu18 .
docker build --target ran-build --tag ran-build:latest --file docker/Dockerfile.build.ubuntu18 .
docker build --target oai-gnb --tag oai-gnb:latest --file docker/Dockerfile.gNB.ubuntu18 .
docker build --target oai-nr-ue --tag oai-nr-ue:latest --file docker/Dockerfile.nrUE.ubuntu18 .
```

Tag and push them
```
docker tag oai-gnb:latest samiemostafavi/expeca-oai-gnb:latest
docker tag oai-nr-ue:latest samiemostafavi/expeca-oai-nr-ue:latest
docker image push samiemostafavi/expeca-oai-gnb:latest
docker image push samiemostafavi/expeca-oai-nr-ue:latest
```
	
### Run gnodeb
	
Make sure the following env variables are set when running the container:
```
USE_SA_TDD_MONO_B2XX=
GNB_ID=
GNB_NAME=
MCC=
MNC=
MNC_LENGTH=
TAC=
NSSAI_SST=
NSSAI_SD=
AMF_IP_ADDRESS=
GNB_NGA_IF_NAME=
GNB_NGA_IP_ADDRESS=
GNB_NGU_IF_NAME=
GNB_NGU_IP_ADDRESS=
SDR_ADDRS=
THREAD_PARALLEL_CONFIG=
```
Env variables example in one line:
```
USE_SA_FDD_MONO=yes,GNB_ID=e00,GNB_NAME=gNB-OAI,MCC=001,MNC=01,MNC_LENGTH=2,TAC=1,NSSAI_SST=1,NSSAI_SD=1,AMF_IP_ADDRESS=192.168.70.132,GNB_NGA_IF_NAME=net1,GNB_NGA_IP_ADDRESS=192.168.70.139,GNB_NGU_IF_NAME=net1,GNB_NGU_IP_ADDRESS=192.168.70.139,SDR_ADDRS=addr=10.40.3.1,THREAD_PARALLEL_CONFIG=PARALLEL_SINGLE_THREAD
```

Labels:
```
networks.1.interface=ens5f0,networks.1.ip=10.40.2.1/16,capabilities.privileged=true,resources.limits.memory=15000Mi,resources.limits.cpu=12,resources.requests.memory=15000Mi,resources.requests.cpu=12
```

Do not use `USE_B2XX`, `USE_X3XX`, or `USE_N3XX` if the container does not have access to internet.
	
### Run nrUE
	

