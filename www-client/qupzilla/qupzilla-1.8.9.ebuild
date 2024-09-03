# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
MY_PN="QupZilla"
MY_P=${MY_PN}-${PV}
PLOCALES="ar_SA bg_BG ca_ES cs_CZ da_DK de_DE el_GR es_ES es_MX es_VE eu_ES fa_IR fi_FI fr_FR gl_ES he_IL hr_HR hu_HU id_ID it_IT ja_JP ka_GE lg lt lv_LV nl_NL nqo pl_PL pt_BR pt_PT ro_RO ru_RU sk_SK sr@ijekavianlatin sr@ijekavian sr@latin sr sv_SE tr_TR uk_UA uz@Latn zh_CN zh_TW"
PLUGINS_HASH="7c66cb2efbd18eacbd04ba211162b1a042e5b759"
PLUGINS_VERSION="2015.06.05" # if there are no updates, we can use the older archive

inherit eutils l10n multilib virtualx qmake-utils vcs-snapshot

DESCRIPTION="Qt WebKit web browser"
HOMEPAGE="http://www.qupzilla.com/"
SRC_URI="https://github.com/${MY_PN}/${PN}/releases/download/v${PV}/${MY_P}.tar.xz
	https://github.com/${MY_PN}/${PN}-plugins/archive/${PLUGINS_HASH}.tar.gz -> ${PN}-plugins-${PLUGINS_VERSION}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm ~ppc64 x86"
IUSE="dbus debug gnome-keyring kde libressl nonblockdialogs +qt4 qt5"
REQUIRED_USE="^^ ( qt4 qt5 )
	kde? ( qt4 )"

RDEPEND="
	x11-libs/libX11
	gnome-keyring? ( gnome-base/gnome-keyring )
	kde? (
		kde-base/kdelibs:4
		kde-apps/kwalletd:4
	)
	libressl? ( dev-libs/libressl )
	!libressl? ( dev-libs/openssl:0 )
	qt4? (
		>=dev-qt/qtcore-4.8:4
		>=dev-qt/qtgui-4.8:4
		>=dev-qt/qtscript-4.8:4
		>=dev-qt/qtsql-4.8:4[sqlite]
		>=dev-qt/qtwebkit-4.8:4
		dbus? ( >=dev-qt/qtdbus-4.8:4 )
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtconcurrent:5
		dev-qt/qtnetwork:5[ssl]
		dev-qt/qtprintsupport:5
		dev-qt/qtscript:5
		dev-qt/qtsql:5[sqlite]
		dev-qt/qtwebkit:5
		dev-qt/qtwidgets:5
		dev-qt/qtx11extras:5
		dbus? ( dev-qt/qtdbus:5 )
	)
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	qt5? ( dev-qt/linguist-tools:5 )"

DOCS=( AUTHORS CHANGELOG FAQ README.md )
S=${WORKDIR}/${MY_P}

src_prepare() {
	rm_plugin_loc() {
		sed -i -e "s:translations/${1}.ts::" src/plugins/*/*.pro || die
		sed -i -e "\:<file>locale/${1}.qm</file>:d" src/plugins/*/*.qrc || die

		rm -f "${S}"/src/plugins/*/translations/"${1}".ts #not fatal
	}

	rm_loc() {
		# remove localizations the user has not specified
		sed -i -e "/${1}.ts/d" translations/translations.pri || die
		rm_plugin_loc "${1}"
		rm "${S}"/translations/"${1}".ts || die
	}

	mv_replace() {
		#move folder to new location and delete existing destination if there is a clash
		for replaced in "${1}"/* ; do
                	rm -rf "${2}"/"$(basename "${replaced}")" #not fatal
                	mv -f "${replaced}" "${2}" || die
        	done
	}

	epatch_user

	# move files from the plugins archive into qupzilla build tree
	mv_replace "${WORKDIR}"/${PN}-plugins-${PLUGINS_VERSION}/plugins/ "${S}"/src/plugins/ || die
	mv_replace "${WORKDIR}"/${PN}-plugins-${PLUGINS_VERSION}/themes/ "${S}"/bin/themes/ || die
	mv_replace "${WORKDIR}"/${PN}-plugins-${PLUGINS_VERSION}/scripts/ "${S}"/scripts/ || die
	rm -rf "${WORKDIR}"/${PN}-plugins-${PLUGINS_VERSION}/ || die

	# remove outdated prebuilt localizations
	rm -f "${S}"/bin/locale/* || die
        rm -f "${S}"/src/plugins/*/locale/*

	# remove empty locale
	rm "${S}"/translations/empty.ts || die

	l10n_find_plocales_changes "translations" "" ".ts"
	l10n_for_each_disabled_locale_do rm_loc

	# remove translations from plugins that are not present in locales
	for translation in "${S}"/src/plugins/*/translations/*.ts ; do
		if [ ! -f "${S}"/translations/"$(basename "${translation}")" ] ; then
			rm_plugin_loc "$(basename "${translation/.ts/}")"
		fi
	done
}

src_configure() {
	# see BUILDING document for explanation of options
	export \
		QUPZILLA_PREFIX="${EPREFIX}/usr/" \
		USE_LIBPATH="${EPREFIX}/usr/$(get_libdir)" \
		DISABLE_DBUS=$(usex dbus '' 'true') \
		KDE_INTEGRATION=$(usex kde 'true' '') \
		NONBLOCK_JS_DIALOGS=$(usex nonblockdialogs 'true' '') \
                DISABLE_UPDATES_CHECK='true'

	if use qt4 ; then
		eqmake4 $(use gnome-keyring && echo "DEFINES+=GNOME_INTEGRATION")
	else
		eqmake5 $(use gnome-keyring && echo "DEFINES+=GNOME_INTEGRATION")
	fi
}

src_compile() {
	# workaround translations generation in parallel build
	local LRELEASE="$(use qt4 && echo "$(qt4_get_bindir)"/lrelease || echo "$(qt5_get_bindir)"/lrelease)"
	for translation in "${S}"/translations/*.ts ; do
		mkdir -p "$(dirname "${translation}")"/../bin/locale/
		"$LRELEASE" -compress -removeidentical -silent "${translation}" \
		    -qm "$(dirname "${translation}")"/../bin/locale/"$(basename "${translation/.ts/.qm}")" || die
	done
	for translation in "${S}"/src/plugins/*/translations/*.ts ; do
		mkdir -p "$(dirname "${translation}")"/../locale/
		"$LRELEASE" -compress -removeidentical -silent "${translation}" \
		    -qm "$(dirname "${translation}")"/../locale/"$(basename "${translation/.ts/.qm}")" || die
	done

	emake
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}

pkg_postinst() {
	if has_version www-plugins/adobe-flash; then
		ewarn "For using adobe flash plugin you may need to run"
		ewarn "    \"paxctl-ng -m /usr/bin/qupzilla\""
	fi
}
