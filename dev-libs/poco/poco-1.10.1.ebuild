# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="The POCO C++ Libraries are powerful cross-platform C++ libraries for building network- and internet-based applications that run on desktop, server, mobile, IoT, and embedded systems"
HOMEPAGE="https://pocoproject.org/"
SRC_URI="https://github.com/pocoproject/${PN}/archive/${P}-release.tar.gz -> ${P}.tar.gz"
LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="amd64 arm x86"

IUSE="7zip cppparser +crypto +data +encodings encodings_compiler examples +file2pagecompiler iodbc +json +jwt libressl +mariadb +mongodb +mysql +net +odbc +pagecompiler pdf pocodoc postgres +redis +sqlite +ssl test +utils +xml +zip"
RESTRICT="!test? ( test )"
REQUIRED_USE="
	7zip? ( utils xml )
	encodings_compiler? ( net utils )
	file2pagecompiler? ( utils )
	iodbc? ( odbc )
	jwt? ( crypto json )
	mongodb? ( net )
	mysql? ( data )
	mariadb? ( data )
	odbc? ( data )
	pagecompiler? ( net utils )
	pdf? ( utils xml )
	pocodoc? ( cppparser utils xml )
	postgres? ( data )
	redis? ( net )
	sqlite? ( data )
	ssl? ( crypto net utils )
	test? ( data? ( sqlite ) utils xml )
	zip? ( utils xml )
"

BDEPEND="
	virtual/pkgconfig
"
RDEPEND="
	>=dev-libs/libpcre-8.42
	sys-libs/zlib
	mysql? ( !mariadb? ( dev-db/mysql-connector-c:0= ) )
	mariadb? ( dev-db/mariadb-connector-c:0= )
	odbc? ( iodbc? ( dev-db/libiodbc )
		!iodbc? ( dev-db/unixODBC ) )
	sqlite? ( dev-db/sqlite:3 )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
	xml? ( dev-libs/expat )
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${P}-release"

src_prepare() {
	cmake_src_prepare

	if use test ; then
		# ignore missing tests on experimental library
		# and tests requiring running DB-servers, internet connections, etc.
		sed -i -e '/testsuite/d' \
			{Data/{MySQL,ODBC},MongoDB,Net,NetSSL_OpenSSL,PDF,Redis}/CMakeLists.txt || die
		# Poco expands ~ using passwd, which does not match $HOME in the build environment
		sed -i -e '/CppUnit_addTest.*testExpand/d' \
			Foundation/testsuite/src/PathTest.cpp || die
		# ignore failing Crypto test since upstream does not seem to care,
		# see https://github.com/pocoproject/poco/issues/1209
		sed -i -e '/RSATest, testRSACipherLarge/d' \
			Crypto/testsuite/src/RSATest.cpp || die
	fi
}

src_configure() {
	# apache support is dead and buggy, https://github.com/pocoproject/poco/issues/1764
	local mycmakeargs=(
		-DPOCO_UNBUNDLED=ON
		-DENABLE_APACHECONNECTOR=OFF
		-DENABLE_CPPPARSER="$(usex cppparser)"
		-DENABLE_CRYPTO="$(usex crypto)"
		-DENABLE_DATA="$(usex data)"
		-DENABLE_DATA_MYSQL="$( if use mysql || use mariadb ; then echo ON ; else echo OFF ; fi )"
		-DENABLE_DATA_ODBC="$(usex odbc)"
		-DENABLE_DATA_POSTGRESQL="$(usex postgres)"
		-DENABLE_DATA_SQLITE="$(usex sqlite)"
		-DENABLE_FOUNDATION=ON
		-DENABLE_ENCODINGS="$(usex encodings)"
		-DENABLE_ENCODINGS_COMPILER="$(usex encodings_compiler)"
		-DENABLE_JSON="$(usex json)"
		-DENABLE_JWT="$(usex jwt)"
		-DENABLE_MONGODB="$(usex mongodb)"
		-DENABLE_NET="$(usex net)"
		-DENABLE_NETSSL="$(usex ssl)"
		-DENABLE_NETSSL_WIN=OFF
		-DENABLE_PAGECOMPILER="$(usex pagecompiler)"
		-DENABLE_PAGECOMPILER_FILE2PAGE="$(usex file2pagecompiler)"
		-DENABLE_PDF="$(usex pdf)"
		-DENABLE_POCODOC="$(usex pocodoc)"
		-DENABLE_REDIS="$(usex redis)"
		-DENABLE_SEVENZIP="$(usex 7zip)"
		-DENABLE_TESTS="$(usex test)"
		-DENABLE_UTIL="$(usex utils)"
		-DENABLE_XML="$(usex xml)"
		-DENABLE_ZIP="$(usex zip)"
		-DFORCE_OPENSSL=OFF
	)

	cmake_src_configure
}

src_test() {
	POCO_BASE="${S}" cmake_src_test
}

src_install() {
	cmake_src_install

	if use examples ; then
		for sd in */samples ; do
			insinto /usr/share/doc/${PF}/examples/${sd%/samples}
			doins -r ${sd}
		done
		find "${D}/usr/share/doc/${PF}/examples" \
			-iname "*.sln" -or -iname "*.vcproj" -or \
			-iname "*.vmsbuild" -or -iname "*.properties" \
			-delete
	fi
}
