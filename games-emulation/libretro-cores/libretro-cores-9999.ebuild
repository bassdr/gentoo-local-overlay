# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="libretro is a simple backend API for emulators, game engines, and media players to be run through a unified GUI."
HOMEPAGE="https://www.libretro.com/"
EGIT_REPO_URI="https://github.com/libretro/libretro-super.git"

inherit git-r3 toolchain-funcs multilib-minimal

#SRC_URI="https://github.com/libretro/${PN}/archive/master.tar.gz                      -> ${P}.tar.gz"
#  https://github.com/libretro/bsnes-libretro/archive/master.tar.gz             -> bsnes-libretro.tar.gz
#  https://github.com/libretro/bsnes-libretro/archive/master.tar.gz             -> bsnes-libretro.tar.gz
#  https://github.com/libretro/bsnes-libretro/archive/master.tar.gz             -> bsnes-libretro.tar.gz
#  https://github.com/libretro/libretro-crocods/archive/master.tar.gz           -> libretro-crocods.tar.gz
#  https://github.com/libretro/dolphin/archive/master.tar.gz                    -> dolphin.tar.gz
#  https://github.com/libretro/Ishiiruka/archive/master.tar.gz                  -> Ishiiruka.tar.gz
#  https://github.com/libretro/daphne/archive/master.tar.gz                     -> daphne.tar.gz
#  https://github.com/libretro/mrboom-libretro/archive/master.tar.gz            -> mrboom-libretro.tar.gz
#  https://github.com/libretro/frodo-libretro/archive/master.tar.gz             -> frodo-libretro.tar.gz
#  https://github.com/libretro/vice-libretro/archive/master.tar.gz              -> vice-libretro.tar.gz
#  https://github.com/libretro/vice-libretro/archive/master.tar.gz              -> vice-libretro.tar.gz
#  https://github.com/libretro/vice-libretro/archive/master.tar.gz              -> vice-libretro.tar.gz
#  https://github.com/libretro/vice-libretro/archive/master.tar.gz              -> vice-libretro.tar.gz
#  https://github.com/libretro/xrick-libretro/archive/master.tar.gz             -> xrick-libretro.tar.gz
#  https://github.com/libretro/FreeIntv/archive/master.tar.gz                   -> FreeIntv.tar.gz
#  https://github.com/libretro/libretro-pocketcdg/archive/master.tar.gz         -> libretro-pocketcdg.tar.gz
#  https://github.com/libretro/easyrpg-libretro/archive/master.tar.gz           -> easyrpg-libretro.tar.gz
#  https://github.com/libretro/libretro-gme/archive/master.tar.gz               -> libretro-gme.tar.gz
#  https://github.com/libretro/snes9x2002/archive/master.tar.gz                 -> snes9x2002.tar.gz
#  https://github.com/libretro/snes9x2005/archive/master.tar.gz                 -> snes9x2005.tar.gz
#  https://github.com/libretro/snes9x2010/archive/master.tar.gz                 -> snes9x2010.tar.gz
#  https://github.com/libretro/snes9x/archive/master.tar.gz                     -> snes9x.tar.gz
#  https://github.com/libretro/reicast-emulator/archive/master.tar.gz           -> reicast-emulator.tar.gz
#  https://github.com/libretro/redream/archive/master.tar.gz                    -> redream.tar.gz
#  https://github.com/libretro/libretro-minivmac/archive/master.tar.gz          -> libretro-minivmac.tar.gz
#  https://github.com/libretro/REminiscence/archive/master.tar.gz               -> REminiscence.tar.gz
#  https://github.com/libretro/Genesis-Plus-GX/archive/master.tar.gz            -> Genesis-Plus-GX.tar.gz
#  https://github.com/libretro/mgba/archive/master.tar.gz                       -> mgba.tar.gz
#  https://github.com/libretro/libretro-video-processor/archive/master.tar.gz   -> libretro-video-processor.tar.gz
#  https://github.com/libretro/fbalpha/archive/master.tar.gz                    -> fbalpha.tar.gz
#  https://github.com/libretro/fbalpha2012/archive/master.tar.gz                -> fbalpha2012.tar.gz
#  https://github.com/libretro/fbalpha2012_cps1/archive/master.tar.gz           -> fbalpha2012_cps1.tar.gz
#  https://github.com/libretro/fbalpha2012_cps2/archive/master.tar.gz           -> fbalpha2012_cps2.tar.gz
#  https://github.com/libretro/fbalpha2012_cps3/archive/master.tar.gz           -> fbalpha2012_cps3.tar.gz
#  https://github.com/libretro/fbalpha2012_neogeo/archive/master.tar.gz         -> fbalpha2012_neogeo.tar.gz
#  https://github.com/libretro/blastem/archive/master.tar.gz                    -> blastem.tar.gz
#  https://github.com/libretro/vba-next/archive/master.tar.gz                   -> vba-next.tar.gz
#  https://github.com/libretro/vbam-libretro/archive/master.tar.gz              -> vbam-libretro.tar.gz
#  https://github.com/libretro/libretro-handy/archive/master.tar.gz             -> libretro-handy.tar.gz
#  https://github.com/libretro/libretro-cap32/archive/master.tar.gz             -> libretro-cap32.tar.gz
#  https://github.com/libretro/libretro-fsuae/archive/master.tar.gz             -> libretro-fsuae.tar.gz
#  https://github.com/libretro/libretro-uae/archive/master.tar.gz               -> libretro-uae.tar.gz
#  https://github.com/libretro/bnes-libretro/archive/master.tar.gz              -> bnes-libretro.tar.gz
#  https://github.com/libretro/libretro-fceumm/archive/master.tar.gz            -> libretro-fceumm.tar.gz
#  https://github.com/libretro/gambatte-libretro/archive/master.tar.gz          -> gambatte-libretro.tar.gz
#  https://github.com/drhelius/Gearboy/archive/master.tar.gz                    -> Gearboy.tar.gz
#  https://github.com/drhelius/Gearsystem/archive/master.tar.gz                 -> Gearsystem.tar.gz
#  https://github.com/libretro/SameBoy/archive/master.tar.gz                    -> SameBoy.tar.gz
#  https://github.com/libretro/meteor-libretro/archive/master.tar.gz            -> meteor-libretro.tar.gz
#  https://github.com/libretro/nxengine-libretro/archive/master.tar.gz          -> nxengine-libretro.tar.gz
#  https://github.com/libretro/libretro-prboom/archive/master.tar.gz            -> libretro-prboom.tar.gz
#  https://github.com/libretro/stella-libretro/archive/master.tar.gz            -> stella-libretro.tar.gz
#  https://github.com/libretro/melonDS/archive/master.tar.gz                    -> melonDS.tar.gz
#  https://github.com/libretro/OpenLara/archive/master.tar.gz                   -> OpenLara.tar.gz
#  https://github.com/libretro/cannonball/archive/master.tar.gz                 -> cannonball.tar.gz
#  https://github.com/libretro/desmume/archive/master.tar.gz                    -> desmume.tar.gz
#  https://github.com/libretro/desmume2015/archive/master.tar.gz                -> desmume2015.tar.gz
#  https://github.com/libretro/QuickNES_Core/archive/master.tar.gz              -> QuickNES_Core.tar.gz
#  https://github.com/libretro/nestopia/archive/master.tar.gz                   -> nestopia.tar.gz
#  https://github.com/libretro/Craft/archive/master.tar.gz                      -> Craft.tar.gz
#  https://github.com/libretro/libretro-pcem/archive/master.tar.gz              -> libretro-pcem.tar.gz
#  https://github.com/libretro/tyrquake/archive/master.tar.gz                   -> tyrquake.tar.gz
#  https://github.com/libretro/pcsx_rearmed/archive/master.tar.gz               -> pcsx_rearmed.tar.gz
#  https://github.com/libretro/pcsx1-libretro/archive/master.tar.gz             -> pcsx1-libretro.tar.gz
#  https://github.com/libretro/beetle-gba-libretro/archive/master.tar.gz        -> beetle-gba-libretro.tar.gz
#  https://github.com/libretro/beetle-lynx-libretro/archive/master.tar.gz       -> beetle-lynx-libretro.tar.gz
#  https://github.com/libretro/beetle-ngp-libretro/archive/master.tar.gz        -> beetle-ngp-libretro.tar.gz
#  https://github.com/libretro/beetle-pce-fast-libretro/archive/master.tar.gz   -> beetle-pce-fast-libretro.tar.gz
#  https://github.com/libretro/beetle-supergrafx-libretro/archive/master.tar.gz -> beetle-supergrafx-libretro.tar.gz
#  https://github.com/libretro/beetle-psx-libretro/archive/master.tar.gz        -> beetle-psx-libretro.tar.gz
#  https://github.com/libretro/beetle-saturn-libretro/archive/master.tar.gz     -> beetle-saturn-libretro.tar.gz
#  https://github.com/libretro/beetle-pcfx-libretro/archive/master.tar.gz       -> beetle-pcfx-libretro.tar.gz
#  https://github.com/libretro/beetle-bsnes-libretro/archive/master.tar.gz      -> beetle-bsnes-libretro.tar.gz
#  https://github.com/libretro/beetle-vb-libretro/archive/master.tar.gz         -> beetle-vb-libretro.tar.gz
#  https://github.com/libretro/beetle-wswan-libretro/archive/master.tar.gz      -> beetle-wswan-libretro.tar.gz
#  https://github.com/libretro/rustation-libretro/archive/master.tar.gz         -> rustation-libretro.tar.gz
#  https://github.com/libretro/scummvm/archive/master.tar.gz                    -> scummvm.tar.gz
#  https://github.com/libretro/yabause/archive/master.tar.gz                    -> yabause.tar.gz
#  https://github.com/libretro/yabause/archive/master.tar.gz                    -> yabause.tar.gz
#  https://github.com/libretro/yabause/archive/master.tar.gz                    -> yabause.tar.gz
#  https://github.com/libretro/dosbox-libretro/archive/master.tar.gz            -> dosbox-libretro.tar.gz
#  https://github.com/libretro/Basilisk2/archive/master.tar.gz                  -> Basilisk2.tar.gz
#  https://github.com/libretro/virtualjaguar-libretro/archive/master.tar.gz     -> virtualjaguar-libretro.tar.gz
#  https://github.com/libretro/mame2000-libretro/archive/master.tar.gz          -> mame2000-libretro.tar.gz
#  https://github.com/libretro/mame2003-libretro/archive/master.tar.gz          -> mame2003-libretro.tar.gz
#  https://github.com/libretro/mame2003-plus-libretro/archive/master.tar.gz     -> mame2003-plus-libretro.tar.gz
#  https://github.com/libretro/mame2003_midway/archive/master.tar.gz            -> mame2003_midway.tar.gz
#  https://github.com/libretro/mame2010-libretro/archive/master.tar.gz          -> mame2010-libretro.tar.gz
#  https://github.com/libretro/mame2015-libretro/archive/master.tar.gz          -> mame2015-libretro.tar.gz
#  https://github.com/libretro/mame2016-libretro/archive/master.tar.gz          -> mame2016-libretro.tar.gz
#  https://github.com/libretro/mame/archive/master.tar.gz                       -> mame.tar.gz
#  https://github.com/libretro/FFmpeg/archive/master.tar.gz                     -> FFmpeg.tar.gz
#  https://github.com/libretro/bsnes-libretro-cplusplus98/archive/master.tar.gz -> bsnes-libretro-cplusplus98.tar.gz
#  https://github.com/libretro/bsnes-mercury/archive/master.tar.gz              -> bsnes-mercury.tar.gz
#  https://github.com/libretro/bsnes-mercury/archive/master.tar.gz              -> bsnes-mercury.tar.gz
#  https://github.com/libretro/bsnes-mercury/archive/master.tar.gz              -> bsnes-mercury.tar.gz
#  https://github.com/libretro/picodrive/archive/master.tar.gz                  -> picodrive.tar.gz
#  https://github.com/libretro/tgbdual-libretro/archive/master.tar.gz           -> tgbdual-libretro.tar.gz
#  https://github.com/Zlika/theodore/archive/master.tar.gz                      -> theodore.tar.gz
#  https://github.com/SourMesen/Mesen/archive/master.tar.gz                     -> Mesen.tar.gz
#  https://github.com/libretro/mupen64plus-libretro/archive/master.tar.gz       -> mupen64plus-libretro.tar.gz
#  https://github.com/libretro/mupen64plus-libretro/archive/master.tar.gz       -> mupen64plus-libretro.tar.gz
#  https://github.com/libretro/paraLLeXT/archive/master.tar.gz                  -> paraLLeXT.tar.gz
#  https://github.com/libretro/parallel-n64/archive/master.tar.gz               -> parallel-n64.tar.gz
#  https://github.com/libretro/Dinothawr/archive/master.tar.gz                  -> Dinothawr.tar.gz
#  https://github.com/libretro/libretro-3dengine/archive/master.tar.gz          -> libretro-3dengine.tar.gz
#  https://github.com/libretro/libretro-remotejoy/archive/master.tar.gz         -> libretro-remotejoy.tar.gz
#  https://github.com/libretro/blueMSX-libretro/archive/master.tar.gz           -> blueMSX-libretro.tar.gz
#  https://github.com/libretro/fmsx-libretro/archive/master.tar.gz              -> fmsx-libretro.tar.gz
#  https://github.com/libretro/libretro-2048/archive/master.tar.gz              -> libretro-2048.tar.gz
#  https://github.com/libretro/libretro-vecx/archive/master.tar.gz              -> libretro-vecx.tar.gz
#  https://github.com/libretro/citra/archive/master.tar.gz                      -> citra.tar.gz
#  https://github.com/libretro/ThePowderToy/archive/master.tar.gz               -> ThePowderToy.tar.gz
#  https://github.com/libretro/ppsspp/archive/master.tar.gz                     -> ppsspp.tar.gz
#  https://github.com/libretro/prosystem-libretro/archive/master.tar.gz         -> prosystem-libretro.tar.gz
#  https://github.com/libretro/libretro-o2em/archive/master.tar.gz              -> libretro-o2em.tar.gz
#  https://github.com/libretro/4do-libretro/archive/master.tar.gz               -> 4do-libretro.tar.gz
#  https://github.com/libretro/crawl-ref/archive/master.tar.gz                  -> crawl-ref.tar.gz
#  https://github.com/libretro/hatari/archive/master.tar.gz                     -> hatari.tar.gz
#  https://github.com/libretro/TempGBA-libretro/archive/master.tar.gz           -> TempGBA-libretro.tar.gz
#  https://github.com/libretro/gpsp/archive/master.tar.gz                       -> gpsp.tar.gz
#  https://github.com/libretro/emux/archive/master.tar.gz                       -> emux.tar.gz
#  https://github.com/libretro/fuse-libretro/archive/master.tar.gz              -> fuse-libretro.tar.gz
#  https://github.com/libretro/gw-libretro/archive/master.tar.gz                -> gw-libretro.tar.gz
#  https://github.com/libretro/ChaiLove/archive/master.tar.gz                   -> ChaiLove.tar.gz
#  https://github.com/libretro/81-libretro/archive/master.tar.gz                -> 81-libretro.tar.gz
#  https://github.com/libretro/libretro-lutro/archive/master.tar.gz             -> libretro-lutro.tar.gz
#  https://github.com/libretro/PokeMini/archive/master.tar.gz                   -> PokeMini.tar.gz
#  https://github.com/libretro/libretro-meowPC98/archive/master.tar.gz          -> libretro-meowPC98.tar.gz
#  https://github.com/libretro/NP2kai/archive/master.tar.gz                     -> NP2kai.tar.gz
#  https://github.com/libretro/px68k-libretro/archive/master.tar.gz             -> px68k-libretro.tar.gz
#  https://github.com/libretro/libretro-uzem/archive/master.tar.gz              -> libretro-uzem.tar.gz
#  https://github.com/libretro/libretro-atari800/archive/master.tar.gz          -> libretro-atari800.tar.gz
#  https://github.com/MJaoune/vemulator-libretro/archive/master.tar.gz          -> vemulator-libretro.tar.gz
#  https://github.com/meepingsnesroms/Mu/archive/master.tar.gz                  -> Mu.tar.gz
#  https://github.com/libretro/Dinothawr/archive/master.tar.gz                  -> Dinothawr.tar.gz
#"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl vulkan"

DEPEND=">=net-libs/libpcap-1.8.1-r2"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=( "${FILESDIR}/mednafen_psx_hw.patch" )

src_unpack() {
  git-r3_src_unpack
  "${S}/libretro-fetch.sh" --shallow --cores || die
}

src_prepare() {
  default

  sed -i 's/\\\"-j$JOBS\\\"/${MAKEOPTS}/g' "${S}/libretro-build-common.sh"
  sed -i 's/-j$JOBS/${MAKEOPTS}/g' "${S}/libretro-build-common.sh"
}

src_configure() {
  if ! use opengl ; then
    sed -i '/export BUILD_LIBRETRO_GL=1/d' "${S}/libretro-config.sh"
  fi
}

multilib_src_compile() {
  cd ..

  if [ "${MULTILIB_ABI_FLAG}" = "abi_x86_64" ] ; then
    export PTR64=1
  else
    export PTR64=0
  fi

  export RARCH_DIST_DIR="${BUILD_DIR}"
  export CXX11="${CXX}"

  "${S}/libretro-build.sh"

  if use vulkan ; then
    LDFLAGS="$LDFLAGS -lpthread" HAVE_PARALLEL=1 HAVE_OPENGL=0 "${S}/libretro-build.sh" parallel_n64
  fi

  if use opengl || use vulkan ; then
    "${S}/libretro-build.sh" mednafen_psx_hw
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
