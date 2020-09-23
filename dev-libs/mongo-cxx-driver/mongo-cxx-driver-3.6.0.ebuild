# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="C++ Driver for MongoDB"
HOMEPAGE="http://mongocxx.org/"
SRC_URI="https://github.com/mongodb/${PN}/archive/r${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="static-libs static-mongoc"
RESTRICT=""
REQUIRED_USE=""

BDEPEND=""
RDEPEND=">=dev-libs/mongo-c-driver-1.17.0
	static-mongoc? ( dev-libs/mongo-c-driver[static-libs] )"

DEPEND="${RDEPEND}
	dev-libs/boost"

S="${WORKDIR}/${PN}-r${PV}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_VERSION="${PV}"
		-DENABLE_UNINSTALL=OFF
		-DBSONCXX_POLY_USE_BOOST=ON
		-DBUILD_SHARED_AND_STATIC_LIBS="$(usex static-libs ON OFF)"
		-DBUILD_SHARED_LIBS_WITH_STATIC_MONGOC="$(usex static-mongoc ON OFF)"
	)

	cmake_src_configure
}
