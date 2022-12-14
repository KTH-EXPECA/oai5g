#!/bin/bash

docker build -t expeca-mysql -f mysql/Dockerfile ./mysql/
docker image tag expeca-mysql samiemostafavi/expeca-mysql

docker build -t expeca-nrf -f nrf/Dockerfile ./nrf/
docker image tag expeca-nrf samiemostafavi/expeca-nrf

docker build -t expeca-udr -f udr/Dockerfile ./udr/
docker image tag expeca-udr samiemostafavi/expeca-udr

docker build -t expeca-udm -f udm/Dockerfile ./udm/
docker image tag expeca-udm samiemostafavi/expeca-udm

docker build -t expeca-ausf -f ausf/Dockerfile ./ausf/
docker image tag expeca-ausf samiemostafavi/expeca-ausf

docker build -t expeca-amf -f amf/Dockerfile ./amf/
docker image tag expeca-amf samiemostafavi/expeca-amf

docker build -t expeca-spgwu -f spgwu/Dockerfile ./spgwu/
docker image tag expeca-spgwu samiemostafavi/expeca-spgwu

docker image push samiemostafavi/expeca-mysql
docker image push samiemostafavi/expeca-nrf
docker image push samiemostafavi/expeca-udr
docker image push samiemostafavi/expeca-udm
docker image push samiemostafavi/expeca-ausf
docker image push samiemostafavi/expeca-amf
docker image push samiemostafavi/expeca-spgwu
