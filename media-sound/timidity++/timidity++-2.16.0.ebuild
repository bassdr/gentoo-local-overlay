# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay: uses bassdr/timidity fork with all patches pre-applied
# and pipewire native support. Adds system-service USE flag for OpenRC
# system-wide MIDI sequencer running as acct-user/timidity.

EAPI=8

inherit autotools desktop elisp-common flag-o-matic systemd udev xdg

MY_PV="${PV/_/-}"
MY_P="TiMidity++-${MY_PV}"

DESCRIPTION="Handy MIDI to WAV converter with OSS and ALSA output support"
HOMEPAGE="https://github.com/bassdr/timidity"
SRC_URI="https://github.com/bassdr/timidity/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/timidity-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="alsa ao emacs flac gtk jack motif nas ncurses ogg oss pipewire selinux slang speex system-service tk vorbis X Xaw3d"

REQUIRED_USE="
	tk? ( X )
	system-service? ( || ( alsa pipewire ) )
"

DEPEND="
	alsa? ( media-libs/alsa-lib )
	ao? ( >=media-libs/libao-0.8.5 )
	emacs? ( >=app-editors/emacs-23.1:* )
	flac? ( media-libs/flac:= )
	gtk? ( x11-libs/gtk+:2 )
	jack? ( virtual/jack )
	motif? ( >=x11-libs/motif-2.3:0 )
	nas? ( >=media-libs/nas-1.4 )
	ncurses? ( sys-libs/ncurses:0= )
	ogg? ( media-libs/libogg )
	pipewire? ( media-video/pipewire:= )
	slang? ( sys-libs/slang )
	speex? ( media-libs/speex )
	tk? ( dev-lang/tk:= )
	vorbis? ( media-libs/libvorbis )
	X? (
		media-libs/libpng:=
		x11-libs/libX11
		x11-libs/libXext
		Xaw3d? ( x11-libs/libXaw3d )
		!Xaw3d? ( x11-libs/libXaw )
	)
"

RDEPEND="
	${DEPEND}
	app-eselect/eselect-timidity
	alsa? ( media-sound/alsa-utils )
	selinux? ( sec-policy/selinux-timidity )
	system-service? (
		acct-group/audio
		acct-group/pipewire
		>=acct-user/timidity-0-r3
		>=media-video/pipewire-1.6.1-r1[system-service,sound-server]
	)
"

PDEPEND="|| ( media-sound/timidity-eawpatches media-sound/timidity-freepats )"

SITEFILE=50${PN}-gentoo.el

DOCS=( AUTHORS ChangeLog NEWS README.md "${FILESDIR}"/timidity.cfg-r1 )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	export EXTRACFLAGS="${CFLAGS}" #385817

	local audios
	# List by preference
	local xaw_provider=$(usex Xaw3d 'xaw3d' 'xaw')

	# configure workarounds: configure.in here is written for an old version
	# of autoconf and upstream seems quite dead.
	#
	# 1. Avoid janky configure test breaking
	# ```checking for sys/wait.h that is POSIX.1 compatible... yes
	# ./configure: 7995: test: =: unexpected operator```
	export ac_cv_header_sys_time_h=yes
	#
	# 2. And yes, we expect standard header locations (this configure test is flaky for us too)
	# This avoids a bunch of implicit decl. errors which only happen with USE=-Xaw3d(?!)
	append-cppflags -DSTDC_HEADERS

	# bug #943939
	append-cflags -std=gnu17

	local myeconfargs=(
		--localstatedir=/var/state/${PN}
		--with-module-dir="${EPREFIX}/usr/share/timidity"
		--with-lispdir="${SITELISP}/${PN}"
		--with-elf
		--enable-server
		--enable-network
		--enable-dynamic
		--enable-vt100
		--enable-spline=cubic
		$(use_enable emacs)
		$(use_enable slang)
		$(use_enable ncurses)
		$(use_with X x)
		$(use_enable X spectrogram)
		$(use_enable X wrd)
		$(use_enable X xskin)
		$(use_enable X xaw)
		$(use_enable gtk)
		$(use_enable tk tcltk)
		$(use_enable motif)
		$(use_with Xaw3d xawlib ${xaw_provider})
		$(use_enable pipewire pipewiresyn)
	)

	use flac && audios+=",flac"
	use speex && audios+=",speex"
	use vorbis && audios+=",vorbis"
	use ogg && audios+=",ogg"
	use oss && audios+=",oss"
	use jack && audios+=",jack"
	use ao && audios+=",ao"
	use pipewire && audios+=",pipewire"

	if use nas; then
		audios+=",nas"
		myeconfargs+=(
			--with-nas-library="/usr/$(get_libdir)/libaudio.so"
			--with-x
		)
		use X || ewarn "Basic X11 support will be enabled because required by nas."
	fi

	if use alsa; then
		audios+=",alsa"
		myeconfargs+=(
			--with-default-output=alsa
			--enable-alsaseq
		)
	fi

	if use motif; then
		myeconfargs+=(
			--with-x
		)
		use X || ewarn "Basic X11 support will be enabled because required by motif."
	fi

	# needs to come after all audios have been collected
	myeconfargs+=(
		--enable-audio=${audios}
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs

	# System-service: OpenRC init, log dir, systemd unit, udev auto-connect
	if use system-service; then
		newconfd "${FILESDIR}"/timidity.confd timidity
		newinitd "${FILESDIR}"/timidity.initd timidity

		if use pipewire; then
			# Switch defaults to PipeWire: -ip interface, -OW output
			sed -i \
				-e 's/^: "${TIMIDITY_INTERFACE:=-iA}"/: "${TIMIDITY_INTERFACE:=-ip}"/' \
				"${ED}"/etc/init.d/timidity || die
			sed -i \
				-e 's/^TIMIDITY_OPTS="-B2,8 -EFreverb=0"/TIMIDITY_OPTS="-OW -EFreverb=0"/' \
				"${ED}"/etc/conf.d/timidity || die
		fi

		systemd_dounit "${FILESDIR}"/timidity.service

		# udev rule + helper to auto-connect MIDI devices to the sequencer
		udev_dorules "${FILESDIR}"/99-timidity-midi.rules
		exeinto /usr/lib/udev
		doexe "${FILESDIR}"/timidity-midi-connect
	fi

	insinto /etc
	newins "${FILESDIR}"/timidity.cfg-r1 timidity.cfg

	dodir /usr/share/timidity
	dosym ../../../etc/timidity.cfg /usr/share/timidity/timidity.cfg

	if use emacs; then
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	doicon "${FILESDIR}"/timidity.xpm
	newmenu "${FILESDIR}"/timidity.desktop.2 timidity.desktop

	# Order of preference: gtk, X (Xaw), ncurses, slang
	# Do not create menu item for terminal ones
	local interface="-id"
	local terminal="true"
	local nodisplay="true"
	if use gtk || use X; then
		interface="-ia"
		terminal="false"
		nodisplay="false"
		use gtk && interface="-ig"
	elif use ncurses || use slang; then
		local interface="-is"
		use ncurses && interface="-in"
	fi
	sed -e "s/Exec=timidity/Exec=timidity ${interface}/" \
		-e "s/Terminal=.*/Terminal=${terminal}/" \
		-e "s/NoDisplay=.*/NoDisplay=${nodisplay}/" \
		-i "${ED}"/usr/share/applications/timidity.desktop || die
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	udev_reload
	use emacs && elisp-site-regen

	elog "A timidity config file has been installed in /etc/timidity.cfg."
	elog "Do not edit this file as it will interfere with the eselect timidity tool."
	elog "The tool 'eselect timidity' can be used to switch between installed patchsets."

	if use system-service; then
		# Add timidity user to the pipewire group so it can access
		# the PipeWire socket.
		if use pipewire; then
			if ! id -nG timidity 2>/dev/null | grep -qw pipewire; then
				usermod -aG pipewire timidity || ewarn "Failed to add timidity to pipewire group"
			fi
		fi

		elog
		elog "system-service (OpenRC): installed /etc/init.d/timidity"
		elog "Runs TiMidity++ as the 'timidity' user (groups: audio, pipewire)."
		elog
		elog "Enable with:"
		elog "  rc-update add timidity default"
		elog
		if use pipewire; then
			elog "Output defaults to PipeWire native (-OW) with PipeWire MIDI (-ip)."
			elog "To route through PulseAudio instead, enable USE=ao and set"
			elog "TIMIDITY_OPTS=\"-OO -EFreverb=0\" in /etc/conf.d/timidity."
		else
			elog "Output defaults to ALSA (-Os) with ALSA sequencer (-iA)."
			elog "To route through PipeWire, enable USE=ao and set"
			elog "TIMIDITY_OPTS=\"-OO -EFreverb=0\" in /etc/conf.d/timidity."
		fi
		elog
		elog "A udev rule has been installed to auto-connect USB MIDI devices to"
		elog "the TiMidity sequencer when they are plugged in."
		elog
		elog "Service log: /var/log/timidity.log"
		elog
	fi

	if use sparc; then
		elog "Only saving to wave file and ALSA soundback has been tested working."
	fi

	xdg_pkg_postinst
}

pkg_postrm() {
	udev_reload
	use emacs && elisp-site-regen
	xdg_pkg_postrm
}
