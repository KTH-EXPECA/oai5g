#!/bin/bash

# ENV Vars example:
# AUTH_SERVER=10.0.87.254,AUTH_PROJECT_NAME=openstack,AUTH_USERNAME=admin,AUTH_PASSWORD=wcXLR6yAZ6mya79vi1BkjtIkONHyZqO9kJg0tYOp,SWIFT_CONTAINER=oai5g-ran,CONF_FILE_ADDR=gnb.sa.band78.fr1.106PRB.usrpb210.conf

sh -c 'python3 /tmp/download_files.py /opt/oai-gnb/etc/gnb.conf $SWIFT_CONTAINER $CONF_FILE_ADDR'
sh -c 'sudo uhd_image_loader --args \"type=e3xx,mgmt_addr=10.10.3.3,fpga=XG\" && sudo ./nr-softmodem -O /opt/oai-gnb/etc/gnb.conf --sa --continuous-tx --usrp-tx-thread-config 1 -E --gNBs.[0].min_rxtxtime 6'
