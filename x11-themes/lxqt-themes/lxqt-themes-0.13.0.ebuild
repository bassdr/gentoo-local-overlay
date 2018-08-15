# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit cmake-utils

DESCRIPTION="Themes, graphics and icons for LXQt"
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
	!lxqt-base/lxqt-common
"

DEPEND="${CDEPEND}
	>=dev-util/cmake-3.0.2
	>=dev-util/lxqt-build-tools-0.5.0
"

RDEPEND="${CDEPEND}
"

src_configure() {
	local mycmakeargs=( -DPULL_TRANSLATIONS=OFF )
	cmake-utils_src_configure
}
