# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for Shairport-sync"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( "${PN}" pipewire )

acct-user_add_deps
