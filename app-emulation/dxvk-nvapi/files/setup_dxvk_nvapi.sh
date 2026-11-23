#!/bin/bash
# Enable or disable dxvk-nvapi in a wine prefix, the way Proton does it:
# symlink the nvapi DLLs and the NVIDIA driver's DLSS (NGX) DLLs into the
# prefix and override them to native. Games then need DXVK_ENABLE_NVAPI=1
# (and NVIDIA_WINE_DLL_DIR for DLSS) in their environment.
#
#   WINEPREFIX=/path/to/prefix setup_dxvk_nvapi.sh install|uninstall
#
# WINE selects the wine binary (default: wine from PATH).

basedir=/usr/lib/dxvk-nvapi
ngxdir=${NVIDIA_WINE_DLL_DIR:-/usr/lib64/nvidia/wine}
wine=${WINE:-wine}

die() {
	echo "${0##*/}: $*" >&2
	exit 1
}

[[ $1 == install || $1 == uninstall ]] ||
	die "usage: WINEPREFIX=/path/to/prefix ${0##*/} install|uninstall"
action=$1

prefix=${WINEPREFIX:-${HOME}/.wine}
[[ -f ${prefix}/system.reg ]] || die "${prefix} is not a wine prefix"

windir=${prefix}/drive_c/windows
if [[ -d ${windir}/syswow64 ]]; then
	dlls=(
		"x64/nvapi64.dll:system32"
		"x64/nvofapi64.dll:system32"
		"x32/nvapi.dll:syswow64"
	)
	ngx_dest=system32
else
	dlls=( "x32/nvapi.dll:system32" )
	ngx_dest=
fi

override() {
	if [[ ${action} == install ]]; then
		"${wine}" reg add 'HKCU\Software\Wine\DllOverrides' /v "$1" \
			/d native /f >/dev/null 2>&1 ||
			die "failed to add the $1 override"
	else
		# fails when the value is already gone, which is fine
		"${wine}" reg delete 'HKCU\Software\Wine\DllOverrides' /v "$1" \
			/f >/dev/null 2>&1
	fi
}

# link <source> <dest dir>
link() {
	local dst=${windir}/$2/${1##*/}

	if [[ ${action} == install ]]; then
		[[ -f $1 ]] || die "missing $1"
		ln -sfn "$1" "${dst}" || die "failed to link ${dst}"
		echo "linked ${dst}"
	elif [[ -L ${dst} && $(readlink "${dst}") == "$1" ]]; then
		rm -f "${dst}" || die "failed to remove ${dst}"
		echo "removed ${dst}"
	fi
}

for entry in "${dlls[@]}"; do
	link "${basedir}/${entry%%:*}" "${entry##*:}"
	dll=${entry%%:*}
	dll=${dll##*/}
	override "${dll%.dll}"
done

# DLSS: Proton copies these two from the driver; a symlink keeps them
# current across driver updates.
if [[ -n ${ngx_dest} && -d ${ngxdir} ]]; then
	for dll in _nvngx.dll nvngx.dll; do
		[[ -f ${ngxdir}/${dll} ]] && link "${ngxdir}/${dll}" "${ngx_dest}"
	done
fi
