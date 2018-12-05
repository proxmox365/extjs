PACKAGE=libjs-extjs
PKGVER=6.0.1
PKGREL=2

DEB=${PACKAGE}_${PKGVER}-${PKGREL}_all.deb

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

.PHONY: deb
deb: ${DEB}
${DEB}:
	rm -rf build
	mkdir build
	rsync -a debian/ build/debian
	rsync -a extjs/ build/extjs
	cp Makefile build/
	cp extjs/licenses/license.txt build/debian/copyright
	cd build; dpkg-buildpackage -b -us -uc
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
	rm -rf ./build *.deb *.changes *.buildinfo
	find . -name '*~' -exec rm {} ';'

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
