# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:$

EAPI=5
inherit webapp

DESCRIPTION="Magento Community Edition is open source eCommerce software used to power hundreds of thousands of online stores."
HOMEPAGE="http://magento.com"
SRC_URI="https://github.com/magento/magento2/archive/${PV/_/-}.tar.gz -> ${P}.tar.gz"

LICENSE="OSL-3.0 AFL-3.0"
KEYWORDS="~amd64"

DEPEND=">=dev-lang/php-5.4[xml,ctype,gd,simplexml,crypt,hash,curl,iconv,intl,xslt,xmlwriter]
        dev-php/composer"

need_httpd

pkg_setup() {
  webapp_pkg_setup
}

src_unpack() {
  unpack "${A}"
  mv ${P//_/-} ${P}
}

src_configure() {
  composer install || die "Composer install failed in folder: `pwd`"
}

src_install() {
        webapp_src_preinst

        # First we install docs and then copy everything left into htdocs dir
        # to avoid bugs like #236411.

        # We ensure the directories are prepared for writing.  The post-
        # install instructions guide the user to enable the feature.
        local DOCS="LICENSE.txt LICENSE_AFL.txt README.md CHANGELOG.md CONTRIBUTING.md CONTRIBUTOR_LICENSE_AGREEMENT.html"
        dodoc ${DOCS}

        # Clean everything not used at the site...
        rm -rf ${DOCS} .gitignore || die

        # Install
        insinto "${MY_HTDOCSDIR}"
        doins -r .

        # writable folders will be owned by the server
        webapp_serverowned "${MY_HTDOCSDIR}"/app/etc
        webapp_serverowned "${MY_HTDOCSDIR}"/var
        webapp_serverowned "${MY_HTDOCSDIR}"/pub/media
        webapp_serverowned "${MY_HTDOCSDIR}"/pub/static

        webapp_src_install
}

pkg_postinst() {
        webapp_pkg_postinst
}

