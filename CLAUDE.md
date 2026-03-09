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

## Updating or Adding Packages

1. Copy an existing ebuild as a template from the same category
2. Update `SRC_URI`, `KEYWORDS`, version variables, and checksums
3. Run `ebuild <new.ebuild> manifest` to generate the Manifest entry
4. Test with `emerge -av =category/package-version` on a Gentoo system
5. Update `metadata.xml` if USE flags or upstream info changed
