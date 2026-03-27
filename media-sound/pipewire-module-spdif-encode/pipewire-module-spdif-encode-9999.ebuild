# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/bassdr/${PN}.git"
else
	SRC_URI="https://github.com/bassdr/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
fi

inherit meson

DESCRIPTION="PipeWire module for real-time surround encoding (AC3/DTS) over S/PDIF and HDMI"
HOMEPAGE="https://github.com/bassdr/pipewire-module-spdif-encode"

LICENSE="MIT"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	test? ( >=dev-cpp/catch-3:0 )
"
RDEPEND="
	>=media-video/pipewire-0.3:=
	media-video/ffmpeg:=
	media-video/wireplumber
"
DEPEND="${RDEPEND}"

src_configure() {
	local emesonargs=(
		$(meson_feature test)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# PipeWire config for loading the module
	insinto /usr/share/pipewire/pipewire.conf.avail
	doins dist/50-spdif-encode.conf

	# WirePlumber config: loads the volume-lock script
	insinto /usr/share/wireplumber/wireplumber.conf.d
	doins dist/50-spdif-encode-wireplumber.conf

	# WirePlumber script: locks target device route volume to 100%
	insinto /usr/share/wireplumber/scripts/spdif-encode
	doins dist/spdif-encode-lock-volume.lua
}

pkg_postinst() {
	elog "To enable the S/PDIF surround encoder, symlink the config:"
	elog "  ln -s /usr/share/pipewire/pipewire.conf.avail/50-spdif-encode.conf \\"
	elog "        /etc/pipewire/pipewire.conf.d/50-spdif-encode.conf"
	elog
	elog "Then restart PipeWire.  The virtual 5.1 sink will appear in"
	elog "pavucontrol and wpctl.  Route applications to it for AC3-encoded"
	elog "output over S/PDIF, TOSLINK, or HDMI."
	elog
	elog "Edit target.object in the config to select your output device."
	elog "List candidates with: wpctl status | grep -i -E 'hdmi|spdif|iec958'"
	elog
	elog "The target device volume is automatically locked to 100% by"
	elog "a WirePlumber script (any other volume corrupts the bitstream)."
}
