# Copyright 2008-2013 Funtoo Technologies
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils multilib linux-info

DESCRIPTION="Guitar Pro 6 Tabulator Play"
HOMEPAGE="http://www.guitar-pro.com/"
#SRC_URI="http://download7.guitar-pro.com/fca6838190bdcc8d3112d4bfca1bd8f4/4fec86a3/gp6/gp6-full-linux-demo-r11201.deb"
SRC_URI="gp6-full-linux-r${PV}.deb"

LICENSE="ArobasMusic"
SLOT="0"
KEYWORDS="-* ~x86 ~amd64"
IUSE="multilib"
RESTRICT="fetch strip"

NATIVE_DEPEND="
  dev-qt/qtgui
  dev-qt/qtopengl
  dev-qt/qtwebkit
  media-sound/pulseaudio
  media-libs/portaudio
  dev-libs/expat
  =dev-libs/openssl-0.9.8*
"

RDEPEND="
  x11-libs/gksu
  !amd64? ( ${NATIVE_DEPEND} )
  amd64? (
    || (
      app-emulation/emul-linux-x86-qtlibs[-abi_x86_32(-)]
      dev-qt/qtgui[abi_x86_32(-)]
    )
    || (
      app-emulation/emul-linux-x86-qtlibs[-abi_x86_32(-)]
      dev-qt/qtopengl[abi_x86_32(-)]
    )
    || (
      app-emulation/emul-linux-x86-qtlibs[-abi_x86_32(-)]
      dev-qt/qtwebkit[abi_x86_32(-)]
    )
    || (
      app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)]
      media-sound/pulseaudio[abi_x86_32(-)]
    )
    || (
      app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)]
      media-libs/portaudio[abi_x86_32(-)]
    )
    || (
      app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
      dev-libs/expat[abi_x86_32(-)]
    )
    =dev-libs/openssl-0.9.8*[abi_x86_32(-)]
  )
"

DEPEND="${RDEPEND}"

S=${WORKDIR}

QA_PRESTRIPPED="${CHMOD_FILES}"
DT_RPATH="/opt/*"

pkg_nofetch() {
	einfo "Please download"
	einfo "${SRC_URI}"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

src_unpack() {
	/usr/bin/ar x ${DISTDIR}/${A}
	cd ${S}
	tar xfv data.tar.gz
	rm control.tar.gz
	rm debian-binary
	rm data.tar.gz
}
pkg_setup() {
	if use kernel_linux; then
		CONFIG_CHECK="SND_SEQUENCER"
		linux-info_pkg_setup
	fi
}
src_install() {
	cp ${S}/opt/GuitarPro6/launcher.sh ${S}/opt/GuitarPro6/gp-launcher.sh || die
	sed -i "s/exec \.\/GuitarPro \"\$\*\"/\[\[ -e \.\/libz.so.1 \]\] \&\& sudo mv \.\/libz.so.1 \.\/libz.so.1.bk/g" ${S}/opt/GuitarPro6/gp-launcher.sh || die
	echo "exec ./GuitarPro \"$*\"" >> ${S}/opt/GuitarPro6/gp-launcher.sh || die

	cd ${S}/opt/GuitarPro6
	#ewarn "$(pwd)"
	#rm ${S}/opt/GuitarPro6/libz.so.1 || die "can not remove libz.so.1"

	sed -i "s/launcher.sh/gp-launcher.sh/g" ${S}/usr/share/applications/GuitarPro6.desktop
	sed -i "s/Categories=Application;AudioVideo;/Categories=AudioVideo;/g" ${S}/usr/share/applications/GuitarPro6.desktop
	cp -r ${S} ${D} || die "Error: Copy ${S} ${D}"
	mv $D/work/* ${D} || die "Error: mv ${D}/work/* ${D}"
	rmdir ${D}/work
	
	dodir ${S}/opt/GuitarPro6/ || die "dodir error"
	dosym /usr/lib/libcrypto.so /opt/GuitarPro6/libcrypto.so.0.9.8 || die "Error: create symlink libcrypto"
	dosym /usr/lib/libssl.so /opt/GuitarPro6/libssl.so.0.9.8 || die "Error: create symlink libssl"
	dosym /opt/GuitarPro6/gp-launcher.sh /usr/local/bin/GuitarPro6
	rm -r ${S} || die "Error: rm -r ${S}"
}

pkg_postinst() {
	ewarn "The library libz.so.1 is not needed - if it exists can not be started GuitarPro."
	ewarn "You want GuitarPro6 update, delete ~/.config/Arobas Music/Guitar Pro 6.conf"
	einfo 'If you get the error "Can not open shared library /usr/lib/alsa-lib/libasound_module_conf_pulse.so"'
	einfo 'Create the file /etc/ld.so.conf.d/alsa32.conf with the following content /usr/lib32/alsa-lib'
	einfo 'Correct /usr/share/alsa/alsa.conf.d/51-pulseaudio-probe.conf of lib "/usr/lib32/alsa-lib/libasound_module_conf_pulse.so"' 
	einfo 'according lib "libasound_module_conf_pulse.so and run ldconfig"'
	einfo "please visit this website to solve it. URL: http://forums.gentoo.org/viewtopic-t-916116-start-0.html"
	einfo "If you find errors in this ebuild, please send me an email."
	einfo "knamarksan@gmail.com"
	einfo
	einfo "add modul snd-seq-midi in /etc/conf.d/modules for autoload"
}

