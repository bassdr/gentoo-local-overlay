# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay: MuseScore General SoundFont with TiMidity eselect integration

EAPI=8

DESCRIPTION="MuseScore General SoundFont — high-quality GM/GS instrument set"
HOMEPAGE="https://musescore.org/en/handbook/soundfonts-and-sfz-files"
MY_PN="MuseScore_General"
SRC_URI="https://ftp.osuosl.org/pub/musescore/soundfont/${MY_PN}/${MY_PN}.sf2 -> ${P}.sf2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"
RESTRICT="binchecks strip"

RDEPEND="app-eselect/eselect-timidity"

S="${WORKDIR}"

src_unpack() {
	# Single SF2 file, not a tarball — copy into workdir
	cp "${DISTDIR}/${P}.sf2" "${S}/${MY_PN}.sf2" || die
}

src_install() {
	# Install SoundFont alongside other SF2 files
	insinto /usr/share/sounds/sf2
	doins "${MY_PN}.sf2"

	# TiMidity patchset configuration for eselect-timidity
	insinto /usr/share/timidity/musescore-soundfont
	doins "${FILESDIR}"/timidity.cfg
}

pkg_postinst() {
	eselect timidity update --global --if-unset

	elog "MuseScore General SoundFont installed to /usr/share/sounds/sf2/"
	elog
	elog "To use with TiMidity++ (system-wide):"
	elog "  eselect timidity set --global musescore-soundfont"
	elog
	elog "Note: this patchset may not appear in 'eselect timidity list'"
	elog "due to a hardcoded list in the eselect module, but manual"
	elog "selection by name works correctly."
}

