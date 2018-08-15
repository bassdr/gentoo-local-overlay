# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="NetworkManager tray icon -> simple front end (nm-applet)"
HOMEPAGE="https://github.com/palinek/nm-tray"
SRC_URI="https://github.com/palinek/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
  kde-frameworks/networkmanager-qt:5
  dev-qt/qtwidgets:5
  dev-qt/linguist-tools:5
"
DEPEND="${RDEPEND}"

