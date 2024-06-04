FROM debian as build
#FROM ubuntu:24.04 as build
#docker image rm libtool
#docker build --no-cache -t libtool .
#docker run  --rm -it  --name Colin libtool
# ubuntu has apt package handler
RUN apt update
RUN apt upgrade -y
#RUN apt install -y gcc g++ make git zip unzip libtool rpm tree vim bison openjdk-21-jdk
RUN apt install -y gcc g++ make git zip unzip libtool rpm tree vim bison wget

RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
RUN dpkg -i jdk-21_linux-x64_bin.deb
#FROM alpine as build

#RUN apk add gcc g++ make git zip unzip patch libtool automake autoconf tree dpkg rpm vim bison openjdk21


#FROM fedora as build
#FROM chaman72/centos9 as build

#I ran docker pull dokken/centos-stream-9 to get chaman72/centos9

#centos and fedora use yum
#RUN yum  update -y
#RUN yum install  gcc-c++ make git zip unzip libtool patch vim rpmdevtools vim tree bison wget  -y

ENV container docker
#RUN wget https://download.oracle.com/java/21/archive/jdk-21.0.1_linux-x64_bin.rpm
#RUN dnf install jdk-21.0.1_linux-x64_bin.rpm -y
#ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk
#ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV JAVA_HOME=/usr/lib/jvm/jdk-21-oracle-x64
#ENV JAVA_HOME=/usr/lib/jvm/jdk-21-oracle-x64

WORKDIR /topper
RUN mkdir SWIG bin
WORKDIR /topper/SWIG
RUN git clone https://github.com/swig/swig.git SWIG

WORKDIR /topper/SWIG/SWIG
RUN ./autogen.sh && ./configure --prefix=$(pwd) --without-pcre
RUN make && make install
ENV PATH=$PATH:/topper/libsafeqp:/topper/bin
COPY backup.zip /topper/
RUN mkdir safeqp
WORKDIR /topper/safeqp
RUN unzip ../backup && patch < linux64patch
WORKDIR /topper
RUN git clone https://github.com/colinxsmith/libsafeqp
WORKDIR /topper/libsafeqp
RUN gcc -O2 ../safeqp/genconst.c -lm  -o ../bin/genconst
RUN gcc -O2 ../safeqp/validas.c ../safeqp/krypton.c ../safeqp/guniqid.c -o ../bin/validas
RUN gcc -O2 ../safeqp/future.c ../safeqp/krypton.c  -o ../bin/future

RUN sed "s/libraryname/safejava/" ../safeqp/safe.i > safejava/safejava.i
RUN /topper/SWIG/SWIG/swig -java -c++ -module safejava -o safejava/safejava_wrap.cpp safejava/safejava.i
#RUN sed -i "/ReleaseStringUTFChars(,/d" safejava/safejava_wrap.cpp
RUN getsource.sh && autogen.sh && configure --pref=$(pwd)
RUN make
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas libsafeqp/.libs/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN make install
RUN (NOW=24/10/2024;validas lib/libsafeqp.so.1.0.0 $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN (NOW=24/10/2024;validas lib/libsafeqp.a $(future -b 13101D54 $(date +%d/%m/%Y) $NOW) 1023)
RUN mkdir ~/rpmbuild
