# Multi stage build for installing irtt tool in spgwu
FROM golang:1.19.3 AS goimage

# Install go package
RUN go install github.com/samiemostafavi/nlmt/cmd/nlmt@v0.10.3 \
 && cp $GOPATH/bin/nlmt /usr/local/bin/

from oaisoftwarealliance/oai-spgwu-tiny:v1.4.0
COPY --from=goimage /usr/local/bin/irtt /usr/local/bin/

# Install iperf3
RUN apt-get -y update
RUN apt-get install -y iperf3

ENV TZ=Europe/Paris
ENV PID_DIRECTORY=/var/run
ENV SGW_INTERFACE_NAME_FOR_S1U_S12_S4_UP=eth0
ENV SGW_INTERFACE_NAME_FOR_SX=eth0
ENV PGW_INTERFACE_NAME_FOR_SGI=eth0
ENV NETWORK_UE_NAT_OPTION=yes
ENV NETWORK_UE_IP=12.1.1.0/24
ENV SPGWC0_IP_ADDRESS=192.168.70.133
ENV BYPASS_UL_PFCP_RULES=no
ENV MCC=001
ENV MNC=01
ENV MNC03=001
ENV TAC=1
ENV GW_ID=1
ENV THREAD_S1U_PRIO=80
ENV S1U_THREADS=8
ENV THREAD_SX_PRIO=81
ENV SX_THREADS=1
ENV THREAD_SGI_PRIO=80
ENV SGI_THREADS=8
ENV REALM=openairinterface.org
ENV ENABLE_5G_FEATURES=yes
ENV REGISTER_NRF=yes
ENV USE_FQDN_NRF=yes
ENV UPF_FQDN_5G=oai-spgwu
ENV NRF_IPV4_ADDRESS=192.168.70.130
ENV NRF_PORT=80
ENV NRF_API_VERSION=v1
ENV NRF_FQDN=oai-nrf
ENV NSSAI_SST_0=1
ENV NSSAI_SD_0=0x1
ENV DNN_0=oai
ENV NSSAI_SST_1=1
ENV NSSAI_SD_1=0x2
ENV DNN_1=oai2
ENV NSSAI_SST_2=1
ENV NSSAI_SD_2=0x3
ENV DNN_2=oai3
