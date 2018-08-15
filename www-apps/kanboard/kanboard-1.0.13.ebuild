# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=5
inherit webapp

DESCRIPTION="Kanboard is a simple visual task board web application."
HOMEPAGE="http://kanboard.net"
SRC_URI="https://github.com/fguillot/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="AGPL-3"
KEYWORDS="~amd64"

DEPEND="|| (
          www-servers/apache
          www-servers/nginx
        )
        >=dev-lang/php-5.3.7[unicode]
        dev-php/composer"

pkg_setup() {
  webapp_pkg_setup
}

src_configure() {
  webapp_src_configure
  composer install || die "Composer install failed in folder: `pwd`"
  sed -i -e "s/define('APP_VERSION', 'master')/define('APP_VERSION', '${PV}')/g" \
    app/constants.php || die "Could not set APP_VERSION in '`pwd`/app/constants.php'"
}

src_install() {
        webapp_src_preinst

        # First we install docs and then copy everything left into htdocs dir
        # to avoid bugs like #236411.

        # We ensure the directories are prepared for writing.  The post-
        # install instructions guide the user to enable the feature.
        local DOCS="README.markdown LICENSE"
        dodoc ${DOCS} docs/*.markdown

        # Clean everything not used at the site...
        rm -rf ${DOCS} scripts tests docs .gitignore || die

        # Install
        insinto "${MY_HTDOCSDIR}"
        doins -r .

        # sqlite database folder will be owned by the server
        webapp_serverowned "${MY_HTDOCSDIR}"/data

        webapp_src_install
}

pkg_postinst() {
        webapp_pkg_postinst
}

