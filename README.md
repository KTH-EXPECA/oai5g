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
	ip: 192.168.70.136
	```
4. udm
	```
	ip: 192.168.70.137
	```
5. ausf
	```
	ip: 192.168.70.138
	```
6. amf
	```
	ip: 192.168.70.132
	```
7. smf
	```
	ip: 192.168.70.133
	```
8. spgwu
	```
	ip: 192.168.70.134
	cap_add:
	    - NET_ADMIN
	    - SYS_ADMIN
	cap_drop:
	    - ALL
	privileged: true
	```
