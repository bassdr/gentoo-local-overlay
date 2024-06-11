# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..11} pypy3 )
inherit distutils-r1

DESCRIPTION="Wrapper script for OpenConnect supporting Azure AD (SAMLv2) authentication to Cisco SSL-VPNs"
HOMEPAGE="https://github.com/vlaci/openconnect-sso https://pypi.org/project/openconnect-sso/"
SRC_URI="https://files.pythonhosted.org/packages/source/${PN::1}/${PN}/${P}.tar.gz"

LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"

DOCS="README.md"

RDEPEND="
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/colorama[${PYTHON_USEDEP}]
	dev-python/importlib-metadata[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/keyring[${PYTHON_USEDEP}]
	dev-python/prompt-toolkit[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/structlog[${PYTHON_USEDEP}]
	dev-python/tomli[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-python/PyQtWebEngine[${PYTHON_USEDEP}]
	dev-python/PySocks[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/save_config_as_cached_pickle.patch"
)
