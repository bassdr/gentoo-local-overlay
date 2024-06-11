# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="Noto fonts support tools and scripts plus web site generation"
HOMEPAGE="https://github.com/googlei18n/nototools"

SRC_URI="https://github.com/googlefonts/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc64 x86"

RDEPEND="
	media-gfx/scour
	>=dev-python/booleanOperations-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/defcon-0.6.0[${PYTHON_USEDEP}]
	>=dev-python/fonttools-4.11.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-7.1.2[${PYTHON_USEDEP}]
	>=dev-python/pyclipper-1.1.0-r1[${PYTHON_USEDEP}]
"

# Some tests weren't ported to python3 yet
RESTRICT="test"

src_prepare() {
	sed -i '/setuptools_scm/d' setup.py
	sed -i '/use_scm_version/d' setup.py
	echo "version = '${PV}'" > nototools/_version.py
	default
}

python_test() {
	esetup.py test
}
