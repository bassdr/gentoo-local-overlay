# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Gentoo Linux package overlay** (ebuild repository) named `bassdr`. It provides additional packages not in the main Gentoo tree, based on the official Gentoo repository (`masters = gentoo` in `metadata/layout.conf`).

Users add it via:
```bash
eselect repository add bassdr git https://github.com/bassdr/gentoo-local-overlay.git
emerge --sync bassdr
```

## Ebuild Validation and Quality Checks

```bash
# Check ebuilds for QA issues (run from repo root or package dir)
pkgcheck scan

# Regenerate Manifest (checksums) after modifying an ebuild or adding source files
ebuild <path/to/package.ebuild> manifest

# Verify a package builds correctly (in a test environment)
emerge -av =category/package-version
```

## Ebuild Structure

Each package lives at `category/package-name/package-name-version.ebuild` and follows Gentoo EAPI conventions (currently EAPI 8). Key components:

- **`files/`** subdirectory: patches and auxiliary files referenced in ebuilds
- **`metadata.xml`**: maintainer info, USE flag descriptions, upstream links
- **`Manifest`**: BLAKE2B/SHA512 checksums — regenerate with `ebuild foo.ebuild manifest` after any change

## Package Categories in This Overlay

- `acct-group/`, `acct-user/` — system account definitions for services (nqptp, shairport-sync)
- `dev-libs/` — C++ libraries (POCO, mongo-cxx-driver, wt web toolkit, libclangformat-ide)
- `dev-util/` — IDEs: CLion, PyCharm, MonoDevelop
- `media-sound/` — shairport-sync (AirPlay), GuitarPro6
- `net-misc/` — FreeRDP (remote desktop), nqptp, omada-sdn-controller
- `sys-apps/` — emerge-update helper script
- `sys-kernel/` — Raspberry Pi kernel sources

## Custom Eclasses

Located in `eclass/`:
- `libretro.eclass` / `libretro-core.eclass` — framework for building Libretro emulator cores

## Ebuild Conventions

- Always specify `EAPI=8` (current standard)
- Binary/pre-built packages: use `src_unpack` or `src_install` only, no build phase; restrict fetch if needed
- For CMake-based packages, inherit `cmake` eclass and use `cmake_src_configure`, `cmake_src_compile`, `cmake_src_test`
- `RESTRICT="mirror"` for packages fetched from upstream directly
- `RESTRICT="test"` when tests cannot run in the Portage sandbox
- Account ebuilds (`acct-user/`, `acct-group/`) inherit `acct-user` or `acct-group` eclass

## OpenRC System Services

This overlay extends several packages with `USE=system-service` support on OpenRC (upstream only supports systemd for system-wide mode). Key patterns:

### File layout for a system service

- **`files/<name>-system.initd`** — OpenRC init script (`#!/sbin/openrc-run`, POSIX-compliant)
- **`files/<name>-system.confd`** — `/etc/conf.d/` config (sourced by OpenRC before the init script)
- **`files/55<name>-system`** — `/etc/env.d/` file for login shell environment (processed by `env-update`)

### Environment variables: conf.d vs env.d

These serve **different audiences** and both may be needed:

| Mechanism | Audience | Installed with | Format |
|-----------|----------|---------------|--------|
| `/etc/conf.d/<service>` | Daemon processes (OpenRC `supervise-daemon`) | `newconfd` | `VAR=value` (shell) |
| `/etc/env.d/55<name>` | User login shells (bash, zsh, csh) | `newins` into `/etc/env.d` | `VAR=value` (no `export`) |

**OpenRC daemons do NOT source `/etc/profile` or `/etc/env.d`** — they only get variables from their conf.d file and what the init script explicitly `export`s.

After installing env.d files, users run `env-update && source /etc/profile`.

### Sharing variables between services

Use a single canonical conf.d file and source it from others:
```sh
# /etc/conf.d/pipewire-pulse-system
. /etc/conf.d/pipewire-system
PULSE_SYSTEM=1
```

Init scripts keep `${VAR:=default}` fallbacks so they work even without conf.d:
```sh
: "${PIPEWIRE_USER:=pipewire}"
export XDG_RUNTIME_DIR="${PIPEWIRE_RUNTIME_DIR}"
```

### Conditional installation

Guard service-specific files behind the relevant USE flags so users don't get config they didn't ask for:
```bash
if use sound-server; then
    newexe "${FILESDIR}"/pipewire-pulse-system.initd pipewire-pulse-system
    newconfd "${FILESDIR}"/pipewire-pulse-system.confd pipewire-pulse-system
fi
```

### Current system services in this overlay

- **pipewire** (`media-video/pipewire`): `pipewire-system`, `pipewire-pulse-system` (if `sound-server`)
- **wireplumber** (`media-video/wireplumber`): `wireplumber-system`
- **timidity++** (`media-sound/timidity++`): system-service MIDI sequencer

## Updating or Adding Packages

1. Copy an existing ebuild as a template from the same category
2. Update `SRC_URI`, `KEYWORDS`, version variables, and checksums
3. Run `ebuild <new.ebuild> manifest` to generate the Manifest entry
4. Test with `emerge -av =category/package-version` on a Gentoo system
5. Update `metadata.xml` if USE flags or upstream info changed
