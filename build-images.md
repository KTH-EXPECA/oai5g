# Build 5G Network Images

The building blocks of our 5g network are containers. All components could be divided into:

1. Core Network (CN)
	1. MySQL
	2. NRF
	3. UDR
	4. UDM
	5. AUSF
	6. AMF
	7. SMF
	8. SPGWU
2. Radio Access Network (RAN)
	1. gNodeB
	2. nrUE


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

At ExPECA we use E320 USRP devices. These software-defined radios are very similar to B210. Hence, we use B210's configuration file as the reference.

Copy the conf file to ci-scripts folder and add the `sdr_addrs` to `RUs`.
```
cp targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf ci-scripts/conf_files/
vim ci-scripts/conf_files/gnb.sa.band78.fr1.106PRB.usrpb210.conf
cat ci-scripts/conf_files/gnb.sa.band78.fr1.106PRB.usrpb210.conf
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

Modify the block with `outputfilename: "gnb.sa.fdd.conf"` in the file `docker/scripts/gnb_parameters.yaml` as shown below
```
vim docker/scripts/gnb_parameters.yaml
```

1. Change `filePrefix` from `gnb.sa.band66.fr1.106PRB.usrpn300.conf` to `gnb.sa.band78.fr1.106PRB.usrpb210.conf`
2. Add `sdr_addrs` config
```
- key: sdr_addrs
  env: "@SDR_ADDRS@"
```

Modify `generateTemplate.py` file
```
vim docker/scripts/generateTemplate.py
```
Replace the following line in the `prefix_outputfile` dict:
```
"gnb.sa.band66.fr1.106PRB.usrpn300.conf": f'{data[0]["paths"]["dest_dir"]}/{outputfilename}',
```
with
```
"gnb.sa.band78.fr1.106PRB.usrpb210.conf": f'{data[0]["paths"]["dest_dir"]}/{outputfilename}',
```

Make sure you define `USE_SA_FDD_MONO` environment variable. Then according to `docker/scripts/gnb_entrypoint.sh` our desired config file will be created when the container starts.

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
USE_SA_FDD_MONO
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
