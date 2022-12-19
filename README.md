# oai5g-docker

This repository containes all necessary instructions to run an all-container end-to-end 5g network using ExPECA Openstack. The building blocks of our 5g network are containers. All components could be divided into:

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


Admins at ExPECA testbed need to build and push the images to the ExPECA docker registry according to [here](https://github.com/KTH-EXPECA/oai5g-docker/blob/main/docs/how-to-build-images.md).

Currently the following setup is supported at ExPECA testbed:
- SDR: USRP E320
- 5G frequency band: 78, tdd
- PRBs: 106
