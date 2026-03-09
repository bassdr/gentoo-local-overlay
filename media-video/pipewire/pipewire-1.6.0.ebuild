# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay fork: system-service USE flag now works on OpenRC.
# Installs /etc/init.d/pipewire-system (runs as acct-user/pipewire).
# See also: media-video/wireplumber with the same USE flag.

EAPI=8

# 1. Please regularly check (even at the point of bumping) Fedora's packaging
# for needed backports at https://src.fedoraproject.org/rpms/pipewire/tree/rawhide.
#
# 2. Upstream also sometimes amend release notes for the previous release to mention
# needed patches, e.g. https://gitlab.freedesktop.org/pipewire/pipewire/-/tags/0.3.55#distros
#
# 3. Keep an eye on git master (for both PipeWire and WirePlumber) as things
# continue to move quickly. It's not uncommon for fixes to be made shortly
# after releases.

# TODO: Maybe get upstream to produce `meson dist` tarballs:
# - https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3663
# - https://gitlab.freedesktop.org/pipewire/pipewire/-/merge_requests/1788
#
# Generate using https://github.com/thesamesam/sam-gentoo-scripts/blob/main/niche/generate-pipewire-docs
# Set to 1 if prebuilt, 0 if not
# (the construct below is to allow overriding from env for script)
: ${PIPEWIRE_DOCS_PREBUILT:=1}

PIPEWIRE_DOCS_PREBUILT_DEV=sam
PIPEWIRE_DOCS_VERSION="$(ver_cut 1-2).0"
# Default to generating docs (inc. man pages) if no prebuilt; overridden later
PIPEWIRE_DOCS_USEFLAG="+man"
PYTHON_COMPAT=( python3_{11..14} )
inherit meson-multilib optfeature prefix python-any-r1 systemd tmpfiles udev

if [[ ${PV} == 9999 ]] ; then
	PIPEWIRE_DOCS_PREBUILT=0
	EGIT_REPO_URI="https://gitlab.freedesktop.org/${PN}/${PN}.git"
	inherit git-r3
elif [[ ${PV} == *.9999 ]] ; then
	PIPEWIRE_DOCS_PREBUILT=0
	EGIT_REPO_URI="https://gitlab.freedesktop.org/${PN}/${PN}.git"
	EGIT_BRANCH="${PV%.*}"
	inherit git-r3
else
	if [[ ${PV} == *_p* ]] ; then
		MY_COMMIT=""
		SRC_URI="https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/${MY_COMMIT}/pipewire-${MY_COMMIT}.tar.bz2 -> ${P}.tar.bz2"
		S="${WORKDIR}"/${PN}-${MY_COMMIT}
	else
		SRC_URI="https://gitlab.freedesktop.org/${PN}/${PN}/-/archive/${PV}/${P}.tar.bz2"
	fi

	if [[ ${PIPEWIRE_DOCS_PREBUILT} == 1 ]] ; then
		SRC_URI+=" !man? ( https://dev.gentoo.org/~${PIPEWIRE_DOCS_PREBUILT_DEV}/distfiles/${CATEGORY}/${PN}/${PN}-${PIPEWIRE_DOCS_VERSION}-docs.tar.xz )"
		PIPEWIRE_DOCS_USEFLAG="man"
	fi

	KEYWORDS="~amd64 ~arm ~arm64 ~loong ~mips ~ppc ~ppc64 ~riscv ~sparc ~x86"
fi

DESCRIPTION="Multimedia processing graphs"
HOMEPAGE="https://pipewire.org/"

LICENSE="MIT LGPL-2.1+ GPL-2"
# ABI was broken in 0.3.42 for https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues/49
SLOT="0/0.4"
IUSE="${PIPEWIRE_DOCS_USEFLAG} bluetooth elogind dbus doc echo-cancel extra ffmpeg fftw flatpak gstreamer gsettings"
IUSE+=" ieee1394 jack-client jack-sdk libcamera loudness lv2 modemmanager pipewire-alsa readline roc selinux"
IUSE+=" pulseaudio sound-server ssl system-service systemd test v4l X zeroconf"

# bassdr: system-service no longer requires systemd; on OpenRC it installs
# /etc/init.d/pipewire-system running as acct-user/pipewire instead.
REQUIRED_USE="
	ffmpeg? ( extra )
	bluetooth? ( dbus )
	jack-sdk? ( !jack-client )
	modemmanager? ( bluetooth )
	!sound-server? ( !pipewire-alsa )
	jack-client? ( dbus )
"

RESTRICT="!test? ( test )"

BDEPEND="
	>=dev-build/meson-0.59
	virtual/pkgconfig
	dbus? ( >=dev-util/gdbus-codegen-2.80.5-r1 )
	doc? (
		${PYTHON_DEPS}
		>=app-text/doxygen-1.9.8
		media-gfx/graphviz
	)
	man? (
		${PYTHON_DEPS}
		>=app-text/doxygen-1.9.8
	)
"
RDEPEND="
	acct-group/audio
	acct-group/pipewire
	media-libs/alsa-lib[${MULTILIB_USEDEP}]
	sys-libs/ncurses:=[unicode(+)]
	virtual/libintl[${MULTILIB_USEDEP}]
	virtual/libudev[${MULTILIB_USEDEP}]
	bluetooth? (
		dev-libs/glib
		media-libs/fdk-aac
		media-libs/liblc3
		media-libs/libldac
		media-libs/libfreeaptx
		media-libs/opus
		media-libs/sbc
		>=net-wireless/bluez-4.101:=
		virtual/libusb:1
	)
	elogind? ( sys-auth/elogind )
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	echo-cancel? (
		media-libs/webrtc-audio-processing:=
		|| (
			>=media-libs/webrtc-audio-processing-2.0:2
			>=media-libs/webrtc-audio-processing-1.2:1
		)
	)
	extra? ( >=media-libs/libsndfile-1.0.20 )
	ffmpeg? ( media-video/ffmpeg:= )
	fftw? ( sci-libs/fftw:3.0=[${MULTILIB_USEDEP}] )
	flatpak? ( dev-libs/glib )
	gstreamer? (
		>=dev-libs/glib-2.32.0:2
		>=media-libs/gstreamer-1.10.0:1.0
		media-libs/gst-plugins-base:1.0
	)
	gsettings? ( >=dev-libs/glib-2.26.0:2 )
	ieee1394? ( media-libs/libffado[${MULTILIB_USEDEP}] )
	jack-client? ( >=media-sound/jack2-1.9.10:2[dbus] )
	jack-sdk? (
		!media-sound/jack-audio-connection-kit
		!media-sound/jack2
	)
	libcamera? ( media-libs/libcamera:= )
	loudness? ( media-libs/libebur128:=[${MULTILIB_USEDEP}] )
	lv2? ( media-libs/lilv )
	modemmanager? ( >=net-misc/modemmanager-1.10.0 )
	pipewire-alsa? ( >=media-libs/alsa-lib-1.2.10[${MULTILIB_USEDEP}] )
	pulseaudio? ( media-libs/libpulse )
	sound-server? ( !media-sound/pulseaudio-daemon )
	roc? ( >=media-libs/roc-toolkit-0.4.0:= )
	readline? ( sys-libs/readline:= )
	selinux? ( sys-libs/libselinux )
	ssl? ( dev-libs/openssl:= )
	systemd? ( sys-apps/systemd )
	system-service? ( acct-user/pipewire )
	v4l? ( media-libs/libv4l )
	X? (
		media-libs/libcanberra
		x11-libs/libX11
		x11-libs/libXfixes
	)
	zeroconf? ( net-dns/avahi )
"

DEPEND="${RDEPEND}"

PDEPEND=">=media-video/wireplumber-0.5.2"

PATCHES=(
	"${FILESDIR}"/${PN}-0.3.25-enable-failed-mlock-warning.patch
)

pkg_setup() {
	if use doc || use man ; then
		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	default

	# Used for upstream backports
	if [[ ${PV} != *9999 && -d "${FILESDIR}"/${PV} ]] ; then
		eapply "${FILESDIR}"/${PV}
	fi
}

multilib_src_configure() {
	local logind=disabled
	if multilib_is_native_abi ; then
		if use systemd ; then
			logind=enabled
		elif use elogind ; then
			logind=enabled
		fi
	fi

	local emesonargs=(
		-Ddocdir="${EPREFIX}"/usr/share/doc/${PF}

		$(meson_feature dbus)
		$(meson_native_use_feature zeroconf avahi)
		$(meson_native_use_feature doc docs)
		$(meson_native_use_feature man)
		$(meson_native_enabled examples)
		$(meson_feature test tests)
		-Dinstalled_tests=disabled
		$(meson_feature ieee1394 libffado)
		$(meson_native_use_feature gstreamer)
		$(meson_native_use_feature gstreamer gstreamer-device-provider)
		$(meson_native_use_feature gsettings)
		$(meson_native_use_feature systemd libsystemd)
		-Dlogind=${logind}
		-Dlogind-provider=$(usex systemd 'libsystemd' 'libelogind')

		# bassdr: only install systemd system units when systemd is actually in use
		-Dsystemd-system-service=$(use system-service && use systemd && echo enabled || echo disabled)
		-Dsystemd-system-unit-dir="$(systemd_get_systemunitdir)"
		-Dsystemd-user-unit-dir="$(systemd_get_userunitdir)"

		$(meson_native_use_feature systemd systemd-user-service)
		$(meson_feature pipewire-alsa)
		$(meson_feature selinux)
		-Dspa-plugins=enabled
		-Dalsa=enabled
		-Dcompress-offload=disabled
		-Daudiomixer=enabled
		-Daudioconvert=enabled
		$(meson_native_use_feature bluetooth bluez5)
		$(meson_native_use_feature bluetooth bluez5-backend-hsp-native)
		$(meson_native_use_feature bluetooth bluez5-backend-hfp-native)
		$(meson_native_use_feature modemmanager bluez5-backend-native-mm)
		$(meson_native_use_feature bluetooth bluez5-backend-ofono)
		$(meson_native_use_feature bluetooth bluez5-backend-hsphfpd)
		$(meson_native_use_feature bluetooth bluez5-codec-aac)
		$(meson_native_use_feature bluetooth bluez5-codec-aptx)
		$(meson_native_use_feature bluetooth bluez5-codec-lc3)
		$(meson_native_use_feature bluetooth bluez5-codec-ldac)
		$(meson_native_use_feature bluetooth bluez5-codec-g722)
		$(meson_native_use_feature bluetooth opus)
		$(meson_native_use_feature bluetooth bluez5-codec-opus)
		$(meson_native_use_feature bluetooth libusb)
		$(meson_native_use_feature echo-cancel echo-cancel-webrtc)
		-Dcontrol=enabled
		-Daudiotestsrc=enabled
		-Dffmpeg=disabled
		$(meson_native_use_feature ffmpeg pw-cat-ffmpeg)
		$(meson_native_use_feature flatpak)
		-Dpipewire-jack=enabled
		$(meson_native_use_feature jack-client jack)
		$(meson_use jack-sdk jack-devel)
		$(usex jack-sdk "-Dlibjack-path=${EPREFIX}/usr/$(get_libdir)" '')
		-Dsupport=enabled
		-Devl=disabled
		-Dtest=disabled
		-Dbluez5-codec-lc3plus=disabled
		$(meson_feature loudness ebur128)
		$(meson_feature fftw)
		$(meson_native_use_feature lv2)
		$(meson_native_use_feature v4l v4l2)
		$(meson_native_use_feature libcamera)
		$(meson_native_use_feature roc)
		$(meson_native_use_feature readline)
		$(meson_native_use_feature ssl raop)
		-Dvideoconvert=enabled
		-Dvideotestsrc=enabled
		-Dvolume=enabled
		-Dvulkan=disabled
		$(meson_native_use_feature extra pw-cat)
		-Dudev=enabled
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)/rules.d"
		-Dsdl2=disabled
		-Dlibmysofa=disabled
		$(meson_native_use_feature extra sndfile)
		-Dsession-managers="[]"

		-Dpam-defaults-install=true

		$(meson_native_use_feature X x11)
		$(meson_native_use_feature X x11-xfixes)
		$(meson_native_use_feature X libcanberra)

		$(meson_native_use_feature pulseaudio libpulse)

		-Dsnap=disabled
		-Donnxruntime=disabled
		-Dbluez5-plc-spandsp=disabled
		-Dbluez5-codec-ldac-dec=disabled
	)

	if use !sound-server; then
		emesonargs+=( '-Dgsettings-pulse-schema=disabled' )
	else
		emesonargs+=(
			$(meson_native_use_feature gsettings gsettings-pulse-schema)
		)
	fi

	meson_src_configure
}

multilib_src_test() {
	meson_src_test --timeout-multiplier 10
}

multilib_src_install() {
	DOCS= meson_src_install
}

multilib_src_install_all() {
	einstalldocs

	if ! use man && [[ ${PIPEWIRE_DOCS_PREBUILT} == 1 ]] ; then
		doman "${WORKDIR}"/${PN}-${PIPEWIRE_DOCS_VERSION}-docs/man/*/*.[0-8]
	fi

	if use pipewire-alsa; then
		dodir /etc/alsa/conf.d

		insinto /usr/share/alsa/alsa.conf.d
		doins "${FILESDIR}"/99-pipewire-default-hook.conf
		eprefixify "${ED}"/usr/share/alsa/alsa.conf.d/99-pipewire-default-hook.conf

		dosym ../../../usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/50-pipewire.conf
		dosym ../../../usr/share/alsa/alsa.conf.d/99-pipewire-default-hook.conf /etc/alsa/conf.d/99-pipewire-default-hook.conf
	fi

	# User-session OpenRC service (login session, uses XDG_RUNTIME_DIR from elogind/PAM)
	exeinto /etc/user/init.d
	newexe "${FILESDIR}"/pipewire.initd pipewire
	if use sound-server; then
		newexe "${FILESDIR}"/pipewire-pulse.initd pipewire-pulse

		insinto /etc/wireplumber/wireplumber.conf.d
		doins "${FILESDIR}"/gentoo-sound-server-enable-audio-bluetooth.conf
	fi

	if use system-service; then
		if use systemd; then
			newtmpfiles - pipewire.conf <<-EOF || die
				d /run/pipewire 0755 pipewire pipewire - -
			EOF
		else
			# bassdr: OpenRC system service — runs as acct-user/pipewire,
			# creates /run/pipewire in start_pre via checkpath.
			exeinto /etc/init.d
			newexe "${FILESDIR}"/pipewire-system.initd pipewire-system
		fi
	fi

	if ! use systemd; then
		if use system-service; then
			# bassdr: system-service mode — the autostart desktop file and
			# gentoo-pipewire-launcher are intentionally NOT installed.
			# Installing them would spawn a competing per-user pipewire/wireplumber
			# on login, conflicting with the system instance (see bug #964059).
			# Instead, point all clients at the system socket via profile.d.
			insinto /etc/profile.d
			newins "${FILESDIR}"/pipewire-system-env.sh pipewire-system.sh
		else
			insinto /etc/xdg/autostart
			newins "${FILESDIR}"/pipewire.desktop-r2 pipewire.desktop

			exeinto /usr/bin
			newexe "${FILESDIR}"/gentoo-pipewire-launcher.in-r4 gentoo-pipewire-launcher

			doman "${FILESDIR}"/gentoo-pipewire-launcher.1

			if ! use sound-server ; then
				sed -i -s '/pipewire -c pipewire-pulse.conf/s/^/#/' "${ED}"/usr/bin/gentoo-pipewire-launcher || die
			fi

			eprefixify "${ED}"/usr/bin/gentoo-pipewire-launcher
		fi
	fi
}

pkg_postrm() {
	udev_reload
}

pkg_preinst() {
	HAD_SOUND_SERVER=0
	HAD_SYSTEM_SERVICE=0

	if has_version "media-video/pipewire[sound-server(-)]" ; then
		HAD_SOUND_SERVER=1
	fi

	if has_version "media-video/pipewire[system-service(-)]" ; then
		HAD_SYSTEM_SERVICE=1
	fi
}

pkg_postinst() {
	udev_reload

	use system-service && use systemd && tmpfiles_process pipewire.conf

	local ver
	for ver in ${REPLACING_VERSIONS} ; do
		if has_version kde-plasma/kwin[screencast] || has_version x11-wm/mutter[screencast] ; then
			ewarn "Please restart KWin/Mutter after upgrading PipeWire."
			ewarn "Screencasting may not work until you do."
		fi

		if ver_test ${ver} -le 0.3.66-r1 ; then
			elog ">=pipewire-0.3.66 uses the 'pipewire' group to manage permissions"
			elog "and limits needed to function smoothly:"
			elog
			elog "1. Please make sure your user is in the 'pipewire' group:"
			elog " usermod -aG pipewire <youruser>"
			elog

			if ! use jack-sdk ; then
				elog
				elog "JACK emulation is incomplete. Use pw-jack <application> for JACK apps."
				elog
			fi

			if use systemd ; then
				ewarn
				ewarn "PipeWire daemon startup has been moved to a launcher script!"
				ewarn "Make sure that ${EROOT}/etc/pipewire/pipewire.conf no longer"
				ewarn "starts a session manager or PulseAudio compatibility daemon."
				ewarn
			fi

			if use sound-server && ( has_version 'media-sound/pulseaudio[daemon]' || has_version 'media-sound/pulseaudio-daemon' ) ; then
				elog
				elog "This ebuild auto-enables PulseAudio replacement. Disable PulseAudio"
				elog "autospawn in /etc/pulse/client.conf: autospawn = no"
				elog
			fi

			if has_version 'net-misc/ofono' ; then
				ewarn "Native backend has become default. Please disable oFono:"
				ewarn "rc-update delete ofono"
			fi
		fi
	done

	if [[ ${HAD_SOUND_SERVER} -eq 0 || -z ${REPLACING_VERSIONS} ]] ; then
		if use sound-server && use systemd ; then
			elog
			elog "To use PipeWire, enable the user units for each desktop user:"
			elog "  systemctl --user enable pipewire.socket pipewire-pulse.socket"
			elog "  systemctl --user --force enable wireplumber.service"
			elog
		fi

		if ! use sound-server ; then
			ewarn
			ewarn "USE=sound-server is disabled! See https://wiki.gentoo.org/wiki/PipeWire"
			ewarn
		fi
	fi

	if use system-service && [[ ${HAD_SYSTEM_SERVICE} -eq 0 || -z ${REPLACING_VERSIONS} ]] ; then
		if use systemd; then
			ewarn
			ewarn "system-service with systemd: this installs system-wide systemd units."
			ewarn "This is likely NOT what you want. Use systemd user units instead."
			ewarn
		else
			elog
			elog "system-service (OpenRC): installed /etc/init.d/pipewire-system"
			elog "This runs PipeWire as the 'pipewire' user at boot, before any login."
			elog
			elog "Enable with:"
			elog "  rc-update add pipewire-system default"
			elog "  rc-update add wireplumber-system default  (from media-video/wireplumber)"
			elog
			elog "gentoo-pipewire-launcher and pipewire.desktop autostart are NOT installed"
			elog "(see bug #964059). /etc/profile.d/pipewire-system.sh sets"
			elog "PIPEWIRE_RUNTIME_DIR=/run/pipewire so user sessions connect to the"
			elog "system socket instead of spawning their own instance."
			elog
			elog "Users connecting to the system instance should be in the 'pipewire' group:"
			elog "  usermod -aG pipewire <youruser>"
			elog
		fi
	fi

	elog "For documentation, see https://wiki.gentoo.org/wiki/PipeWire"
	elog

	optfeature_header "Optional runtime features:"
	optfeature "restricted realtime capabilities via D-Bus" sys-auth/rtkit

	if use sound-server && ! use pipewire-alsa; then
		optfeature "ALSA plugin for PulseAudio output" "media-plugins/alsa-plugins[pulseaudio]"
	fi
}
