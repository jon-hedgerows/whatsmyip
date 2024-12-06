# see also https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html#Makefile-Conventions
SHELL = /bin/sh

prefix ?= /usr

ifdef IGNORE_NEW
GIT_IGNORE_NEW = --git-ignore-new
endif

all: whatsmyip

whatsmyip: src/whatsmyip.sh
	cat $< | sed "s/^VERSION=.*$$/VERSION=`dpkg-parsechangelog --show-field Version 2>/dev/null || git describe --tags 2>/dev/null || echo dev`/" > $@
	chmod a+rx $@

install: whatsmyip
	install -D whatsmyip $(DESTDIR)$(prefix)/bin/whatsmyip

clean:
	-rm -f whatsmyip

distclean: clean

maintainer-clean: distclean
	-rm -rf debian/.debhelper
	-rm -rf debian/whatsmyip
	-rm -f debian/changelog
	-rm -f debian/changelog.dch
	-rm -f debian/debhelper-build-stamp
	-rm -f debian/files
	-rm -f debian/*.substvars
	-rm -f *-build-deps*
	-rm -f ../whatsmyip_*

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/whatsmyip

builddeps: debian/control
	sudo apt -yy update
	# ensure dev tools are installed
	sudo apt -yy install devscripts build-essential git-buildpackage debhelper equivs
	# make a magic build-deps package, install it, and remove the file
	sudo mk-build-deps -i -r debian/control -t "apt --no-install-recommends -yy"
	# remove the other extraneous files
	-sudo rm -f *-build-deps*
	sudo chmod a+w ..
	touch builddeps

snapshot: builddeps
	-rm -f debian/changelog
	sudo chmod a+w ..
	dch --create --newversion=`git describe --tags --abbrev=0 | sed 's/^v//g'` --package `grep Package: debian/control | head -n 1 | awk '{print $$2}'` "for full history please refer to `grep Homepage: debian/control | head -n 1 | awk '{print $$2}'`"
	gbp dch --snapshot --snapshot-number=`git rev-list --all --count`
	gbp buildpackage --git-ignore-new
	ls -1 ../`grep Package: debian/control | head -n 1 | awk '{print $$2}'`_*

release: builddeps
	-rm -f debian/changelog	
	dch --create --newversion=`git describe --tags --abbrev=0 | sed 's/^v//g'` --package `grep Package: debian/control | head -n 1 | awk '{print $$2}'` "for full history please refer to `grep Homepage: debian/control | head -n 1 | awk '{print $$2}'`"
	gbp dch --release --distribution=stable
	gbp buildpackage $(GIT_IGNORE_NEW)

.PHONY: all install clean distclean uninstall maintainer-clean snapshot release
