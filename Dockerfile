#FROM debian as build
#FROM ubuntu:24.04 as build
#docker image rm libtool
#docker build --no-cache -t libtool .
#docker run  --rm -it  --name Colin libtool
# ubuntu has apt package handler
#RUN apt update
#RUN apt upgrade -y
#RUN apt install -y gcc g++ make git zip unzip libtool rpm tree vim

FROM alpine:3.14 as build

RUN apk add gcc g++ make git zip unzip patch libtool automake autoconf tree dpkg


#FROM fedora as build
#FROM chaman72/centos9 as build

#I ran docker pull dokken/centos-stream-9 to get chaman72/centos9

#centos and fedora use yum
#RUN yum  update -y
#RUN yum install  gcc-c++ make git zip unzip libtool patch vim rpmdevtools tree -y


ENV container docker
WORKDIR /topper
RUN mkdir bin
ENV PATH=$PATH:/topper/libsafeqp:/topper/bin
COPY backup.zip /topper/
RUN mkdir safeqp
WORKDIR /topper/safeqp
RUN unzip ../backup
RUN patch < linux64patch
WORKDIR /topper
RUN git clone https://github.com/colinxsmith/libsafeqp
WORKDIR /topper/libsafeqp
RUN gcc -O2 ../safeqp/genconst.c -lm  -o ../bin/genconst
RUN gcc -O2 ../safeqp/validas.c ../safeqp/krypton.c ../safeqp/guniqid.c -o ../bin/validas
RUN gcc -O2 ../safeqp/future.c ../safeqp/krypton.c  -o ../bin/future
RUN getsource.sh
RUN autogen.sh
RUN configure --pref=$(pwd)
RUN make
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN make install
RUN (NOW=24/10/2024;validas lib/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas lib/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN mkdir ~/rpmbuild