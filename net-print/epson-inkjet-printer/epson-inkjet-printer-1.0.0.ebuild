# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/epson-inkjet-printer-escpr/epson-inkjet-printer-escpr-1.4.4.ebuild,v 1.4 2015/01/15 05:29:29 floppym Exp $

EAPI=5

inherit eutils multilib rpm autotools #multilib-minimal

MY_P="${PN}-201105w-${PV}-1lsb3.2"

DESCRIPTION="Epson Inkjet Printer Driver (ESC/P, full feature)"
HOMEPAGE="http://www.epson.com/"
SRC_URI="http://a1227.g.akamai.net/f/1227/40484/7d/download.ebz.epson.net/dsc/f/01/00/01/68/76/0dac7be1da6b33d967222c35844ac798eb8e00b1/${MY_P}.src.rpm"

LICENSE="LGPL-2.1 EPSON"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack ${A}
	cd "${S}"

	mv ${PN}-201105w-${PV}/ ${P}/

	#README in the filter tar is outdated in 1.0.0
	rm ${PN}-filter-${PV}/README

	mv ${PN}-filter-${PV}/* ${P}/
	rmdir ${PN}-filter-${PV}/
}

src_prepare() {
	rm configure
	eautoreconf
}

src_configure() {
	econf --disable-shared
	sed -i -e 's/^#define CORE_LIBRARY_PATH .*$/#define CORE_LIBRARY_PATH "\/usr\/libexec"/' config.h
	sed -i -e 's/^#define CORE_RESOURCE_PATH .*$/#define CORE_RESOURCE_PATH "\/usr\/share\/'${PN}'\/resource"/' config.h

	#Modify installation path in ppd files
	sed -i -e 's/^\*cupsFilter:.*$/\*cupsFilter: "application\/vnd.cups-raster 0 \/usr\/libexec\/cups\/filter\/'${PN}'"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Confidential:.*$/\*epcgWatermarkData Confidential: "\/usr\/share\/'${PN}'\/watermark\/WEPCG00.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Draft:.*$/\*epcgWatermarkData Draft: "\/usr\/share\/'${PN}'\/watermark\/WEPCG01.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Urgent:.*$/\*epcgWatermarkData Urgent: "\/usr\/share\/'${PN}'\/watermark\/WEPCG02.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Priority:.*$/\*epcgWatermarkData Priority: "\/usr\/share\/'${PN}'\/watermark\/WEPCG03.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Hot:.*$/\*epcgWatermarkData Hot: "\/usr\/share\/'${PN}'\/watermark\/WEPCG04.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData DoNotCopy:.*$/\*epcgWatermarkData DoNotCopy: "\/usr\/share\/'${PN}'\/watermark\/WEPCG05.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData ForYourEyesOnly:.*$/\*epcgWatermarkData ForYourEyesOnly: "\/usr\/share\/'${PN}'\/watermark\/WEPCG06.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData ReviewCopy:.*$/\*epcgWatermarkData ReviewCopy: "\/usr\/share\/'${PN}'\/watermark\/WEPCG07.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData TopSecret:.*$/\*epcgWatermarkData TopSecret: "\/usr\/share\/'${PN}'\/watermark\/WEPCG08.EID"/' ppds/*.ppd
	sed -i -e 's/^\*epcgWatermarkData Duplicate:.*$/\*epcgWatermarkData Duplicate: "\/usr\/share\/'${PN}'\/watermark\/WEPCG09.EID"/' ppds/*.ppd
}

src_install() {
	mkdir -p "${ED%/}/usr/share/ppd/${P}/"
	cp ppds/*.ppd "${ED%/}/usr/share/ppd/${P}/"

	default

	mv "${ED%/}/usr/lib/" "${ED%/}/usr/libexec/"
	mv "${ED%/}/usr/libexec/cups/filter/epson_inkjet_printer_filter" "${ED%/}/usr/libexec/cups/filter/${PN}"

	if [[ ${ABI} == amd64 ]]; then
		dolib lib64/libEpson_201105w.so.${PV}
		dolib lib64/libEpson_201105w.MT.so.${PV}
	elif [[ ${ABI} == x86 ]]; then
		dolib lib/libEpson_201105w.so.${PV}
		dolib lib/libEpson_201105w.MT.so.${PV}
	fi


	insinto /usr/share/${PN}/resource
	doins resource/*.data #"${ED%/}/usr/share/${PN}/resource/"

	insinto /usr/share/${PN}/watermark
	doins watermark/*.EID #"${ED%/}/usr/share/${PN}/watermark/"

	rm -r "${ED%/}/usr/doc" || die
}
