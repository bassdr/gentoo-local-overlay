# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils versionator

DESCRIPTION="LXQt system integration plugin for Qt"
HOMEPAGE="http://lxqt.org/"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/lxqt/${PN}.git"
else
	SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
fi

LICENSE="LGPL-2.1+"
SLOT="0"

CDEPEND="
	dev-libs/libdbusmenu-qt[qt5(+)]
	>=dev-libs/libqtxdg-3.0.0
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	>=x11-libs/libfm-qt-0.13.0
	x11-libs/libX11
"

RDEPEND="${CDEPEND}
	>=lxqt-base/liblxqt-0.9.0
"

DEPEND="${CDEPEND}
	>=dev-util/lxqt-build-tools-0.5.0
	dev-qt/linguist-tools:5
	>=lxqt-base/liblxqt-$(get_version_component_range 1-2)
"

src_configure() {
	local mycmakeargs=( -DPULL_TRANSLATIONS=OFF )
	cmake-utils_src_configure
}
