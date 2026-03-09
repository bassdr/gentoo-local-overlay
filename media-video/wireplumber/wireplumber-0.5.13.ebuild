# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay fork: system-service USE flag now works on OpenRC.
# Installs /etc/init.d/wireplumber-system (runs as acct-user/pipewire).
# See also: media-video/pipewire with the same USE flag.

EAPI=8

# 1. Please regularly check (even at the point of bumping) Fedora's packaging
# for needed backports at https://src.fedoraproject.org/rpms/wireplumber/tree/rawhide
#
# 2. Keep an eye on git master (for both PipeWire and WirePlumber) as things
# continue to move quickly. It's not uncommon for fixes to be made shortly
# after releases.

# Generate using https://github.com/thesamesam/sam-gentoo-scripts/blob/main/niche/generate-wireplumber-docs
: ${WIREPLUMBER_DOCS_PREBUILT:=1}

WIREPLUMBER_DOCS_PREBUILT_DEV=sam
WIREPLUMBER_DOCS_VERSION="$(ver_cut 1-3)"
WIREPLUMBER_DOCS_USEFLAG="+doc"

LUA_COMPAT=( lua5-{3,4} )
PYTHON_COMPAT=( python3_{11..14} )

inherit lua-single meson python-any-r1 systemd

DESCRIPTION="Replacement for pipewire-media-session"
HOMEPAGE="https://gitlab.freedesktop.org/pipewire/wireplumber"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/pipewire/${PN}.git"
	EGIT_BRANCH="master"
	inherit git-r3
else
	SRC_URI="https://gitlab.freedesktop.org/pipewire/${PN}/-/archive/${PV}/${P}.tar.bz2"

	if [[ ${WIREPLUMBER_DOCS_PREBUILT} == 1 ]] ; then
		SRC_URI+=" !doc? ( https://dev.gentoo.org/~${WIREPLUMBER_DOCS_PREBUILT_DEV}/distfiles/${CATEGORY}/${PN}/${PN}-${WIREPLUMBER_DOCS_VERSION}-docs.tar.xz )"
		WIREPLUMBER_DOCS_USEFLAG="doc"
	fi

	KEYWORDS="amd64 arm arm64 ~loong ~mips ppc ppc64 ~riscv ~sparc x86"
fi

LICENSE="MIT"
SLOT="0/0.5"
IUSE="${WIREPLUMBER_DOCS_USEFLAG} doc elogind system-service systemd test"

# bassdr: system-service no longer requires systemd; on OpenRC it installs
# /etc/init.d/wireplumber-system instead of systemd system units.
REQUIRED_USE="
	${LUA_REQUIRED_USE}
	?? ( elogind systemd )
"

RESTRICT="!test? ( test )"

BDEPEND="
	${PYTHON_DEPS}
	dev-libs/glib
	>=dev-util/gdbus-codegen-2.80.5-r1
	dev-util/glib-utils
	sys-devel/gettext
	doc? (
		$(python_gen_any_dep '
			dev-python/breathe[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]
		')
	)
	test? ( sys-apps/dbus )
"
DEPEND="
	${LUA_DEPS}
	>=dev-libs/glib-2.68
	>=media-video/pipewire-1.0.5-r1:=
	virtual/libintl
	elogind? ( sys-auth/elogind )
	systemd? ( sys-apps/systemd )
"
RDEPEND="
	${DEPEND}
	system-service? (
		acct-user/pipewire
		acct-group/pipewire
	)
"

DOCS=( {NEWS,README}.rst )

PATCHES=(
	"${FILESDIR}"/${PN}-0.5.6-config-disable-sound-server-parts.patch
)

python_check_deps() {
	if use doc; then
		python_has_version \
			"dev-python/sphinx[${PYTHON_USEDEP}]" \
			"dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]" \
			"dev-python/breathe[${PYTHON_USEDEP}]" || return 1
	else
		return 0
	fi
}

pkg_setup() {
	lua-single_pkg_setup
	python-any-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Ddaemon=true
		-Dtools=true
		-Dmodules=true
		$(meson_feature doc)
		-Dintrospection=disabled
		-Dsystem-lua=true
		-Dsystem-lua-version=$(ver_cut 1-2 $(lua_get_version))
		$(meson_feature elogind)
		$(meson_feature systemd)
		# bassdr: only install systemd system units when systemd is actually in use
		-Dsystemd-system-service=$(use system-service && use systemd && echo true || echo false)
		$(meson_use systemd systemd-user-service)
		-Dsystemd-system-unit-dir=$(systemd_get_systemunitdir)
		-Dsystemd-user-unit-dir=$(systemd_get_userunitdir)
		$(meson_use test tests)
		$(meson_use test dbus-tests)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	if ! use doc && [[ ${WIREPLUMBER_DOCS_PREBUILT} == 1 ]] ; then
		doman "${WORKDIR}"/${PN}-${WIREPLUMBER_DOCS_VERSION}-docs/man/*/*.[0-8]
	fi

	# User-session OpenRC service (login session, uses XDG_RUNTIME_DIR from elogind/PAM)
	exeinto /etc/user/init.d
	newexe "${FILESDIR}"/wireplumber.initd wireplumber

	if use system-service && ! use systemd; then
		# bassdr: OpenRC system service — runs as acct-user/pipewire,
		# connects to pipewire-system socket at /run/pipewire.
		exeinto /etc/init.d
		newexe "${FILESDIR}"/wireplumber-system.initd wireplumber-system
	fi

	mv "${ED}"/usr/share/doc/wireplumber/* "${ED}"/usr/share/doc/${PF} || die
	rmdir "${ED}"/usr/share/doc/wireplumber || die
}

pkg_postinst() {
	if use system-service; then
		if use systemd; then
			ewarn
			ewarn "WARNING: system-service with systemd installs system-wide systemd units."
			ewarn "This is likely NOT what you want. Use systemd user units instead."
			ewarn
		else
			elog
			elog "system-service (OpenRC): installed /etc/init.d/wireplumber-system"
			elog "This connects to the pipewire-system instance at /run/pipewire."
			elog
			elog "Enable with:"
			elog "  rc-update add wireplumber-system default"
			elog
			elog "Requires media-video/pipewire[system-service] and"
			elog "  rc-update add pipewire-system default"
			elog
		fi
	fi
}
