FROM debian:latest

ENV CROSSTOOL_NG_VERSION=1.22.0
ENV CROSS_TUPLE=mips-unknown-linux-uclibc
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/$CROSS_TUPLE/bin/

# Remove /etc/profile because it screws up our path.
RUN rm /etc/profile

RUN apt-get -y update \
	&& DEBIAN_FRONTEND=noninteractive \
		apt-get -y install dpkg-dev make patch xz-utils bzip2 file fakeroot wget gperf bison flex texinfo help2man gawk libtool-bin automake ncurses-dev

#COPY crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2 /
#COPY crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2.sig /

ADD http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2 /
ADD http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2.sig /

ADD 35B871D1.asc /
ADD ct-ng.config /ct-ng-build/.config
ADD uClibc.config /ct-ng-build/.uClibc.config

RUN gpg --import 35B871D1.asc \
	&& gpg --verify crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2.sig \
	&& tar xvjf crosstool-ng-$CROSSTOOL_NG_VERSION.tar.bz2 \
	&& ( cd crosstool-ng && ./configure && make install ) \
	&& ( yes "" | adduser builder --disabled-login ) \
	&& mkdir -p /opt \
	&& chown -R builder ct-ng-build opt

USER builder

RUN cd ct-ng-build && ct-ng source

RUN cd ct-ng-build && ct-ng build

USER root

RUN rm -fr ct-ng-build

RUN DEBIAN_FRONTEND=noninteractive \
		apt-get -y remove dpkg-dev gperf bison flex libtool-bin ncurses-dev


