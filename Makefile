PACKAGE=libjs-extjs
PKGVER=6.0.1
PKGREL=2

BUILD_DIR=${PACKAGE}-${PKGVER}

DEB=${PACKAGE}_${PKGVER}-${PKGREL}_all.deb
DSC=${PACKAGE}_${PKGVER}-${PKGREL}.dsc

# EXTJSDIR=ext-6.0.1
# wget http://cdn.sencha.com/ext/gpl/ext-6.0.1-gpl.zip
# unzip ext-6.0.1-gpl.zip

EXTDATA=	\
	extjs/build/ext-all.js	\
	extjs/build/ext-all-debug.js	\
	extjs/build/packages/charts/classic/charts.js	\
	extjs/build/packages/charts/classic/charts-debug.js	\

EXT_THEME=	\
	extjs/build/classic/theme-crisp		\
	extjs/build/packages/charts/classic/crisp	\

DESTDIR=

WWWEXT6DIR=${DESTDIR}/usr/share/javascript/extjs

all: ${EXTDATA}

${BUILD_DIR}: debian extjs
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	rsync -a debian/ $@.tmp/debian
	mkdir $@.tmp/extjs
	rsync -a extjs/build/ $@.tmp/extjs/build
	cp Makefile $@.tmp/
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

.PHONY: install
install: ${EXTDATA}
	install -d ${WWWEXT6DIR}
	install -m 0644 ${EXTDATA} ${WWWEXT6DIR}
	cp -a extjs/build/classic/locale ${WWWEXT6DIR}
	cp -a ${EXT_THEME} ${WWWEXT6DIR}
	chown -R www-data:www-data ${WWWEXT6DIR}

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
