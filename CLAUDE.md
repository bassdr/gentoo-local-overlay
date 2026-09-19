# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **personal Gentoo package overlay** (ebuild repository) named `bassdr`. It provides additional packages not in the main Gentoo tree, based on the official Gentoo repository (`masters = gentoo` in `metadata/layout.conf`).

- Official Gentoo tree: `/var/db/repos/gentoo`
- This overlay: `/var/db/repos/bassdr`

Users add it via:
```bash
eselect repository add bassdr git https://github.com/bassdr/gentoo-local-overlay.git
emerge --sync bassdr
```

## Skills

Two project skills encode the detailed workflows — prefer them over improvising:

- **`bump-package`** — check upstream for new versions, decide bump vs. delete (gentoo tree may have caught up), rename the ebuild (`git mv`), regenerate the Manifest.
- **`validate-ebuild`** — pkgcheck, Manifest regen rules, phase testing, formatting rules, pre-commit checklist.

## Core Rules (memorize these)

1. **This overlay only carries what gentoo doesn't.** Before adding or bumping a package, check `/var/db/repos/gentoo`. If gentoo has an equal/newer version and we add no custom patches or USE flags → delete ours instead.
2. **`git mv`, never `cp` + `rm`**, when renaming an ebuild for a version bump (plain `mv` for untracked files). Keeps history.
3. **Regenerate the Manifest after ANY change** to an ebuild or anything in its package dir (patches, initd, confd…). This overlay uses **thick Manifests** (no `thin-manifests` in layout.conf), so the Manifest checksums the ebuild, `metadata.xml`, and `files/` too:
   ```bash
   ebuild <category>/<pkg>/<pkg>-<ver>.ebuild manifest   # from overlay root
   ```
4. **Don't bump `-rN` reflexively** — personal overlay, edit in place when our version already diverges from the tree. New revisions only for changes an installed user needs (runtime fixes, changed installed files).
5. **Validate before declaring done**: `pkgcheck scan <cat>/<pkg>` must be silent; test phases with `ebuild <...> clean install` and inspect the image.

```bash
# Check ebuilds for QA issues (exit status nonzero when findings exist)
pkgcheck scan <cat>/<pkg>
pkgcheck scan --cache=-git        # whole overlay; add --cache=-git if git-log errors

# Regenerate Manifest (checksums)
ebuild <path/to/package.ebuild> manifest

# Verify a package builds correctly
emerge -av =category/package-version
```

## Ebuild Structure

Each package lives at `category/package-name/package-name-version.ebuild`:

- **`files/`** subdirectory: patches and auxiliary files referenced in ebuilds
- **`metadata.xml`**: maintainer info, USE flag descriptions, upstream links (`<remote-id>` is the hook for version checks — add it when pkgcheck's `MissingRemoteId` tells you)
- **`Manifest`**: BLAKE2B/SHA512 checksums — regenerate with `ebuild foo.ebuild manifest`, never edit by hand
- **`metadata/md5-cache/`**: Portage's generated cache — **gitignored, never commit it**. It embeds gentoo eclass checksums, so a committed copy goes stale whenever the gentoo tree updates an eclass. Portage builds its own cache in `/var/cache/edb/dep` when the repo has none; no `FEATURES=metadata-transfer` needed.

## Ebuild Conventions

- **Copyright header** (update the year when you touch a file):
  ```
  # Copyright 1999-<current year> Gentoo Authors
  # Distributed under the terms of the GNU General Public License v2
  ```
- **Variable order** (skel.ebuild; pkgcheck enforces): `DESCRIPTION`, `HOMEPAGE`, `SRC_URI`, `S`, `LICENSE`, `SLOT`, `KEYWORDS`, `IUSE`, `RESTRICT`. Helper variables (e.g. `BASE_URI`, `MY_P`) go just before what they feed.
- **Formatting**: tab indentation (1 tab = 1 level = 4 columns), ≤ 80 columns, no trailing whitespace, UTF-8.
- **`EAPI=8`** unless a newer feature is needed (gentoo's skel.ebuild uses EAPI 9; don't mass-migrate).
- **`KEYWORDS`**: carry keywords over on a bump; a fresh version is `~arch`, never stable-untested. Binary-only builds use `-* ~amd64` style. Personal overlay: keyword only what you actually run.
- Binary/pre-built packages: `src_unpack`/`src_install` only, no build phase; `RESTRICT="mirror strip"` as appropriate; `QA_PREBUILT` for the image paths.
- CMake packages: inherit `cmake`, use `cmake_src_configure` / `cmake_src_compile` / `cmake_src_test`.
- `RESTRICT="test"` when tests can't run in the Portage sandbox.
- Account ebuilds (`acct-user/`, `acct-group/`) inherit the matching eclass.
- `metadata.xml` needs a maintainer entry, or install fails; `pkgcheck` reports missing `remote-id`s with the exact line to add.

## Package Categories in This Overlay

- `acct-group/`, `acct-user/` — system accounts (nqptp, pipewire, shairport-sync, timidity)
- `app-emulation/` — anbox, playonlinux
- `dev-dotnet/`, `dev-java/` — nuget, jargs, yuicompressor
- `dev-libs/` — libclangformat-ide, mongo-cxx-driver, properties-cpp, wt
- `dev-python/` — openconnect-sso
- `dev-util/` — kilo-cli-bin, monodevelop, pycharm
- `media-libs/`, `media-plugins/` — alac, anttweakbar, vdr-vnsiserver
- `media-sound/` — GuitarPro6, musescore-soundfont, pipewire-module-spdif-encode, shairport-sync, timidity++
- `media-video/` — karaokemugen-app, pipewire, wireplumber
- `net-misc/` — nqptp, omada-sdn-controller
- `net-print/` — epson-inkjet-printer
- `sys-apps/` — emerge-update

Several exist only because gentoo lags or diverges (pipewire/wireplumber with OpenRC system-service USE flags, timidity++ live ebuild, kilo-cli-bin not in tree).

## Custom Eclasses

Located in `eclass/`:
- `libretro.eclass` / `libretro-core.eclass` — framework for building Libretro emulator cores

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
- **kilo-remote** (`dev-util/kilo-cli-bin`): keeps a `kilo remote` session alive at boot so the Kilo
  Cloud Agents app can reach it without an active login/SSH session. Always installed (no USE flag —
  it adds no dependencies); opt-in via `rc-update add kilo-remote default`. Templated on `$RC_SVCNAME`
  — symlink the init script (`ln -s kilo-remote kilo-remote.foo`) to run more sessions (other users,
  other workspaces), each with its own conf.d, pidfile, and log dir.

## References

- devmanual.gentoo.org — primary reference for ebuild conventions, init scripts, helpers
- `.claude/resources/` — OpenRC user services, portage debugging, overlay workflow notes

## Updating or Adding Packages

Follow the **`bump-package`** skill (upstream check → gentoo-tree check → `git mv` → edit → manifest → validate). In short:

1. Check gentoo tree first — delete instead of bump if it caught up
2. Rename with `git mv`, update `SRC_URI`/version vars/`KEYWORDS`
3. `ebuild <new.ebuild> manifest`
4. `pkgcheck scan` + `ebuild ... clean install`, then `emerge -av =category/package-version`
5. Update `metadata.xml` if USE flags or upstream info changed
