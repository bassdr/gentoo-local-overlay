# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils

SLOT="0"

SRC_URI="http://www.scootersoftware.com/${P}.tar.gz"
DESCRIPTION="Beyond Compare 3 is the ideal tool for comparing files and folders on your Windows or Linux system. Visualize changes in your code and carefully reconcile them."
HOMEPAGE="http://www.scootersoftware.com/"

KEYWORDS="amd64"
IUSE="kde"

src_prepare() {
	epatch "${FILESDIR}"/no-usr-share-install.patch
}

src_install() {
	dodir /opt/bcompare
	./install.sh --prefix="${D}/opt/bcompare" --ebuild --libdirname="" || die "Install failed"
	dosym /opt/bcompare/bin/bcompare /opt/bin/bcompare
	domenu bcompare.desktop
	doicon bcompare.png bcomparefull32.png bcomparehalf32.png
	insinto /usr/share/mime/packages
	doins bcompare.xml

	MACH=`uname -m`
	NUM=`expr match "$MACH" 'i[0-9]86'`
	if [[ $NUM -ge 4 ]]; then
		MACH_ARCH=i386
	else
		MACH_ARCH=amd64
	fi

	if use kde; then
		insinto /usr/share/kde4/services/
		doins ext/bcompare_ext_kde.desktop
		dosym /opt/bcompare/lib/ext/bcompare_ext_kde.$MACH_ARCH.so /usr/lib/kde4/bcompare_ext_kde.so
	fi
}

pkg_postinst() {
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_mime_database_update
}
