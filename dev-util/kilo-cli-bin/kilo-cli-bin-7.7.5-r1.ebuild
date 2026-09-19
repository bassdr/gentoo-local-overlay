# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit shell-completion

DESCRIPTION="Kilo Code CLI, an open source AI coding agent for the terminal"
HOMEPAGE="https://kilo.ai/cli https://github.com/Kilo-Org/kilocode"

BASE_URI="https://github.com/Kilo-Org/kilocode/releases/download/v${PV}"
SRC_URI="
	amd64? (
		elibc_glibc? (
			cpu_flags_x86_avx2? ( ${BASE_URI}/kilo-linux-x64.tar.gz -> ${P}-x64.tar.gz )
			!cpu_flags_x86_avx2? ( ${BASE_URI}/kilo-linux-x64-baseline.tar.gz -> ${P}-x64-baseline.tar.gz )
		)
		elibc_musl? (
			cpu_flags_x86_avx2? ( ${BASE_URI}/kilo-linux-x64-musl.tar.gz -> ${P}-x64-musl.tar.gz )
			!cpu_flags_x86_avx2? ( ${BASE_URI}/kilo-linux-x64-baseline-musl.tar.gz -> ${P}-x64-baseline-musl.tar.gz )
		)
	)
	arm64? (
		elibc_glibc? ( ${BASE_URI}/kilo-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
		elibc_musl? ( ${BASE_URI}/kilo-linux-arm64-musl.tar.gz -> ${P}-arm64-musl.tar.gz )
	)
"

# The release tarball has no top-level directory.
S="${WORKDIR}"

# MIT: kilo itself and the opencode base it is built on
# Apache-2.0: bundled sandbox-runtime
# LGPL-2+ MIT: bundled bubblewrap, statically linked against musl
LICENSE="MIT Apache-2.0 LGPL-2+"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cpu_flags_x86_avx2"

RESTRICT="mirror strip"

QA_PREBUILT="opt/kilo/*"

src_install() {
	local destdir="/opt/kilo"

	insinto "${destdir}"
	doins -r console licenses tree-sitter
	doins kilo-sandbox-mutation-worker.js kilo-sandbox-network-relay.js

	exeinto "${destdir}"
	doexe kilo bwrap kilo-sandbox-seccomp

	# Wrapper, not a symlink: intercepts self-update commands (kilo is
	# managed by Portage) and sets KILO_DISABLE_AUTOUPDATE for the TUI.
	newbin "${FILESDIR}/kilo-wrapper" kilo

	# yargs completion script: bash, and zsh via bashcompinit.
	# Pre-generated (executing the fetched binary at build time trips the
	# portage sandbox). Regenerate with: kilo completion bash
	newbashcomp "${FILESDIR}/kilo-completion.bash" kilo

	# OpenRC service to keep 'kilo remote' running at boot. root-only: it's
	# where provider API keys end up, since the daemon can't see KILO_USER's
	# ~/.bashrc (see the file's own comments).
	newinitd "${FILESDIR}/kilo-remote.initd" kilo-remote
	newconfd "${FILESDIR}/kilo-remote.confd" kilo-remote
	fperms 0600 /etc/conf.d/kilo-remote
}

pkg_postinst() {
	elog "Configure a provider before first use:"
	elog "    kilo auth login"
	elog
	elog "This package is managed by portage: 'kilo upgrade' and 'kilo uninstall'"
	elog "are intercepted and self-updates are disabled. Update with:"
	elog "    emerge --sync bassdr && emerge -u dev-util/kilo-cli-bin"
	elog
	elog "The sandboxed bash tool needs user namespaces (CONFIG_USER_NS) in the kernel."
	elog
	elog "To keep 'kilo remote' running at boot (reachable from the Kilo Cloud"
	elog "Agents web/mobile interface without an active login/SSH session), run"
	elog "'kilo auth login' as the desired user, set KILO_USER in"
	elog "/etc/conf.d/kilo-remote, then:"
	elog "    rc-update add kilo-remote default"
	elog "For more than one session (other users, or other workspaces), see the"
	elog "symlink instructions at the top of /etc/conf.d/kilo-remote."
}
