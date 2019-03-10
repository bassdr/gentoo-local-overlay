# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CMAKE_MIN_VERSION="3.10.0"

inherit cmake-utils

DESCRIPTION="NetworkManager tray icon -> simple front end (nm-applet)"
HOMEPAGE="https://github.com/palinek/nm-tray"
SRC_URI="https://github.com/palinek/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="modemmanager"

RDEPEND="
  kde-frameworks/networkmanager-qt:5
  dev-qt/qtwidgets:5
  dev-qt/linguist-tools:5
  modemmanager? ( dev-qt/qtxml:5 kde-frameworks/modemmanager-qt:5 )
"
DEPEND="${RDEPEND}
  dev-util/cmake[qt5(-)]
"

#WITH_MODEMMANAGER_SUPPORT

src_configure() {
  local mycmakeargs=(
    -DNM_TRAY_XDG_AUTOSTART_DIR="/etc/xdg/autostart/"
    -DWITH_MODEMMANAGER_SUPPORT="$(usex modemmanager)"
  )
  cmake-utils_src_configure
}
