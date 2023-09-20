# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools

DESCRIPTION="nqptp is a daemon that monitors timing data from any PTP clocks"
HOMEPAGE="https://github.com/mikebrady/nqptp"
SRC_URI="https://github.com/mikebrady/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2.0"

SLOT="0"

KEYWORDS="arm64"

src_prepare() {
	default
	eautoreconf
}
