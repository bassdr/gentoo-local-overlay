# Copyright 2011-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FreeRDP/FreeRDP.git"
	case ${PV} in
		2.*) EGIT_BRANCH="stable-2.0";;
	esac
else
	inherit verify-sig
	MY_P=${P/_/-}
	S="${WORKDIR}/${MY_P}"
	SRC_URI="https://pub.freerdp.com/releases/${MY_P}.tar.gz
		verify-sig? ( https://pub.freerdp.com/releases/${MY_P}.tar.gz.asc )"
	KEYWORDS="~alpha amd64 ~arm arm64 ~loong ppc ppc64 ~riscv x86"
	BDEPEND="verify-sig? ( sec-keys/openpgp-keys-akallabeth )"
	VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/akallabeth.asc"
fi

DESCRIPTION="Free implementation of the Remote Desktop Protocol"
HOMEPAGE="https://www.freerdp.com/"

LICENSE="Apache-2.0"
SLOT="3"
IUSE="aad alsa cpu_flags_arm_neon cpu_flags_x86_sse2 +client cups debug deprecated-api deprecated-commandline dsp-experimental faac faad +fdk-aac +ffmpeg +fuse gsm gstreamer +icu jpeg kerberos lame openh264 pulseaudio qt6 sdl server smartcard soxr systemd test usb vaapi valgrind wayland webview webengine X xinerama xv"
RESTRICT="!test? ( test )"

BDEPEND+="
	virtual/pkgconfig
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
"
COMMON_DEPEND="
	dev-libs/openssl:0=
	sys-libs/zlib:0
	aad? (
		dev-libs/cJSON
		webview? ( net-libs/webkit-gtk:4 )
		webengine? (
			!qt6? ( dev-qt/qtwebengine:5[widgets] )
			qt6? ( dev-qt/qtwebengine:6[widgets] )
		)
	)
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	usb? (
		virtual/libudev:0=
		sys-apps/util-linux:0=
		dev-libs/dbus-glib:0=
		virtual/libusb:1=
	)
	X? (
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXrender
		xinerama? ( x11-libs/libXinerama )
		xv? ( x11-libs/libXv )
	)
	faac? ( media-libs/faac )
	faad? ( media-libs/faad2 )
	fdk-aac? ( media-libs/fdk-aac )
	ffmpeg? ( media-video/ffmpeg:0= )
	!ffmpeg? (
		x11-libs/cairo:0=
	)
	fuse? ( sys-fs/fuse:3 )
	gsm? ( media-sound/gsm )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
		X? ( x11-libs/libXrandr )
	)
	icu? ( dev-libs/icu:0= )
	jpeg? ( media-libs/libjpeg-turbo:0= )
	kerberos? ( virtual/krb5 )
	openh264? ( media-libs/openh264:0= )
	pulseaudio? ( media-libs/libpulse )
	sdl? (
		media-libs/libsdl2[haptic(+),joystick(+),sound(+),video(+)]
		media-libs/sdl2-ttf
	)
	server? (
		X? (
			x11-libs/libXcursor
			x11-libs/libXdamage
			x11-libs/libXext
			x11-libs/libXfixes
			x11-libs/libXrandr
			x11-libs/libXtst
			xinerama? ( x11-libs/libXinerama )
		)
	)
	smartcard? ( sys-apps/pcsc-lite )
	soxr? ( media-libs/soxr )
	systemd? ( sys-apps/systemd:0= )
	client? (
		wayland? (
			dev-libs/wayland
			x11-libs/libxkbcommon
		)
	)
	X? (
		x11-libs/libX11
		x11-libs/libxkbfile
	)
"
DEPEND="${COMMON_DEPEND}
	valgrind? ( dev-debug/valgrind )
"
RDEPEND="${COMMON_DEPEND}
	!net-misc/freerdp:0
	client? ( !net-misc/freerdp:2[client] )
	server? ( !net-misc/freerdp:2[server] )
	smartcard? ( app-crypt/p11-kit )
"

PATCHES=(
	"${FILESDIR}/freerdp-3.6.3-webview-qt6.patch"
	"${FILESDIR}/freerdp-3.7.0-dsp-noffmpeg-fix.patch"
)

option() {
	usex "$1" ON OFF
}

src_configure() {
	# bug #881695
	filter-lto

	local mycmakeargs=(
		-Wno-dev

		# https://bugs.gentoo.org/927037
		-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF

		-DBUILD_TESTING=$(option test)
		-DCHANNEL_URBDRC=$(option usb)
		-DWITH_AAD=$(option aad)
		-DWITH_ALSA=$(option alsa)
		-DWITH_CCACHE=OFF
		-DWITH_CLIENT=$(option client)
		-DWITH_CLIENT_SDL=$(option sdl)
		-DWITH_CLIENT_SDL2=$(option sdl)
		-DWITH_CLIENT_SDL3=OFF
		-DWITH_SAMPLE=OFF
		-DWITH_CUPS=$(option cups)
		-DWITH_DEBUG_ALL=$(option debug)
		-DWITH_MANPAGES=ON
		-DWITH_FAAC=$(option faac)
		-DWITH_FAAD2=$(option faad)
		-DWITH_FDK_AAC=$(option fdk-aac)
		-DWITH_FFMPEG=$(option ffmpeg)
		-DWITH_FREERDP_DEPRECATED=$(option deprecated-api)
		-DWITH_FREERDP_DEPRECATED_COMMANDLINE=$(option deprecated-commandline)
		-DWITH_SWSCALE=$(option ffmpeg)
		-DWITH_CAIRO=$(option !ffmpeg)
		-DWITH_DSP_FFMPEG=$(option !dsp-experimental)
		-DWITH_DSP_EXPERIMENTAL=$(option dsp-experimental)
		-DWITH_FUSE=$(option fuse)
		-DWITH_GSM=$(option gsm)
		-DWITH_GSTREAMER_1_0=$(option gstreamer)
		-DWITH_JPEG=$(option jpeg)
		-DWITH_KRB5=$(option kerberos)
		-DWITH_LAME=$(option lame)
		-DWITH_NEON=$(option cpu_flags_arm_neon)
		-DWITH_OPENH264=$(option openh264)
		-DWITH_OSS=OFF
		-DWITH_OPUS=OFF
		-DWITH_PCSC=$(option smartcard)
		-DWITH_PKCS11=$(option smartcard)
		-DWITH_PULSE=$(option pulseaudio)
		-DWITH_SERVER=$(option server)
		-DWITH_SOXR=$(option soxr)
		-DWITH_SSE2=$(option cpu_flags_x86_sse2)
		-DWITH_LIBSYSTEMD=$(option systemd)
		-DWITH_UNICODE_BUILTIN=$(option !icu)
		-DWITH_VAAPI=$(option vaapi)
		-DWITH_VALGRIND_MEMCHECK=$(option valgrind)
		-DWITH_X11=$(option X)
		-DWITH_XINERAMA=$(option xinerama)
		-DWITH_XV=$(option xv)
		-DWITH_WAYLAND=$(option wayland)
		-DWITH_WEBVIEW=$(if use webview || use webengine ; then echo ON ; else echo OFF ; fi)
		-DWITH_WEBVIEW_QT=$(option !qt6)
		-DWITH_WEBVIEW_QT6=$(option qt6)
		-DWITH_WINPR_TOOLS=$(option server)
	)
	cmake_src_configure
}

src_test() {
	local myctestargs=( -E TestBacktrace )
	has network-sandbox ${FEATURES} && myctestargs+=( -E TestConnect )
	cmake_src_test
}

src_install() {
	cmake_src_install
	mv "${ED}"/usr/share/man/man7/wlog{,3}.7 || die
}
