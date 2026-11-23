# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MULTILIB_ABIS="amd64 x86" # allow usage on /no-multilib/
MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit flag-o-matic meson-multilib

DESCRIPTION="Alternative NVAPI implementation on top of DXVK"
HOMEPAGE="https://github.com/jp7677/dxvk-nvapi/"

# git submodules (headers only) at the commits pinned by ${PV}; vkroots is
# only used by the Vulkan Reflex layer, which is not built
DIRECTX_HEADERS_COMMIT=ea2799ce66647c69710a81338e828b19973e0370
NVAPI_COMMIT=87dca625e83fd89a983e19b904e5f3a580da90d2
VULKAN_HEADERS_COMMIT=e3b1eec08173d6b825cd3ac88c885a63b621504a
SRC_URI="
	https://github.com/jp7677/dxvk-nvapi/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/microsoft/DirectX-Headers/archive/${DIRECTX_HEADERS_COMMIT}.tar.gz
		-> DirectX-Headers-${DIRECTX_HEADERS_COMMIT}.tar.gz
	https://github.com/NVIDIA/nvapi/archive/${NVAPI_COMMIT}.tar.gz
		-> nvapi-${NVAPI_COMMIT}.tar.gz
	https://github.com/KhronosGroup/Vulkan-Headers/archive/${VULKAN_HEADERS_COMMIT}.tar.gz
		-> Vulkan-Headers-${VULKAN_HEADERS_COMMIT}.tar.gz
"

LICENSE="MIT Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+abi_x86_32 crossdev-mingw +strip"

RDEPEND="app-emulation/dxvk[dxgi]"
BDEPEND="!crossdev-mingw? ( dev-util/mingw64-toolchain[${MULTILIB_USEDEP}] )"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if use crossdev-mingw && [[ ! -v MINGW_BYPASS ]]; then
		local tool=-w64-mingw32-g++
		for tool in $(usev abi_x86_64 x86_64${tool}) \
			$(usev abi_x86_32 i686${tool}); do
			if ! type -P ${tool} >/dev/null; then
				eerror "With USE=crossdev-mingw, the mingw toolchain must be"
				eerror "set up: https://wiki.gentoo.org/wiki/Mingw"
				use abi_x86_32 && use abi_x86_64 &&
					eerror "USE=abi_x86_32 needs i686 and x86_64 toolchains."
				die "USE=crossdev-mingw is set but ${tool} was not found"
			elif [[ ! $(LC_ALL=C ${tool} -v 2>&1) =~ "Thread model: posix" ]]
			then
				eerror "${PN} requires GCC built with --enable-threads=posix:"
				eerror "https://wiki.gentoo.org/wiki/Mingw#POSIX_threads_for_Windows"
				die "${tool} does not use POSIX threads"
			fi
		done
	fi
}

src_prepare() {
	local sub
	for sub in DirectX-Headers nvapi Vulkan-Headers; do
		rm -rf external/${sub} || die
	done
	mv ../DirectX-Headers-${DIRECTX_HEADERS_COMMIT} \
		external/DirectX-Headers || die
	mv ../nvapi-${NVAPI_COMMIT} external/nvapi || die
	mv ../Vulkan-Headers-${VULKAN_HEADERS_COMMIT} external/Vulkan-Headers || die

	default
}

src_configure() {
	use crossdev-mingw || PATH=${BROOT}/usr/lib/mingw64-toolchain/bin:${PATH}

	filter-lto

	# -mavx and mingw-gcc do not mix safely (same as app-emulation/dxvk)
	# https://github.com/doitsujin/dxvk/issues/4746#issuecomment-2708869202
	append-flags -mno-avx

	if [[ ${CHOST} != *-mingw* ]]; then
		if [[ ! -v MINGW_BYPASS ]]; then
			unset AR CC CXX RC STRIP
			filter-flags '-fuse-ld=*'
			filter-flags '-mfunction-return=thunk*'
			filter-flags '-Wl,-z,*'
		fi

		CHOST_amd64=x86_64-w64-mingw32
		CHOST_x86=i686-w64-mingw32
		CHOST=$(usex x86 ${CHOST_x86} ${CHOST_amd64})

		strip-unsupported-flags
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	# multilib's ${CHOST_amd64}-gcc -m32 is unusable with crossdev,
	# unset again so meson eclass will set ${CHOST}-gcc + others
	use crossdev-mingw && [[ ! -v MINGW_BYPASS ]] && unset AR CC CXX RC STRIP

	local emesonargs=(
		--prefix="${EPREFIX}"/usr/lib/${PN}
		--{bin,lib}dir=x${MULTILIB_ABI_FLAG: -2}
		-Denable_tests=false # catch2 tests are Windows executables
		$(usev strip --strip) # portage won't strip .dll, so allow it here
	)

	meson_src_configure
}

multilib_src_install_all() {
	dobin "${FILESDIR}"/setup_dxvk_nvapi.sh
	dodoc README.md

	find "${ED}" -type f -name '*.a' -delete || die
}

pkg_postinst() {
	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog "To enable ${PN} on a wine prefix that already uses dxvk, run:"
		elog
		elog "	WINEPREFIX=/path/to/prefix setup_dxvk_nvapi.sh install"
		elog
		elog "then start games with the same environment Proton uses:"
		elog
		elog "	DXVK_ENABLE_NVAPI=1"
		elog "	NVIDIA_WINE_DLL_DIR=${EPREFIX}/usr/lib64/nvidia/wine  (DLSS)"
		elog "	WINEDLLOVERRIDES=nvcuda=b  (wine-proton disables its nvcuda)"
		elog
		elog "setup_dxvk_nvapi.sh is provided by this overlay, not upstream."
	fi
}
