# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils kodi-addon

DESCRIPTION="Kodi's Stalker client addon"
HOMEPAGE="https://github.com/kodi-pvr/pvr.stalker"
KEYWORDS="~amd64 ~x86"

SRC_URI=""
EGIT_BRANCH="Krypton"
EGIT_COMMIT="d01bf4b66d50b9cd8261700ee9f2cc483cfd8faf"
EGIT_REPO_URI="https://github.com/kodi-pvr/pvr.stalker.git"
inherit git-r3

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="
	=media-tv/kodi-17*
	=media-libs/kodi-platform-17*
	dev-libs/jsoncpp
	dev-libs/tinyxml
	"

RDEPEND="
	${DEPEND}
	"
