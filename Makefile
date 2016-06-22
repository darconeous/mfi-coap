

HOST=mips-unknown-linux-uclibc
TAR=tar

#LINKING_FLAGS=--disable-shared --enable-static
LINKING_FLAGS=--enable-shared --disable-static

all: smcp-build strip-root make-root

smcp/configure: smcp/configure.ac smcp/docs/Makefile.am smcp/Makefile.am smcp/src/examples/Makefile.am smcp/src/Makefile.am smcp/src/plugtest/Makefile.am smcp/src/smcp/Makefile.am smcp/src/smcpctl/Makefile.am smcp/src/smcpd/Makefile.am smcp/src/tests/Makefile.am
	smcp/bootstrap.sh

build/smcp/config.status: smcp/configure Makefile
	mkdir -p build/smcp
	cd build/smcp && ../../smcp/configure CFLAGS=-Os --host=$(HOST) host_alias=$(HOST) $(LINKING_FLAGS)  --prefix=/var/etc/persistent --sbindir=/var/etc/persistent/bin --sysconfdir=/var/etc/persistent/ --localstatedir=/var

smcp-build: build/smcp/config.status
	$(MAKE) -C build/smcp install DESTDIR=`pwd`/build/root

strip-root:
	-find `pwd`/build/root | xargs $(HOST)-strip 2> /dev/null
	$(RM) build/root/var/etc/persistent/bin/smcp-plugtest-client
	$(RM) build/root/var/etc/persistent/bin/smcp-plugtest-server
	$(RM) -fr build/root/var/etc/persistent/include
	-$(RM) -f build/root/var/etc/persistent/lib/libsmcp.la
	-$(RM) -f build/root/var/etc/persistent/lib/libsmcp.a
	$(RM) -fr build/root/var/etc/persistent/share/man

make-root:
	$(RM) -fr root
	mkdir -p root
	$(TAR) -cC build/root . | $(TAR) -xvC root
	$(TAR) -cC conf-root . | $(TAR) -xvC root

