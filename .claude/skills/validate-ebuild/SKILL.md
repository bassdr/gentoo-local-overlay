---
name: validate-ebuild
description: Run QA checks on one or more overlay ebuilds — pkgcheck, Manifest consistency, a real emerge build, sandbox violations, and Gentoo devmanual formatting rules. Use after creating or editing an ebuild, before committing, or when asked to validate/check/lint an ebuild or the whole overlay.
---

# Validate an ebuild

Applies to packages in this overlay (`/var/db/repos/bassdr`). Run every command
from the overlay root unless noted. Target: one package
(`<cat>/<pkg>`) or `--all` for the whole overlay.

**Do not stop at phase checks.** A package is validated when a **real
`emerge`** of it succeeds. The five checks below are in order; step 4 is the
one that catches what everything else misses.

## 1. pkgcheck

```bash
pkgcheck scan <cat>/<pkg>          # single package
pkgcheck scan --cache=-git         # whole overlay
```

`pkgcheck` is the authority — fix what it reports rather than reasoning it away.
Notes:

- First run in a fresh clone may fail with `failed running git log: Invalid
  revision range`. That means `origin/HEAD` points at a branch the fetch
  refspec doesn't cover (here: it must point at `main`,
  `git remote set-head origin main`). `pkgcheck cache -R` clears stale caches.
- **`UnusedInherits`** — the eclass list must match what the ebuild actually
  calls. If the ebuild installs bash completions, inherit `shell-completion`
  (EAPI 8; it provides `newbashcomp`/`dobashcomp`). Do not leave an inherited
  eclass just because a template had it.
- **`VariableOrderWrong`** — skel.ebuild order: `DESCRIPTION`, `HOMEPAGE`,
  `SRC_URI`, `S`, `LICENSE`, `SLOT`, `KEYWORDS`, `IUSE`, `RESTRICT`.
  Custom variables (e.g. `BASE_URI`, `MY_P`) go right before the first
  variable they feed — conventionally between `HOMEPAGE` and `SRC_URI`.
- **`MissingRemoteId`** — `pkgcheck` prints the exact line to add to
  `metadata.xml`; copy it verbatim.
- **`WhitespaceFound` / `ExcessiveLineLength` / `DoubleEmptyLine`** — ebuilds
  are tab-indented (1 tab per level, tab = 4 columns), ≤ 80 columns, no
  trailing whitespace.
- **`UnknownLicense`** — `LICENSE` tokens must exist as files in
  `/var/db/repos/gentoo/licenses/`. Bundled third-party components are listed
  as extra tokens, not folded into the main license.
- Exit status is nonzero when findings exist, so a silent run means clean.

## 2. Manifest

```bash
ebuild <cat>/<pkg>/<pkg>-<ver>.ebuild manifest
```

Required after **any** change to the ebuild or anything else in the package
directory — this overlay does not set `thin-manifests`, so Manifests are thick:
they checksum the ebuild, `metadata.xml`, and `files/` as well as distfiles.
Never edit a Manifest by hand.

The command fetches every distfile resolvable from `SRC_URI` across USE flags
and arches — large, but idempotent when nothing changed.

## 3. Phase test (cheap smoke test)

```bash
ebuild <cat>/<pkg>/<pkg>-<ver>.ebuild clean install
```

Then inspect the image before moving on:

```bash
IMG=/var/tmp/portage/<cat>/<pkg>-<ver>/image
find "$IMG" | sort                      # layout: no strays outside D
ls -l "$IMG"/usr/bin 2>/dev/null        # exec bits, symlinks sane
```

Clean up afterwards: `ebuild <cat>/<pkg>/<pkg>-<ver>.ebuild clean`.

**This proves less than it seems.** It runs phases in your current
environment, not emerge's — see step 4. It also can't install anything that
`dobin`/`newbin` place (`install -o 0 -g 0` chowns to root and fails with
`Operation not permitted` when portage runs unprivileged) — that's another
reason the real emerge in step 4 is mandatory.

## 4. Real build (the definitive test)

```bash
emerge -av =<cat>/<pkg>-<ver>
```

Run this for every ebuild you create or substantially change, not just when
you feel like it. Case that motivated this rule: a completion script generated
by executing the fetched binary inside `src_install` passed `ebuild install`
cleanly but failed a real emerge with a sandbox `ACCESS DENIED`. Build-time
execution of fetched binaries also depends on the machine's CPU and mount
state — avoid it entirely; pre-generate files into `files/` instead.

Read the output for all of these, in the build log
(`/var/tmp/portage/<cat>/<pkg>-<ver>/temp/build.log`) when long:

- `SANDBOX ACCESS VIOLATION SUMMARY` — the emerge **fails** on these even when
  the underlying write is harmless (e.g. a runtime probing
  `/sys/kernel/debug/tracing/trace_marker`). The fix is to stop doing whatever
  touched the path — never paper over it with `addwrite` unless you fully
  understand the write and accept it happening as root at install time.
- `ACCESS DENIED` / `open_wr` lines
- QA warnings near the end (`QA_PREBUILT` misses, files installed outside
  `${D}`, wrong shebangs)

### Workdir permission gotcha

A failed root `emerge` leaves `/var/tmp/portage/<cat>/<pkg>-<ver>` owned by
root. Subsequent **user-run** `ebuild`/`pkgcheck` commands then fail with
`Permission denied` on cleanup. Clear it first:

```bash
sudo rm -rf /var/tmp/portage/<cat>/<pkg>-<ver>
```

Conversely, after a user-run phase test, a root emerge may need the same. When
phases fail with permission errors before doing anything, suspect this first.

## 5. Formatting audit (devmanual rules)

`pkgcheck` catches most, but eyeball these in every touched ebuild:

- Copyright header exactly:
  ```
  # Copyright 1999-<current year> Gentoo Authors
  # Distributed under the terms of the GNU General Public License v2
  ```
  (update the year on files touched this year)
- Variable order per skel.ebuild (see step 1)
- Tab indentation, ≤ 80 cols, no trailing whitespace, UTF-8, no trailing empty
  lines
- `metadata.xml`: maintainer present, USE flags documented, `remote-id` current

## Pre-commit checklist

- [ ] `pkgcheck scan <cat>/<pkg>` — silent
- [ ] Manifest regenerated and `git status` shows it staged with the change
- [ ] `emerge -av =<cat>/<pkg>-<ver>` — succeeds, no sandbox violations
- [ ] New ebuild committed with `git mv` (never `cp`+`rm`) when bumping
- [ ] `metadata.xml` still accurate: maintainer, USE flag docs, `remote-id`
- [ ] Copyright year updated on files touched this year

Whole-overlay sweep before a push: `pkgcheck scan --cache=-git` and fix or
acknowledge everything it lists for files you touched.
