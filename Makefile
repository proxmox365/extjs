include /usr/share/dpkg/pkg-info.mk

PACKAGE=libjs-extjs

BUILDDIR ?= ${PACKAGE}-${DEB_VERSION_UPSTREAM}
GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb
DSC=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}.dsc

all: deb

${BUILDDIR}: debian extjs
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	rsync -a debian/ $@.tmp/debian
	mkdir $@.tmp/extjs
	rsync -a extjs/build/ $@.tmp/extjs/build
	cp extjs/licenses/license.txt $@.tmp/debian/copyright
	mv $@.tmp $@

.PHONY: deb
deb: ${DEB}
${DEB}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -b -us -uc
	lintian $@

.PHONY: dsc
dsc: ${DSC}
${DSC}: ${BUILDDIR}
	cd ${BUILDDIR}; tar czf ../${PACKAGE}_${DEB_VERSION_UPSTREAM}.orig.tar.gz *
	cd ${BUILDDIR}; dpkg-buildpackage -S -us -uc -d
	lintian $@

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist buster

.PHONY: distclean clean
distclean: clean
clean:
	rm -rf ${PACKAGE}-*/ *.deb *.changes *.buildinfo *.orig.tar.* *.dsc *.debian.tar.*
	find . -name '*~' -exec rm {} ';'

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
