# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Karaoke Mugen, standing for infinite karaoke, is a playlist manager for your parties."
HOMEPAGE="https://mugen.karaokes.moe/en/"

GUEST_AVATARS_PV=0f71e6c9d45578ba7d33ac6ab9e05d3e20bc8325
LIB_PV=8bc0a108398b31cffefe98de3f44ae4fbca48b49

SRC_URI="
	https://gitlab.com/karaokemugen/code/karaokemugen-app/-/archive/v${PV}/${PN}-v${PV}.tar.bz2
	https://gitlab.com/karaokemugen/medias/guest-avatars/-/archive/${GUEST_AVATARS_PV}/guest-avatars-${GUEST_AVATARS_PV}.tar.bz2 -> ${P}-guest-avatars.tar.bz2
	https://gitlab.com/karaokemugen/code/lib/-/archive/${LIB_PV}/lib-${LIB_PV}.tar.bz2 -> ${P}-lib.tar.bz2
"

PROPERTIES=live

S=${WORKDIR}/${PN}-v${PV}

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm64"
IUSE=""

RDEPEND="
	>=media-video/mpv-0.33
	>=media-video/ffmpeg-3
	>=dev-db/postgresql-16
	>=sys-devel/patch-2.7
	dev-lang/typescript
	net-libs/nodejs
	sys-apps/yarn
	sys-apps/dmidecode
"

src_unpack() {
	default
	rmdir ${PN}-v${PV}/assets/guestAvatars/ || die
	mv guest-avatars-${GUEST_AVATARS_PV} ${PN}-v${PV}/assets/guestAvatars/
	rmdir ${PN}-v${PV}/src/lib/ || die
	mv lib-${LIB_PV} ${PN}-v${PV}/src/lib/ || die

	cd ${S}
	yarn install --frozen-lockfile || die
	cd ${S}/kmfrontend
	yarn install --frozen-lockfile || die
}

src_compile() {
	yarn build || die
	yarn buildkmfrontend || die
}

src_install() {
	mkdir -p "${ED}/opt/${PN}" || die
	cp -r . "${ED}/opt/${PN}" || die
}

pkg_postinst() {
	xdg_pkg_postinst
}
