# Gentoo Overlay Workflow

## Repository layout

- Official Gentoo tree: `/var/db/repos/gentoo`
- This overlay: `/var/db/repos/bassdr`
- `metadata/layout.conf`: `masters = gentoo` — inherits all categories/eclasses from gentoo

## Required files per package

Every package directory needs:
- `<pkg>-<ver>.ebuild` — the ebuild itself
- `metadata.xml` — maintainer, upstream links, USE flag descriptions (missing this causes a fatal error at install)
- `Manifest` — generated via `ebuild ... manifest`, never edit manually

## When adding or updating a package

1. Check if it exists in `/var/db/repos/gentoo` first (search by package name across categories):
   ```bash
   find /var/db/repos/gentoo -maxdepth 2 -type d -name "<pkgname>"
   ```
2. If it exists in gentoo with a newer or equal version and no custom patches/flags: **don't add it here**
3. If bassdr has it and gentoo has caught up: delete from bassdr
4. Regenerate Manifest after any ebuild/files change:
   ```bash
   ebuild <path>.ebuild manifest
   ```

## Manifest regeneration

**Must run after every change** to an ebuild or any file in its directory (patches, init scripts, conf files, etc.):

```bash
ebuild <category>/<pkg>/<pkg>-<ver>.ebuild manifest
```

Example:
```bash
ebuild media-video/wireplumber/wireplumber-0.5.13.ebuild manifest
```

The working directory must be the overlay root (`/var/db/repos/bassdr`). Failing to do this causes checksum mismatches at install time.

## Validation

```bash
pkgcheck scan          # QA checks (from dev-util/pkgcheck)
```

## What belongs in this overlay

Packages **not in the gentoo tree at all**, or packages where the bassdr version adds:
- Custom patches not upstream
- Different USE flags
- A version gentoo hasn't picked up yet (short-term)

## Cleanup checklist (done 2026-03-09)

Removed packages superseded by gentoo tree:
- `dev-libs/poco` (1.10.1 → gentoo 1.15.0)
- `dev-util/clion` (2024.1.x → gentoo 2025.3.x)
- `media-libs/xvid` (identical, gentoo's cleaner)
- `media-plugins/alsaequal` (identical, gentoo's cleaner)
- `net-misc/freerdp` (3.8.0 → gentoo 3.23.0)
- `net-print/epson-inkjet-printer-escpr` (1.6.22 → gentoo 1.8.6)
- `sci-calculators/qalculate-qt` + `sci-libs/libqalculate` (5.2.0 → gentoo 5.9.0)
- `sys-kernel/raspberrypi-sources` (gentoo has same + 6.12.x)
