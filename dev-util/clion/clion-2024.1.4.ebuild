# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop wrapper

DESCRIPTION="A complete toolset for C and C++ development"
HOMEPAGE="https://www.jetbrains.com/clion/"

SRC_URI="amd64? ( https://download.jetbrains.com/cpp/CLion-${PV}.tar.gz )
         arm64? ( https://download.jetbrains.com/cpp/CLion-${PV}-aarch64.tar.gz )"

LICENSE="|| ( IDEA IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL-1.1 CPL-0.5 CPL-1.0
	EPL-1.0 EPL-2.0 GPL-2 GPL-2-with-classpath-exception GPL-3 ISC JDOM
	LGPL-2.1+ LGPL-3 MIT MPL-1.0 MPL-1.1 OFL public-domain PSF-2 UoI-NCSA ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror splitdebug"

BDEPEND="dev-util/patchelf"

RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0:2
	dev-debug/gdb
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-libs/wayland
	dev-build/cmake
	app-alternatives/ninja
	media-libs/alsa-lib
	media-libs/freetype:2
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-libs/zlib
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libXxf86vm
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango"

QA_PREBUILT="opt/${PN}/*"

src_prepare() {
	default

	local remove_me=(
		Install-Linux-tar.txt
		help/ReferenceCardForMac.pdf
		bin/cmake
		bin/gdb/linux
		bin/lldb/linux
		bin/ninja
	)

	case ${ARCH} in
		amd64)	remove_me+=(lib/async-profiler/aarch64/libasyncProfiler.so);;
		arm64)	remove_me+=(lib/async-profiler/amd64/libasyncProfiler.so);;
	esac

	rm -rv "${remove_me[@]}" || die

	for file in "jbr/lib/{libjcef.so,jcef_helper}"
	do
		if [[ -f "${file}" ]]; then
			patchelf --set-rpath '$ORIGIN' "${file}" || die
		fi
	done
}

src_install() {
	local dir=/opt/${PN}

	insinto ${dir}
	doins -r *
	fperms 755 ${dir}/bin/{clion.sh,format.sh,fsnotifier,inspect.sh,jetbrains_client.sh,ltedit.sh,remote-dev-server.sh,repair,restarter}

	case ${ARCH} in
		amd64)	fperms 755 ${dir}/bin/clang/linux/x64/{clangd,clang-tidy,clazy-standalone,llvm-symbolizer};;
		arm64)
			fperms 755 ${dir}/bin/clang/linux/aarch64/{clangd,clang-tidy,clazy-standalone,llvm-symbolizer}
			fperms 755 ${dir}/plugins/clion-radler/DotFiles/linux-arm64/Rider.Backend
		;;
	esac

	if [[ -d jbr ]]; then
		fperms 755 "${dir}"/jbr/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
		# Fix #763582
		fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}
	fi

	case ${ARCH} in
		amd64)	dosym -r "${EPREFIX}/usr/bin/ninja" "${dir}"/bin/ninja/linux/x64/ninja;;
		arm64)	dosym -r "${EPREFIX}/usr/bin/ninja" "${dir}"/bin/ninja/linux/aarch64/ninja;;
	esac

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "CLion" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	insinto /usr/lib/sysctl.d
	newins - 30-"${PN}"-inotify-watches.conf <<<"fs.inotify.max_user_watches = 524288"
}
