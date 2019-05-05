# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="libretro is a simple backend API for emulators, game engines, and media players to be run through a unified GUI."
HOMEPAGE="https://www.libretro.com/"
EGIT_REPO_URI="https://github.com/libretro/libretro-super.git"

inherit git-r3 toolchain-funcs multilib-minimal

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl vulkan"

DEPEND=">=net-libs/libpcap-1.8.1-r2"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=(
  "${FILESDIR}/rules.d-mednafen_psx_hw-mame2016.patch"
  "${FILESDIR}/rules.d-emux.patch"
)

src_unpack() {
  git-r3_src_unpack
  "${S}/libretro-fetch.sh" --shallow --cores || die
}

src_prepare() {
  default

  # Replace the custom make -j$JOBS by ebuild's ${MAKEOPTS}
  sed -i 's/\\\"-j$JOBS\\\"/${MAKEOPTS}/g' "${S}/libretro-build-common.sh"
  sed -i 's/-j$JOBS/${MAKEOPTS}/g' "${S}/libretro-build-common.sh"

  # Add a generic Makefile in emux
  pushd "${WORKDIR}/libretro-emux"
    eapply "${FILESDIR}/libretro-emux-add-makefile.patch"
  popd

  # Fix stonesoup compile errors
  pushd "${WORKDIR}/libretro-stonesoup"
    eapply "${FILESDIR}/libretro-stonesoup-compile-fix.patch"
  popd
}

src_configure() {
  multilib-minimal_src_configure

  # Rewrite the whole config, it's too messy to be modified or appended to
  #TODO: support more architecture
  cat << "  EOF" > "${S}/libretro-config.sh"
    LIBRETRO_DEVELOPER=1

    # Architecture Assignment
    config_cpu() {
      case "${MULTILIB_ABI_FLAG}" in
      abi_x86_64)
        ARCH=x86_64
        X86=true
        X86_64=true
        export PTR64=1
        ;;
      abi_x86_32)
        ARCH=i686
        X86=true
        export PTR64=0
        ;;
      abi_x86_x32)
        ARCH=x86_64
        X86=true
        export PTR64=0
        ;;
      *)
        echo "FATAL ERROR, unknown MULTILIB_ABI_FLAG='${MULTILIB_ABI_FLAG}'" 2>&1
        exit 1
        ;;
      esac
    }

    # Platform Assignment
    config_platform() {
      platform="Linux"
      BINARY_EXT=""
      FORMAT_COMPILER_TARGET="unix"
      FORMAT_EXT="so"
      DIST_DIR="unix"
      export CXX11="${CXX}"
      export FORMAT_COMPILER_TARGET_ALT="$FORMAT_COMPILER_TARGET"
    }

    config_log_build_host() {
      echo "PLATFORM: $platform"
      echo "ARCHITECTURE: $ARCH"
      echo "TARGET: $FORMAT_COMPILER_TARGET"
    }

    config_cpu
    config_platform
    config_log_build_host
  EOF

  if use opengl ; then
    echo 'export BUILD_LIBRETRO_GL=1' >> "${S}/libretro-config.sh"
  fi
}

multilib_src_compile() {
  cd "${WORKDIR}"

  # set output directory for this ABI
  export RARCH_DIST_DIR="${BUILD_DIR}"

  # libretro-config.sh written above needs this
  export MULTILIB_ABI_FLAG

  # build all cores considered stable upstream for this ABI
  "${S}/libretro-build.sh" || die "some core(s) did not compile"

  # build parallel_n64 only if vulkan is set, as this one is optimized for vulkan
  if use vulkan ; then
    "${S}/libretro-build.sh" parallel_n64 || die "parallel_n64 did not compile"
  fi

  # build mednafen_psx_hw only of opengl or vulkan hw-acceleration is enabled
  if use opengl || use vulkan ; then
    "${S}/libretro-build.sh" mednafen_psx_hw || die "mednafen_psx_hw did not compile"
  fi
}

multilib_src_install() {
  exeinto "/usr/$(get_libdir)/libretro"
  doexe *.so
}

multilib_src_install_all() {
  einstalldocs

  insinto "/usr/share/libretro/info"
  doins dist/info/*
}
