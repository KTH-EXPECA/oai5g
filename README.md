# ExPECA Openairinterface5G Setup

This repository containes all necessary information and instructions to select and run Openairinterface5G software on E320 software-defined radios.

The documentation contains the supported versions and/or necessary modifications. We cover 3 different implementations: 
1) Fully containerized using Docker
2) Fully containerized for K8S
3) Bare-metal RAN and containerized CN

The building blocks of our 5g network are containers. All components could be divided into:

1. Core Network (CN)
	1. MySQL
	2. NRF
	3. UDR
	4. UDM
	5. AUSF
	6. AMF
	7. SMF
	8. SPGWU/UPF
2. Radio Access Network (RAN)
	1. gNodeB
	2. nrUE

## Supported versions

### Week 47 2022 

Our Openairinterface flavor supports USRP E320. It is branched from commit [8773e42](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/8773e4236316af35ab141eaaccca14bf06fd3f09) which was merged on November 2022.




