# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NB: The $PV tracks the *repo launcher version*, not the last signed release
# of the repo project.  They are confusingly different currently.

EAPI="7"

PYTHON_COMPAT=( python3_{6,7} )

inherit python-r1

DESCRIPTION="Quickly rewrite git repository history (filter-branch replacement)"
HOMEPAGE="https://github.com/newren/git-filter-repo"
SRC_URI="https://github.com/newren/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"

HTML_DOCS="${S}/Documentation/html/${PN}.html"

#Workaround EPYTHON not passed properly like this: python_foreach_impl dosym "$(python_get_scriptdir)/$1" "$(python_get_sitedir)/$2"
python_newmodulesym() {
        debug-print-function ${FUNCNAME} "${@}"

        [[ ${EPYTHON} ]] || die 'No Python implementation set (EPYTHON is null).'

	dosym "$(realpath "$(python_get_scriptdir)/$1" --relative-to="$(python_get_sitedir)")" "$(python_get_sitedir)/$2"
	python_optimize "${D}/$(python_get_sitedir)"
}

src_install() {
	python_foreach_impl python_doscript "${S}/${PN}"
	python_foreach_impl python_newmodulesym "${PN}" "${PN//-/_}.py"
	doman "${S}/Documentation/man1/${PN}.1"
	use doc && einstalldocs
}
