#FROM debian AS build
#FROM ubuntu:24.04 AS build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
#FROM linuxmintd/mint22-amd64 AS build
#docker image rm libtool
#docker build --no-cache -t libtool .
#docker run  --rm -it  --name Colin libtool
# ubuntu has apt package handler
RUN apt update
RUN apt upgrade -y
RUN apt install -y gcc g++ make git wget zip unzip libtool rpm tree vim bison
RUN apt install -y libpcre2-dev
#RUN apt install -y  openjdk-21-jdk
RUN apt install -y python-dev-is-python3 mono-mcs mono-devel
#debian#####################################
#RUN apt install -y python3-dev mono-mcs mono-devel
#RUN ln -s /usr/bin/python3 /usr/bin/python
#RUN apt install -y libpcre2-dev 
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
RUN dpkg -i jdk-21_linux-x64_bin.deb
RUN apt install -y patch
#########################################
#FROM alpine:edge AS build

#RUN apk add gcc g++ make git zip bash unzip patch libtool automake autoconf tree dpkg rpm vim bison openjdk21 pcre2 pcre2-dev  python3-dev perl-dev

#RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
#   apk add --no-cache --virtual=.build-dependencies ca-certificates && \
#   cert-sync /etc/ssl/certs/ca-certificates.crt && \
#   apk del .build-dependencies

#FROM fedora AS build
#FROM chaman72/centos9 AS build

#I ran docker pull chaman72/centos9 to get chaman72/centos9

#centos and fedora use yum
#RUN yum  update -y
#RUN yum install  gcc-c++ make git zip unzip libtool patch vim rpmdevtools vim tree bison wget -y
#RUN yum install  pcre2 pcre2-devel -y
#RUN yum install  python3-devel -y
#RUN ln -s /usr/bin/python3 /usr/bin/python
#RUN yum install mono-devel  perl-devel  -y
#RUN yum install perl-CPAN -y
#RUN cpan i CPAN && cpan reload CPAN
#RUN cpan i re::engine::PCRE2




#RUN wget https://download.oracle.com/java/21/archive/jdk-21.0.1_linux-x64_bin.rpm
#RUN yum install jdk-21.0.1_linux-x64_bin.rpm -y
ENV container=docker



#RUN wget https://download.oracle.com/java/21/archive/jdk-21.0.1_linux-x64_bin.rpm
#RUN dnf install jdk-21.0.1_linux-x64_bin.rpm -y

WORKDIR /topper
RUN mkdir bin
RUN mkdir /root/SWIGcvs
WORKDIR /root/SWIGcvs
RUN git clone https://github.com/swig/swig.git SWIG

WORKDIR /root/SWIGcvs/SWIG
#RUN ./autogen.sh && ./configure --prefix=$(pwd) --without-pcre
RUN ./autogen.sh && ./configure --prefix=$(pwd)
RUN make && make install
ENV PATH=$PATH:/topper/libsafeqp:/topper/bin
ENV TOPPER=/topper
COPY backup.zip /topper/
RUN mkdir safeqp
WORKDIR /topper/safeqp
RUN unzip ../backup && patch < linux64patch
WORKDIR /topper
RUN git clone https://github.com/colinxsmith/libsafeqp
WORKDIR /topper/libsafeqp
#Only on Alpine
#RUN sed -i "s/amd/musl-linux-amd/" DEBIAN/control
RUN gcc -O2 ../safeqp/genconst.c -lm  -o ../bin/genconst
RUN gcc -O2 ../safeqp/validas.c ../safeqp/krypton.c ../safeqp/guniqid.c -o ../bin/validas
RUN gcc -O2 ../safeqp/future.c ../safeqp/krypton.c  -o ../bin/future

RUN sh getsource.sh && autogen.sh && configure --pref=$(pwd)
RUN make
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN make install
RUN (NOW=24/10/2024;validas lib/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas lib/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
#RUN make licence
#RUN mkdir ~/rpmbuild

#RUN make dotdeb
#RUN make rpm
