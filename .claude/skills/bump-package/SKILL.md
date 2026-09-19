---
name: bump-package
description: Check whether an overlay package has a newer upstream release and bump the ebuild to it. Use when asked to update/bump a package, check for new versions, see what's out of date, or sync an overlay package with upstream. Also covers deciding whether a package should be dropped because the gentoo tree caught up.
---

# Bump a package to a new upstream version

Applies to packages in this overlay (`/var/db/repos/bassdr`). Run every command
from the overlay root.

## 1. Establish the current state

```bash
pquery --repo bassdr --max <cat>/<pkg> 2>/dev/null   # our newest visible version
ls <cat>/<pkg>/                                      # all ebuilds, files/, metadata.xml
```

`pquery` respects masking, so it ignores `-9999` live ebuilds. Plain `ls | sort -V`
does not — it sorts `9999` last and will mislead you.

## 2. Find the latest upstream release

The authoritative hook is `<remote-id>` in the package's `metadata.xml`. Read it
first; only fall back to parsing `SRC_URI`/`HOMEPAGE` if there is none.

```bash
grep remote-id <cat>/<pkg>/metadata.xml
```

All of these are verified working in this environment (`gh` is authenticated as
`bassdr`; `jq` and `curl` are installed):

| remote-id type | command |
|---|---|
| `github` | `gh api repos/<owner>/<repo>/releases/latest --jq .tag_name` |
| `github` (no releases, tags only) | `gh api repos/<owner>/<repo>/tags --jq '.[0].name'` |
| `gitlab` | `curl -s "https://gitlab.com/api/v4/projects/<owner>%2F<repo>/releases?per_page=1" \| jq -r '.[0].tag_name'` |
| `freedesktop-gitlab` | `curl -s "https://gitlab.freedesktop.org/api/v4/projects/<group>%2F<repo>/releases?per_page=1" \| jq -r '.[0].tag_name'` |
| `pypi` | `curl -s https://pypi.org/pypi/<name>/json \| jq -r .info.version` |

Note the `%2F` — the GitLab API wants the URL-encoded `group/project` path.

`sourceforge` has no clean "latest source release" endpoint;
`best_release.json` returns whatever platform SourceForge thinks you want (often
a Windows zip). Check the project's files listing by hand instead.

If `metadata.xml` has no `remote-id`, add one — `pkgcheck` infers the correct
value for you and reports it as `MissingRemoteId`.

## 3. Decide whether to bump at all

**Check the gentoo tree before touching anything.** This overlay only carries
packages gentoo lacks, or packages where our version diverges deliberately.

```bash
pquery --repo gentoo --max <cat>/<pkg> 2>/dev/null
```

- **Gentoo has an equal or newer version and we carry no custom patches/USE
  flags** → do not bump. Delete the package from the overlay instead and tell
  the user why.
- **Gentoo does not have the package** → bump normally.
- **We diverge on purpose** (local patches, extra USE flags such as the
  `system-service` OpenRC work) → bump, and re-apply our delta on top of the new
  upstream version. Diff our ebuild against gentoo's to see exactly what the
  delta is before you start:
  ```bash
  diff -u /var/db/repos/gentoo/<cat>/<pkg>/<pkg>-<ver>.ebuild <cat>/<pkg>/<pkg>-<ver>.ebuild
  ```

## 4. Create the new ebuild

**Always `git mv` — never `cp` + `rm`.** It keeps the file's history attached.

```bash
git mv <cat>/<pkg>/<pkg>-<old>.ebuild <cat>/<pkg>/<pkg>-<new>.ebuild
```

Use plain `mv` only for a file that is not yet tracked.

Keep the old ebuild alongside the new one only when you actually want both
versions available (a slotted package, or an upgrade you don't yet trust).
Otherwise the rename is the bump.

Then edit the new file:

- Bump version variables. Prefer `${PV}`/`${P}` in `SRC_URI` and `S` so the next
  bump is a rename and nothing else.
- Update the copyright year if you touch the file:
  `# Copyright 1999-<current year> Gentoo Authors`
- **`KEYWORDS`**: carry over what the old ebuild had. Never add a stable keyword
  you have not personally tested — a fresh version is `~arch`. Binary-only
  packages use `-* ~amd64` style.
- Check whether upstream changed dependencies, build system, or configure flags.
  A version bump is not always a pure rename.

### Revisions (`-rN`)

- A new **upstream** version never carries a revision: `foo-1.2.3.ebuild`, not
  `foo-1.2.3-r1.ebuild`. `-rN` is reserved for our own changes to a given
  upstream version.
- This is a personal overlay, so **do not bump `-rN` reflexively**. If our
  version already diverges from gentoo (the plain version does not exist
  upstream in the tree), edit the ebuild in place.
- Add a revision only when a user who already installed the package needs the
  change to reach them — different installed files, a runtime fix, changed
  dependencies. Build-time-only fixes and stylistic edits do not need one.

## 5. Regenerate the Manifest

Required after **any** change to an ebuild or to anything in the package
directory — this overlay uses thick Manifests, which checksum the ebuild,
`metadata.xml`, and `files/` as well as distfiles.

```bash
ebuild <cat>/<pkg>/<pkg>-<new>.ebuild manifest
```

This downloads every distfile the `SRC_URI` can resolve to across USE flags and
arches, so a package with many conditional variants will pull all of them.

## 6. Validate

Run the `validate-ebuild` skill. At minimum:

```bash
pkgcheck scan <cat>/<pkg>
ebuild <cat>/<pkg>/<pkg>-<new>.ebuild clean install
```

Then a real install test: `emerge -av =<cat>/<pkg>-<new>`.

## 7. Report

Tell the user the old version, the new version, what changed in the ebuild
beyond the rename, and the validation result. Do not commit unless asked.

## Checking everything at once

To sweep the whole overlay for pending bumps, loop over packages that have a
`remote-id`, compare `pquery --repo bassdr --max` against the upstream query,
and report only the ones that differ. Also flag any package where
`pquery --repo gentoo --max` has caught up — those are deletion candidates, not
bump candidates.
