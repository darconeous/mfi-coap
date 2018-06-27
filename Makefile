

HOST=mips-unknown-linux-uclibc
TAR=tar

COMMON_CONFIGURE_OPTIONS= --host=$(HOST) host_alias=$(HOST)
COMMON_CONFIGURE_OPTIONS+= --prefix=/var/etc/persistent
COMMON_CONFIGURE_OPTIONS+= --sbindir=/var/etc/persistent/bin
COMMON_CONFIGURE_OPTIONS+= --sysconfdir=/etc
COMMON_CONFIGURE_OPTIONS+= --localstatedir=/var

COMMON_CONFIGURE_OPTIONS+= --disable-shared --enable-static
#COMMON_CONFIGURE_OPTIONS+= --enable-shared --disable-static

COMMON_CONFIGURE_OPTIONS+= PKG_CONFIG_DIR=
COMMON_CONFIGURE_OPTIONS+= PKG_CONFIG_LIBDIR=$(SYSROOT)/var/etc/persistent/lib/pkgconfig
COMMON_CONFIGURE_OPTIONS+= PKG_CONFIG_SYSROOT_DIR=$(SYSROOT)
COMMON_CONFIGURE_OPTIONS+= CC='$(HOST)-gcc -ffunction-sections -fdata-sections -Wl,-rpath,/var/etc/persistent/lib,-gc-sections'

ifeq ($(DEBUG),1)
COMMON_CONFIGURE_OPTIONS+= --enable-debug=verbose
make-root: $(SYSROOT)/var/etc/persistent/bin/gdbserver
endif

SYSROOT=$(shell pwd)/build/root
STD_SYSROOT=$(shell $(HOST)-ld --print-sysroot)

all: libnyoci-build smcp-build make-root

# Ignore
#init-root:
#	-mkdir -p "$(SYSROOT)"
#	cd $(STD_SYSROOT) ; for filename in `find -L . -not -type d` ; do if ! test -f "$(SYSROOT)/$$filename" ; then mkdir -p $(SYSROOT)/`dirname $$filename` ; cat $$filename > "$(SYSROOT)/$$filename" ; fi ; done
#		CC_IGNORE=$(HOST)-gcc\ --sysroot\ $(SYSROOT)\ -Wl,-rpath,/var/etc/persistent/lib \
#	find $(SYSROOT) -name '*.la' | xargs sed -i~ -e "/libs=/s:/var/etc/persistent:$(SYSROOT)/var/etc/persistent:"

smcp/configure: smcp/configure.ac smcp/doc/Makefile.am smcp/Makefile.am smcp/src/examples/Makefile.am smcp/src/Makefile.am smcp/src/smcp/Makefile.am smcp/src/smcpd/Makefile.am smcp/src/tests/Makefile.am
	smcp/bootstrap.sh

libnyoci/configure: libnyoci/configure.ac libnyoci/doc/Makefile.am libnyoci/Makefile.am libnyoci/src/examples/Makefile.am libnyoci/src/Makefile.am libnyoci/src/plugtest/Makefile.am libnyoci/src/libnyociextra/Makefile.am libnyoci/src/libnyoci/Makefile.am libnyoci/src/nyocictl/Makefile.am libnyoci/src/tests/Makefile.am
	libnyoci/bootstrap.sh

build/libnyoci/config.status: libnyoci/configure Makefile
	mkdir -p build/libnyoci
	cd build/libnyoci && ../../libnyoci/configure \
		--disable-plugtest \
		--disable-examples \
		$(COMMON_CONFIGURE_OPTIONS) \
		$(NULL)

build/smcp/config.status: smcp/configure Makefile libnyoci-build
	mkdir -p build/smcp
	cd build/smcp && ../../smcp/configure \
		--disable-examples \
		$(COMMON_CONFIGURE_OPTIONS) \
		$(NULL)

smcp-build: build/smcp/config.status
	$(MAKE) -C build/smcp V=1
	$(MAKE) -C build/smcp install DESTDIR="$(SYSROOT)"
	find $(SYSROOT) -name '*.la' | xargs sed -i~ -e "/`printf %s $(SYSROOT) | sed y:/:.:`/!s:/var/etc/persistent:$(SYSROOT)/var/etc/persistent:"

libnyoci-build: build/libnyoci/config.status
	$(MAKE) -C build/libnyoci V=1
	$(MAKE) -C build/libnyoci install DESTDIR="$(SYSROOT)"
	find $(SYSROOT) -name '*.la' | xargs sed -i~ -e "/`printf %s $(SYSROOT) | sed y:/:.:`/!s:/var/etc/persistent:$(SYSROOT)/var/etc/persistent:"

strip-root:
	-find $(SYSROOT) -type f | xargs $(HOST)-strip 2> /dev/null
	$(RM) -fr $(SYSROOT)/var/etc/persistent/include
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.la
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.la~
	-$(RM) -f $(SYSROOT)/var/etc/persistent/lib/*.a
	$(RM) -fr $(SYSROOT)/var/etc/persistent/share/man
	$(RM) -fr $(SYSROOT)/var/etc/persistent/lib/pkgconfig

$(SYSROOT)/var/etc/persistent/bin/gdbserver: $(STD_SYSROOT)/../debug-root/usr/bin/gdbserver
	cp $(STD_SYSROOT)/../debug-root/usr/bin/gdbserver $(SYSROOT)/var/etc/persistent/bin/gdbserver

make-root:
	$(RM) -fr root
	mkdir -p root
	$(TAR) -cC $(SYSROOT) var | $(TAR) -xvC root
	$(TAR) -cC conf-root var | $(TAR) -xvC root
	-find root -type f | xargs $(HOST)-strip 2> /dev/null
	$(RM) -fr root/var/etc/persistent/include
	-$(RM) -f root/var/etc/persistent/lib/*.la
	-$(RM) -f root/var/etc/persistent/lib/*.la~
	-$(RM) -f root/var/etc/persistent/lib/*.a
	$(RM) -fr root/var/etc/persistent/share/man
	$(RM) -fr root/var/etc/persistent/lib/pkgconfig
	(cd root && find . -type f ) > root/var/etc/persistent/mfi-coap-manifest.txt
	@echo ------
	@find root -type f | xargs ls --color -lah
	@du -h root

clean:
	$(RM) -fr build/root
	$(RM) -fr build/smcp
	$(RM) -fr build/libnyoci
	$(RM) -fr root

