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
