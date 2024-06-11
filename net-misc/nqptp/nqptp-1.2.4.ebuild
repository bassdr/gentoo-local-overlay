# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools fcaps

DESCRIPTION="nqptp is a daemon that monitors timing data from any PTP clocks"
HOMEPAGE="https://github.com/mikebrady/nqptp"
SRC_URI="https://github.com/mikebrady/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2.0"

SLOT="0"

KEYWORDS="arm64"

IUSE="systemd"

RDEPEND="
        acct-user/${PN}
        acct-group/${PN}
"

DEPEND="${RDEPEND}"


PATCHES=(
        "${FILESDIR}/no-setcap.patch"
)

FILECAPS=(
	'cap_net_bind_service=+ep' usr/bin/${PN}
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
        econf \
                $(use_with systemd systemd-startup)
}
