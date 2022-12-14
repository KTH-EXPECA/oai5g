# oai5g-docker

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
	```
	name: 5gcn-spgwu
	ip: 192.168.70.134
	image: samiemostafavi/expeca-spgwu
	environment variables: SGW_INTERFACE_NAME_FOR_S1U_S12_S4_UP=net1,SGW_INTERFACE_NAME_FOR_SX=net1,PGW_INTERFACE_NAME_FOR_SGI=net1,USE_FQDN_NRF=no
	labels: networks.1.interface=ens5f0,networks.1.ip=192.168.70.134/26,capabilities.privileged=true,capabilities.add.1=NET_ADMIN,capabilities.add.2=SYS_ADMIN,capabilities.drop.1=ALL
	cap_add:
	    - NET_ADMIN
	    - SYS_ADMIN
	cap_drop:
	    - ALL
	privileged: true
	```
