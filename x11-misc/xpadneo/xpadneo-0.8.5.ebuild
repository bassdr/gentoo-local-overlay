# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod udev

DESCRIPTION="Advanced Linux Driver for Xbox One Wireless Controller"
HOMEPAGE="https://atar-axis.github.io/xpadneo/"
SRC_URI="https://github.com/atar-axis/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}/hid-${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
#IUSE="gnome X"
#RESTRICT="strip"

#RDEPEND=""
#DEPEND="${RDEPEND} sys-kernel/dkms"
#BDEPEND="virtual/pkgconfig"

MODULE_NAMES="hid-${PN}(kernel/drivers/hid:${S}/src:${S}/src)"

src_compile() {
	BUILD_PARAMS="-C \"${KV_OUT_DIR}\" M=${S}/src" \
	BUILD_TARGETS="clean modules" \
		linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
	udev_dorules etc-udev-rules.d/98-${PN}.rules

	echo "CONFIG_PROTECT_MASK=\"/etc/modprobe.d/99-${PN}-bluetooth.conf\"" > 50${PN}
	doenvd 50${PN}

	echo "options bluetooth disable_ertm=y" > "99-${PN}-bluetooth.conf"
	insinto /etc/modprobe.d
	doins "99-${PN}-bluetooth.conf"
        doins etc-modprobe.d/xpadneo.conf
}

pkg_postinst() {
	linux-mod_pkg_postinst
	udev_reload

	DISABLE_ERTM=/sys/module/bluetooth/parameters/disable_ertm
	if test -e "${DISABLE_ERTM}"; then
		echo "y" > "${DISABLE_ERTM}"
	fi
}

pkg_postrm() {
	linux-mod_pkg_postrm
	udev_reload
}
