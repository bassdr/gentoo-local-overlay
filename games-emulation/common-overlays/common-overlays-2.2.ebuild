# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

LIBRETRO_COMMIT_SHA="3e9102a717f3e294867d71c674dcebece0bb6cb2"
inherit libretro

DESCRIPTION="Collection of overlay files for use with libretro frontends."
HOMEPAGE="https://github.com/libretro/common-overlays"
KEYWORDS="~amd64 ~x86 ~arm"

LICENSE="GPL-3"
SLOT="0"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	dodir "${LIBRETRO_DATA_DIR}"/overlays
	cp -R "${S}"/* "${D}${LIBRETRO_DATA_DIR}"/overlays
}
