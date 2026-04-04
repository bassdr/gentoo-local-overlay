# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay: uses bassdr/timidity fork with all patches pre-applied
# and pipewire native support. Adds system-service USE flag for OpenRC
# system-wide MIDI sequencer running as acct-user/timidity.

EAPI=8

inherit autotools desktop elisp-common flag-o-matic linux-info systemd udev xdg

DESCRIPTION="Handy MIDI to WAV converter with OSS and ALSA output support"
HOMEPAGE="https://github.com/bassdr/timidity"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/bassdr/timidity.git"
	EGIT_BRANCH="main"
else
	SRC_URI="https://github.com/bassdr/timidity/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~ppc ~ppc64 ~riscv ~sparc ~x86"
	S="${WORKDIR}/timidity-${PV}"
fi

LICENSE="GPL-2+"
SLOT="0"
IUSE="alsa ao cpu_flags_arm_neon cpu_flags_x86_sse4_1 emacs flac gtk jack motif nas ncurses ogg oss pipewire selinux slang speex system-service tk vorbis X Xaw3d"

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
	pipewire? (
		acct-group/pipewire
		>=media-video/pipewire-1.6.1-r1[sound-server,system-service?]
	)
	selinux? ( sec-policy/selinux-timidity )
	system-service? ( >=acct-user/timidity-0-r3 )
"

PDEPEND="|| ( media-sound/timidity-eawpatches media-sound/timidity-freepats )"

# dist/ files ship in the source tarball
DIST="${S}/dist"

DOCS=( AUTHORS ChangeLog NEWS README.md "${DIST}"/config/timidity.cfg )

_check_kernel_config() {
	if use pipewire; then
		local CONFIG_CHECK="~PREEMPT_RT ~HZ_1000 !~HZ_PERIODIC"
		local WARNING_PREEMPT_RT="CONFIG_PREEMPT_RT is not set — recommended for low-latency MIDI synthesis (reduces worst-case scheduling latency from ~10ms to ~0.1ms)"
		local WARNING_HZ_1000="CONFIG_HZ_1000 is not set — recommended for low-latency audio (finer timer granularity)"
		local WARNING_HZ_PERIODIC="CONFIG_HZ_PERIODIC is set — NO_HZ_IDLE or NO_HZ_FULL is recommended for low-latency audio (reduces timer interrupt jitter)"
		check_extra_config
	fi
}

pkg_pretend() {
	_check_kernel_config
}

pkg_setup() {
	_check_kernel_config
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# Float mixing (auto-enabled with PipeWire) adds -O3 -ffast-math via
	# configure.ac.  Promote CFLAGS to -O3 here so it doesn't appear after
	# the distro's -O2 as a redundant override.  Users who explicitly want
	# -O2 can set it in package.env (it will still be overridden by
	# configure's append, but that's the upstream default for float mixing).
	if use pipewire; then
		replace-flags '-O*' '-O3'
		append-flags '-ffast-math'
	fi

	use flac && audios+=",flac"
	use speex && audios+=",speex"
	use vorbis && audios+=",vorbis"
	use ogg && audios+=",ogg"
	use oss && audios+=",oss"
	use jack && audios+=",jack"
	use ao && audios+=",ao"
	use alsa && audios+=",alsa"
	use pipewire && audios+=",pipewire"
	use nas && audios+=",nas"

	local myeconfargs=(
		--localstatedir=/var/state/${PN}
		--with-module-dir="${EPREFIX}/usr/share/timidity"
		--with-lispdir="${SITELISP}/${PN}"
		--with-xawlib=$(usex Xaw3d 'xaw3d' 'xaw')
		--with-elf
		--enable-server
		--enable-network
		--enable-dynamic
		--enable-vt100
		--enable-spline=gauss
		--enable-fixed-resamplation
		--enable-audio=${audios}
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
		$(use motif && use_with motif x)
		$(use_with nas nas-library "/usr/$(get_libdir)/libaudio.so")
		$(use nas && use_with nas x)
		$(use_enable alsa alsaseq)
		$(use pipewire || use_with alsa default-output alsa)
		$(use_enable pipewire pipewiresyn)
		$(use pipewire && use_with pipewire default-output pipewire)
		$(usex arm64 '--enable-simd-mixing' '')
		$(usex cpu_flags_arm_neon '--enable-simd-mixing' '')
		$(usex cpu_flags_x86_sse4_1 '--enable-simd-mixing' '')
	)

	if ! use X; then
		use nas && ewarn "Basic X11 support will be enabled because required by nas."
		use motif && ewarn "Basic X11 support will be enabled because required by motif."
	fi

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs

	# System-service: OpenRC init, log dir, systemd unit, udev auto-connect
	if use system-service; then
		newconfd "${DIST}"/openrc/timidity.confd timidity
		newinitd "${DIST}"/openrc/timidity.initd timidity

		if ! use pipewire; then
			# Upstream defaults to PipeWire (-ipA); switch to ALSA sequencer
			sed -i \
				-e 's/^: "${TIMIDITY_INTERFACE:=-ipA}"/: "${TIMIDITY_INTERFACE:=-iA}"/' \
				"${ED}"/etc/init.d/timidity || die
		fi

		systemd_dounit "${DIST}"/systemd/timidity.service

		# udev rule + helper to auto-connect MIDI devices to the sequencer
		udev_dorules "${DIST}"/udev/99-timidity-midi.rules
		exeinto /usr/lib/udev
		doexe "${DIST}"/udev/timidity-midi-connect
	fi

	if use pipewire; then
		# Low-latency PipeWire quantum config (user activates via symlink/copy)
		insinto /usr/share/pipewire/pipewire.conf.avail
		doins "${DIST}"/pipewire/10-timidity-low-latency.conf

		# systemd user service for per-user PipeWire MIDI synthesis
		systemd_douserunit "${DIST}"/systemd/timidity-user.service
	fi

	insinto /etc
	newins "${DIST}"/config/timidity.cfg timidity.cfg

	dodir /usr/share/timidity
	dosym ../../../etc/timidity.cfg /usr/share/timidity/timidity.cfg

	if use emacs; then
		elisp-site-file-install "${DIST}/50${PN}-gentoo.el"
	fi

	doicon "${DIST}"/desktop/timidity.xpm
	newmenu "${DIST}"/desktop/timidity.desktop timidity.desktop

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

	if use pipewire; then
		elog
		elog "Low-latency MIDI synthesis (PipeWire):"
		elog
		elog "  Latency is controlled by PipeWire's quantum setting (-B is ignored)."
		elog "  A config fragment has been installed to:"
		elog "    /usr/share/pipewire/pipewire.conf.avail/10-timidity-low-latency.conf"
		elog
		elog "  To activate, copy or symlink it:"
		elog "    mkdir -p /etc/pipewire/pipewire.conf.d"
		elog "    ln -s /usr/share/pipewire/pipewire.conf.avail/10-timidity-low-latency.conf \\"
		elog "          /etc/pipewire/pipewire.conf.d/"
		elog "    systemctl --user restart pipewire"
		elog
		elog "  For best results, also use --realtime-priority=50 and ensure your"
		elog "  user is in the 'pipewire' group (for memlock + rtprio ulimits)."
		elog
		elog "  Monitor for xruns with: pw-top"
		elog
	fi

	if use system-service; then
		# Add timidity user to the pipewire group so it can access the PipeWire socket.
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
			elog "Output defaults to PipeWire native (-OW) with PipeWire MIDI (-ipA)."
		else
			elog "Output defaults to ALSA (-Os) with ALSA sequencer (-iA)."
		fi
		elog "See /etc/conf.d/timidity for available options."
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
