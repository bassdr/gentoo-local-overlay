# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Script to update Gentoo, brute force, with a bit of try and errors"
HOMEPAGE="https://github.com/bassdr/emerge-update"
SRC_URI="https://github.com/bassdr/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} >=app-admin/eclean-kernel-2"

src_install() {
    dobin emerge-update
}
