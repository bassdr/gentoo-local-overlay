# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit vdr-plugin-2

DESCRIPTION="VDR plugin: VNSI Streamserver Plugin (FernetManta repo)"
HOMEPAGE="https://github.com/FernetMenta/vdr-plugin-vnsiserver"
SRC_URI="https://github.com/FernetMenta/vdr-plugin-vnsiserver/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

DEPEND=">=media-video/vdr-1.7.14"
RDEPEND="${DEPEND}
		>=media-plugins/xbmc-addon-pvr-0.0.1_p20140213"
# Maintainer, please add also media-plugins/xbmc-addon-pvr with the same patchlevel
# to the tree, so it is guaranteed that the server and the addon fit together

S="${WORKDIR}/vdr-plugin-${VDRPLUGIN}-${PV}"

src_prepare() {
	vdr-plugin-2_src_prepare

	fix_vdr_libsi_include demuxer.c
	fix_vdr_libsi_include videoinput.c
}

src_install() {
	vdr-plugin-2_src_install

	insinto /etc/vdr/plugins/vnsiserver
	doins vnsiserver/allowed_hosts.conf
	diropts -gvdr -ovdr
}
