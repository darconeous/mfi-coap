

HOST=mips-unknown-linux-uclibc
TAR=tar

#LINKING_FLAGS=--disable-shared --enable-static
LINKING_FLAGS=--enable-shared --disable-static

SYSROOT=$(shell pwd)/build/root
STD_SYSROOT=/opt/$(HOST)/$(HOST)/sysroot

all: libnyoci-build smcp-build strip-root make-root

smcp/configure: smcp/configure.ac smcp/doc/Makefile.am smcp/Makefile.am smcp/src/examples/Makefile.am smcp/src/Makefile.am smcp/src/smcp/Makefile.am smcp/src/smcpd/Makefile.am smcp/src/tests/Makefile.am
	smcp/bootstrap.sh

libnyoci/configure: libnyoci/configure.ac libnyoci/doc/Makefile.am libnyoci/Makefile.am libnyoci/src/examples/Makefile.am libnyoci/src/Makefile.am libnyoci/src/plugtest/Makefile.am libnyoci/src/libnyociextra/Makefile.am libnyoci/src/libnyoci/Makefile.am libnyoci/src/nyocictl/Makefile.am libnyoci/src/tests/Makefile.am
	libnyoci/bootstrap.sh

build/libnyoci/config.status: libnyoci/configure Makefile
	mkdir -p build/libnyoci
	cd build/libnyoci && ../../libnyoci/configure \
		--disable-plugtest \
		--disable-examples \
		CFLAGS=-Os \
		--host=$(HOST) \
		host_alias=$(HOST) \
		$(LINKING_FLAGS) \
		--prefix=/var/etc/persistent \
		--sbindir=/var/etc/persistent/bin \
		--sysconfdir=/etc \
		--localstatedir=/var \
		PKG_CONFIG_DIR= \
		PKG_CONFIG_LIBDIR=$(SYSROOT)/var/etc/persistent/lib/pkgconfig \
		PKG_CONFIG_SYSROOT_DIR=$(SYSROOT) \
		$(NULL)

build/smcp/config.status: smcp/configure Makefile libnyoci-build
	mkdir -p build/smcp
	cd build/smcp && ../../smcp/configure \
		--disable-examples \
		CFLAGS=-Os \
		--host=$(HOST) \
		host_alias=$(HOST) \
		$(LINKING_FLAGS) \
		--prefix=/var/etc/persistent \
		--sbindir=/var/etc/persistent/bin \
		--sysconfdir=/etc \
		--localstatedir=/var \
		PKG_CONFIG_DIR= \
		PKG_CONFIG_LIBDIR=$(SYSROOT)/var/etc/persistent/lib/pkgconfig \
		PKG_CONFIG_SYSROOT_DIR=$(SYSROOT) \
		$(NULL)

smcp-build: build/smcp/config.status
	$(MAKE) -C build/smcp
	$(MAKE) -C build/smcp install DESTDIR="$(SYSROOT)"
	find $(SYSROOT) -name '*.la' | xargs sed -i~ -e "s;/var/etc/persistent;$(SYSROOT)/var/etc/persistent;"

libnyoci-build: build/libnyoci/config.status
	$(MAKE) -C build/libnyoci
	$(MAKE) -C build/libnyoci install DESTDIR="$(SYSROOT)"
	find $(SYSROOT) -name '*.la' | xargs sed -i~ -e "s;/var/etc/persistent;$(SYSROOT)/var/etc/persistent;"

strip-root:
	-find $(SYSROOT) -type f | xargs $(HOST)-strip 2> /dev/null
	$(RM) -fr $(SYSROOT)/var/etc/persistent/include
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.la
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.la~
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.a
	$(RM) -fr $(SYSROOT)/var/etc/persistent/share/man
	$(RM) -fr $(SYSROOT)/var/etc/persistent/lib/pkgconfig

make-root:
	$(RM) -fr root
	mkdir -p root
	$(TAR) -cC $(SYSROOT) var | $(TAR) -xvC root
	$(TAR) -cC conf-root var | $(TAR) -xvC root
	(cd root && find . -type f ) > root/var/etc/persistent/mfi-coap-manifest.txt
	@echo ------
	@find root -type f | xargs ls --color -lah
	@du -h root

clean:
	$(RM) -fr build/root
	$(RM) -fr build/smcp
	$(RM) -fr build/libnyoci
	$(RM) -fr root

