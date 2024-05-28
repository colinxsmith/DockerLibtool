#FROM ubuntu:24.04 as build
# ubuntu has apt package handler
#RUN apt update
#RUN apt upgrade -y
#RUN apt install -y gcc g++ make git zip unzip libtool

#FROM alpine:3.14
#RUN apk add gcc g++ make git zip unzip patch libtool automake autoconf


FROM centos:centos7
ENV container docker
#centos uses yum
RUN yum -y update
RUN yum install  gcc-c++ make git zip unzip libtool patch -y


ENV PATH=$PATH:/topper/libsafeqp
WORKDIR /topper
COPY backup.zip /topper/
RUN mkdir safeqp
WORKDIR /topper/safeqp
RUN unzip ../backup
RUN patch < linux64patch
WORKDIR /topper
RUN git clone https://github.com/colinxsmith/libsafeqp
WORKDIR /topper/libsafeqp
RUN gcc ../safeqp/genconst.c -lm -o genconst
RUN gcc ../safeqp/validas.c ../safeqp/krypton.c ../safeqp/guniqid.c -o validas
RUN gcc ../safeqp/future.c ../safeqp/krypton.c  -o future
RUN getsource.sh
RUN autogen.sh
RUN configure --pref=$(pwd)
RUN make
RUN (NOW=24/10/2024;./validas libsafeqp/.libs/libsafeqp.so.1.0.0 $(./future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;./validas libsafeqp/.libs/libsafeqp.a $(./future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
#RUN make licence
RUN make install
RUN (NOW=24/10/2024;./validas lib/libsafeqp.so.1.0.0 $(./future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;./validas lib/libsafeqp.a $(./future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)