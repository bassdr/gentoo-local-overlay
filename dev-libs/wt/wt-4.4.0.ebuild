# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Wt, C++ Web Toolkit"
HOMEPAGE="https://www.webtoolkit.eu/wt"
SRC_URI="https://github.com/emweb/wt/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="examples test extjs firebird haru libwtdbo libwttest mssqlserver mysql opengl pango postgres qt4 qt5 sqlite ssl unwind"
RESTRICT=""
REQUIRED_USE=""

BDEPEND=""
RDEPEND=""

DEPEND="${RDEPEND}
	>=dev-libs/boost-1.50"

#S="${WORKDIR}/${PN}-r${PV}"

src_prepare() {
	# Erase content of WtInstall.cmake because it tries to create a folder in /run
	echo > WtInstall.cmake 
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLIB_INSTALL_DIR=$(get_libdir)
		-DRUNDIR=/run/wt
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTS=$(usex test)
		-DENABLE_EXT=$(usex extjs)
		-DENABLE_FIREBIRD=$(usex firebird)
		-DENABLE_HARU=$(usex haru)
		-DENABLE_LIBWTDBO=$(usex libwtdbo)
		-DENABLE_LIBWTTEST=$(usex libwttest)
		-DENABLE_MSSQLSERVER=$(usex mssqlserver)
		-DENABLE_MYSQL=$(usex mysql)
		-DENABLE_OPENGL=$(usex opengl)
		-DENABLE_PANGO=$(usex pango)
		-DENABLE_POSTGRES=$(usex postgres)
		-DENABLE_QT4=$(usex qt4)
		-DENABLE_QT5=$(usex qt5)
		-DENABLE_SQLITE=$(usex sqlite)
		-DENABLE_SSL=$(usex ssl)
		-DENABLE_UNWIND=$(usex unwind)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install
	rm -rf "${ED}"/run || die
}
