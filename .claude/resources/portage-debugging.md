# Portage Debugging Commands

Commands tried in practice — noting what works, what fails, and why.

## Checking which repo portage picks for a package

```bash
# Works — shows version + repo in verbose output
emerge -pv media-video/pipewire

# Works — force a specific repo and see if portage accepts it
# This is the most useful diagnostic: if bassdr version is ignored, try forcing it
# and read the actual error
emerge -pv "=media-video/pipewire-1.6.0::bassdr"
```

**Does NOT work:**
```bash
portageq best_visible / media-video/pipewire   # shows version but not the repo
equery list -ao media-video/pipewire           # wrong syntax, equery list needs -p/-o flag differently
```

## Checking all visible ebuilds from all repos

```bash
python3 -c "
import portage
t = portage.db[portage.root]['porttree'].dbapi
for cpv in t.match('media-video/pipewire'):
    repo = t.aux_get(cpv, ['repository'])[0]
    print(cpv, repo)
"
```

Note: if the same package appears twice from the same repo, the portage metadata
cache is stale. Clear it and regenerate:

```bash
rm /var/cache/edb/dep/var/db/repos/bassdr/media-video/<pkg>-<ver>
egencache --update --repo=bassdr --jobs=$(nproc)
```

`egencache` may print errors for unrelated broken ebuilds (e.g. qupzilla) — those
can be ignored.

## Ebuild commands

```bash
# Works
ebuild <path>.ebuild manifest     # regenerate Manifest
ebuild <path>.ebuild pretend      # runs pkg_pretend (produces no output if empty — that's normal)
ebuild <path>.ebuild fetch        # download sources

# Does NOT work
ebuild <path>.ebuild metadata     # 'metadata' is not a valid ebuild command
```

Valid ebuild commands: clean, compile, config, configure, digest, fetch, fetchall,
help, info, install, manifest, merge, nofetch, package, postinst, postrm, preinst,
prepare, prerm, pretend, qmerge, setup, test, unmerge, unpack.

## Repo config and priorities

```bash
portageq repos_config /    # shows all repos, their paths and priorities
```

Overlay repos default to priority 0. The gentoo main tree has priority -1000.
Higher priority wins for the same package+version.

## Package masks

```bash
grep -r "pipewire" /etc/portage/package.mask/ 2>/dev/null
grep -r "pipewire" /etc/portage/package.mask  2>/dev/null
```

USE flag masks (like `system-service`) live in the gentoo tree:
`/var/db/repos/gentoo/profiles/base/package.use.mask`
These apply to overlay ebuilds too (via masters inheritance).

## Silent portage backtracking

Portage silently falls back to a lower-priority repo when the overlay ebuild
fails dependency resolution — **no error is shown to the user**.

To diagnose: force the overlay version explicitly:
```bash
emerge -pv "=category/package-version::bassdr"
```
This will reveal the actual dependency error (e.g. wrong package category in RDEPEND).

Common mistake: copy-pasting RDEPEND from a different ebuild version where a
package moved categories (e.g. `media-libs/liblc3` vs `media-sound/liblc3`).

## OpenRC service commands

```bash
rc-service <name> status    # check if running
rc-service <name> start
rc-update add <name> default
rc-status                   # list all services and their state
```

Note: `/etc/init.d/` files must be owned by root and executable. When installing
init scripts manually (outside of emerge), use sudo:
```bash
sudo cp files/foo.initd /etc/init.d/foo
sudo chmod +x /etc/init.d/foo
```

## pactl / PulseAudio client debugging

```bash
# Test with explicit socket path (bypasses profile.d env)
PULSE_SERVER=unix:/run/pipewire/pulse/native pactl stat

# If that works but bare `pactl stat` fails:
# → PULSE_SERVER is not set in the current shell
# → Source profile.d or start a new login shell
source /etc/profile.d/pipewire-system.sh
```

PipeWire creates `$XDG_RUNTIME_DIR/pulse/` with mode `700` (owner only).
Users in the `pipewire` group need `chmod 750` on that directory to traverse it,
even though the `native` socket itself is `777`. Fix in init script `start_post`.
