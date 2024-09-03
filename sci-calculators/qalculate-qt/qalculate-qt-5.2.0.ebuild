# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Bump with sci-libs/libqalculate and sci-calculators/qalculate-gtk!

inherit qmake-utils

DESCRIPTION="Qt-based UI for libqalculate"
HOMEPAGE="https://github.com/Qalculate/qalculate-qt"
SRC_URI="https://github.com/Qalculate/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

IUSE="qt6"

DEPEND="!qt6? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	qt6? ( dev-qt/qtbase:6[gui,widgets,network] )
	>=sci-libs/libqalculate-${PV}
"
RDEPEND="${DEPEND}"
BDEPEND="!qt6? ( dev-qt/linguist-tools:5 ) qt6? ( dev-qt/qttools:6[linguist] )"

src_prepare() {
	default
	if use !qt6 ; then
		eqmake5 PREFIX="${EPREFIX}/usr"
	else
		eqmake6 PREFIX="${EPREFIX}/usr"
	fi
}

src_install() {
	emake INSTALL_ROOT="${ED}" install
}
