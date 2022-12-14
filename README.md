# oai5g-docker

Execution order and conditions:

network: 192.168.70.128/26

1. mysql
	ip: 192.168.70.131
2. nrf
	ip: 192.168.70.130
3. udr
	ip: 192.168.70.136
4. udm
	ip: 192.168.70.137
5. ausf
	ip: 192.168.70.138
6. amf
	ip: 192.168.70.132
7. smf
	ip: 192.168.70.133
8. spgwu
	ip: 192.168.70.134
	cap_add:
            - NET_ADMIN
            - SYS_ADMIN
        cap_drop:
            - ALL
        privileged: true
