PACKAGE=libjs-extjs
PKGVER=6.0.1
PKGREL=2

BUILD_DIR=${PACKAGE}-${PKGVER}

DEB=${PACKAGE}_${PKGVER}-${PKGREL}_all.deb
DSC=${PACKAGE}_${PKGVER}-${PKGREL}.dsc

all: deb

${BUILD_DIR}: debian extjs
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	rsync -a debian/ $@.tmp/debian
	mkdir $@.tmp/extjs
	rsync -a extjs/build/ $@.tmp/extjs/build
	cp extjs/licenses/license.txt $@.tmp/debian/copyright
	mv $@.tmp $@

.PHONY: deb
deb: ${DEB}
${DEB}: ${BUILD_DIR}
	cd ${BUILD_DIR}; dpkg-buildpackage -b -us -uc
	lintian $@

.PHONY: dsc
dsc: ${DSC}
${DSC}: ${BUILD_DIR}
	cd ${BUILD_DIR}; tar czf ../${PACKAGE}_${PKGVER}.orig.tar.gz *
	cd ${BUILD_DIR}; dpkg-buildpackage -S -us -uc -nc -d
	lintian $@

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB} | ssh repoman@repo.proxmox.com -- upload --product pve,pmg --dist stretch

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR} ${BUILD_DIR}.tmp *.deb *.changes *.buildinfo *.orig.tar.* *.dsc *.debian.tar.*
	find . -name '*~' -exec rm {} ';'

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
