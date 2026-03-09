# OpenRC User Services & Lingering

Source: https://wiki.gentoo.org/wiki/OpenRC

## Key Concepts

- **System services**: `/etc/init.d/` — run as root at boot
- **User services**: `/etc/user/init.d/` — run in a user session context
- **User configs**: `/etc/user/conf.d/` (overridable per-user via `${XDG_CONFIG_HOME}/rc/conf.d/`)
- User service state stored in `${XDG_RUNTIME_DIR}/openrc/`

## Lingering

Lingering allows a user's service session to start at boot without that user logging in.

### Setup (as root)

```bash
ln -s /etc/init.d/user /etc/init.d/user.<username>
rc-update add user.<username> default
```

### Enable services for that user (as the user)

```bash
rc-update --user add <service> default
rc-service --user <service> start
rc-status --user
```

## Requirements

- `XDG_RUNTIME_DIR` must be available — provided by `sys-auth/elogind`
- elogind should be in the boot runlevel

---

## PipeWire / WirePlumber on OpenRC

### Option A: Lingering (single-user desktop, simplest)

The Gentoo ebuilds install pipewire/wireplumber to `/etc/user/init.d/`. Use lingering to start them at boot as your own user — no fork needed, no system-service hassle.

```bash
# root
ln -s /etc/init.d/user /etc/init.d/user.alice
rc-update add user.alice default
# alice
rc-update --user add pipewire default
rc-update --user add wireplumber default
```

WirePlumber enumerates ALSA/USB devices via udev. When alice logs in, the session reconnects to the already-running PipeWire.

### Option B: True system service (this overlay's fork)

The bassdr overlay forks `media-video/pipewire` and `media-video/wireplumber` so that `USE=system-service` works on OpenRC (upstream hard-requires systemd for this flag).

**What the fork does differently:**
- Drops `system-service? ( systemd )` from REQUIRED_USE in both ebuilds
- Installs `/etc/init.d/pipewire-system` and `/etc/init.d/wireplumber-system` (run as `acct-user/pipewire`, socket at `/run/pipewire/`)
- **Does NOT install** `gentoo-pipewire-launcher` or `pipewire.desktop` autostart when `system-service` is set (avoids bug #964059 — the autostart would spawn a competing per-user instance on login since it only checks `pgrep -u "${USER}"` and misses the `pipewire`-user process)
- Installs `/etc/profile.d/pipewire-system.sh` which exports `PIPEWIRE_RUNTIME_DIR=/run/pipewire` so user sessions find the system socket

**Enable:**
```bash
# Unmask (upstream mask doesn't apply to this overlay's ebuild, but local package.use.mask may need adjusting)
rc-update add pipewire-system default
rc-update add wireplumber-system default
# Add users to pipewire group
usermod -aG pipewire <youruser>
```

### gentoo-pipewire-launcher conflict (bug #964059)

The launcher checks `pgrep -u "${USER}" -x pipewire|wireplumber`. If pipewire runs as the `pipewire` system user, this check passes (no match) and a second competing instance starts. The autostart `.desktop` file only has `X-GNOME-HiddenUnderSystemd=true` — no OpenRC guard. The fix in the fork: skip installing both when `system-service` is enabled.

### Wiki reference

https://wiki.gentoo.org/wiki/WirePlumber#OpenRC — user services still marked experimental as of late 2025. Recommends `gentoo-pipewire-launcher` for most users.
