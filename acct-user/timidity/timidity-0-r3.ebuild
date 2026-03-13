# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#
# bassdr overlay: changed primary group from 'nobody' to 'audio' so the
# timidity system service can open /dev/snd/seq for ALSA sequencer mode.

EAPI=8

inherit acct-user

DESCRIPTION="A user for media-sound/timidity++"

ACCT_USER_GROUPS=( "audio" )
ACCT_USER_HOME="/var/lib/timidity"
ACCT_USER_HOME_PERMS="0700"
ACCT_USER_ID="306"

acct-user_add_deps
