# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools

DESCRIPTION="Shairport Sync is an AirPlay audio player"
HOMEPAGE="https://github.com/mikebrady/shairport-sync"
SRC_URI="https://github.com/mikebrady/shairport-sync/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"

SLOT="0"

KEYWORDS="arm64"

IUSE="+airplay2 +alac alsa convolution daemon pipewire pulseaudio jack mbedtls +openssl soundio soxr systemd"

REQUIRED_USE="
	|| ( alsa jack pipewire pulseaudio )
	^^ ( openssl mbedtls )
"

BDEPEND="
	airplay2? ( app-editors/vim-core )
"

RDEPEND="
	acct-user/${PN}
	acct-group/${PN}
	dev-libs/libconfig
	net-dns/avahi
	airplay2? ( app-pda/libplist dev-libs/libsodium >=net-misc/nqptp-1.2.4 )
	alac? ( media-libs/alac )
	alsa? ( media-libs/alsa-lib )
	convolution? ( media-libs/libsndfile )
	daemon? ( dev-libs/libdaemon )
	jack? ( virtual/jack )
	openssl? ( dev-libs/openssl )
	pipewire? ( media-video/pipewire )
	pulseaudio? ( media-libs/libpulse )
	mbedtls? ( net-libs/mbedtls )
	soundio? ( media-libs/libsoundio )
	soxr? ( media-libs/soxr )
"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/gentoo-makefile-00.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--with-avahi \
		--with-libdaemon \
		--with-metadata \
		--with-pipe \
		--with-stdout \
		$(use_with airplay2 airplay-2) \
		$(use_with alac apple-alac) \
		$(use_with alsa) \
		$(use_with convolution) \
		$(use_with daemon libdaemon) \
		$(use_with jack) \
		--with-ssl=$(usex mbedtls 'mbedtls' 'openssl') \
		$(use_with pipewire pw) \
		$(use_with pulseaudio pa) \
		$(use_with soundio) \
		$(use_with soxr) \
		$(use_with systemd)
		$(use_with !systemd 'systemv')
}
