# upsmon for WMware ESXi 5.0 to 8.0
# Rene Garcia 2023 - GPL Licence

PROJECT_VERSION=2.5.0

SMTPTOOLS_VERSION=0.2.3
LIBRESSL_VERSION=3.7.3
NUT_VERSION=2.8.1
HARD=$(shell uname -i)

PROJECT=NutClient
NAME=upsmon
CURDIR=$(PWD)
VERSION=$(NUT_VERSION)-$(PROJECT_VERSION)

VIBNAME=$(NAME)-$(VERSION).$(HARD).vib
ARCNAME=$(PROJECT)-ESXi-$(VERSION)
ARCHIVE=$(ARCNAME).$(HARD).tar.gz
DEPOT=$(PROJECT)-ESXi-$(VERSION)-offline_bundle.zip

all: $(ARCHIVE) $(DEPOT)

libressl-$(LIBRESSL_VERSION).tar.gz:
	wget --no-check-certificate http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$(LIBRESSL_VERSION).tar.gz

libressl-$(LIBRESSL_VERSION): libressl-$(LIBRESSL_VERSION).tar.gz
	tar -xf libressl-$(LIBRESSL_VERSION).tar.gz

libressl-bin: libressl-$(LIBRESSL_VERSION)
	cd libressl-$(LIBRESSL_VERSION) ; ./configure --prefix=$(CURDIR)/libressl-bin --enable-shared=no --enable-static=yes CFLAGS="-fPIC"
	cd libressl-$(LIBRESSL_VERSION) ; make install

nut-$(NUT_VERSION).tar.gz:
	wget --no-check-certificate http://networkupstools.org/source/2.8/nut-$(NUT_VERSION).tar.gz

nut-$(NUT_VERSION): nut-$(NUT_VERSION).tar.gz
	tar -xf nut-$(NUT_VERSION).tar.gz
	cd nut-$(NUT_VERSION); patch -p1 < $(CURDIR)/patches/nut-$(NUT_VERSION)-esxi.patch

nut-bin: nut-$(NUT_VERSION) libressl-bin
	cd nut-$(NUT_VERSION); touch .git; ./configure --prefix=/opt/nut --without-cgi --without-snmp --without-wrap --without-serial --with-user=daemon --with-group=daemon --with-openssl --with-openssl-includes="-I$(CURDIR)/libressl-bin/include" --with-openssl-libs="-L$(CURDIR)/libressl-bin/lib -lssl -lcrypto" LDFLAGS="-lrt -lpthread"
	cd nut-$(NUT_VERSION); make DESTDIR=$(CURDIR)/nut-bin install

smtptools-$(SMTPTOOLS_VERSION).tar.gz:
	wget --no-check-certificate http://distfiles.gentoo.org/distfiles/c2/smtptools-$(SMTPTOOLS_VERSION).tar.gz

smtptools-$(SMTPTOOLS_VERSION): smtptools-$(SMTPTOOLS_VERSION).tar.gz
	tar -xf smtptools-$(SMTPTOOLS_VERSION).tar.gz
	cd smtptools-$(SMTPTOOLS_VERSION); patch -p1 < $(CURDIR)/patches/smtptools-0.2.3-autotools.patch
	cd smtptools-$(SMTPTOOLS_VERSION); patch -p1 < $(CURDIR)/patches/smtptools-0.2.3-cleanups.patch

smtptools-bin: smtptools-$(SMTPTOOLS_VERSION)
	cd smtptools-$(SMTPTOOLS_VERSION); LDFLAGS="-lresolv" ./configure --prefix=/opt/nut
	cd smtptools-$(SMTPTOOLS_VERSION); make DESTDIR=$(CURDIR)/smtptools-bin install

payload: nut-bin smtptools-bin
	rm -rf payload-tmp
	cp -pr skeleton payload-tmp
	mkdir -p payload-tmp/opt/nut/lib payload-tmp/opt/nut/bin payload-tmp/opt/nut/sbin
	cp -p nut-bin/opt/nut/bin/upsc payload-tmp/opt/nut/bin/
	cp -p nut-bin/opt/nut/sbin/upsmon payload-tmp/opt/nut/sbin/
	cp -p smtptools-bin/opt/nut/bin/smtpblast payload-tmp/opt/nut/bin/
	cp -pP nut-bin/opt/nut/lib/libupsclient.so* payload-tmp/opt/nut/lib/
	find payload-tmp -type f -exec file {} \; | grep 'not stripped' | cut -d: -f1 | xargs -t -L 1 strip
	mv payload-tmp payload
	touch payload

$(VIBNAME): payload
	script/mkvib.sh $(CURDIR)/payload "$(VERSION)" $(NAME) $(CURDIR)/data/descriptor.xml.template
	mv "$(CURDIR)/payload/$(VIBNAME)" "$(CURDIR)/$(VIBNAME)"

$(ARCHIVE): $(VIBNAME)
	sed -e "s!@VERSION@!$(VERSION)!" -e "s!@HARD@!$(HARD)!" $(CURDIR)/data/$(NAME)-install.sh.template > upsmon-install.sh
	sed -e "s!@VERSION@!$(VERSION)!" -e "s!@HARD@!$(HARD)!" $(CURDIR)/data/$(NAME)-remove.sh.template > upsmon-remove.sh
	sed -e "s!@VERSION@!$(VERSION)!" -e "s!@HARD@!$(HARD)!" $(CURDIR)/data/$(NAME)-update.sh.template > upsmon-update.sh
	chmod 755 $(NAME)-install.sh $(NAME)-remove.sh $(NAME)-update.sh
	tar -cf - readme.txt $(NAME)-install.sh $(NAME)-remove.sh $(NAME)-update.sh $(VIBNAME) | gzip -9 > $(ARCHIVE)

$(DEPOT): $(VIBNAME)
	script/mkbundle.sh $(PROJECT) $(NAME) $(VERSION) $(VIBNAME)

archive:
	git archive --format=tar --prefix=NutClient-ESXi-$(VERSION)-src/ $(PROJECT_VERSION) | gzip -9 > NutClient-ESXi-$(VERSION)-src.tar.gz

clean:
	rm -rf nut-bin nut-$(NUT_VERSION)
	rm -rf libressl-bin libressl-$(LIBRESSL_VERSION)
	rm -rf smtptools-bin smtptools-$(SMTPTOOLS_VERSION)
	rm -rf payload tmp
	rm -f $(VIBNAME) $(NAME)-install.sh $(NAME)-remove.sh $(NAME)-update.sh
	rm -f $(ARCHIVE)
	rm -f $(DEPOT)

cleaner: clean
	rm -f libressl-$(LIBRESSL_VERSION).tar.gz
	rm -f smtptools-$(SMTPTOOLS_VERSION).tar.gz
	rm -f nut-$(NUT_VERSION).tar.gz
	rm -f NutClient-ESXi-$(VERSION)-src.tar.gz
