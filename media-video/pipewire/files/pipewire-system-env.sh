# /etc/profile.d/pipewire-system.sh
# Installed by media-video/pipewire[system-service] on OpenRC.
# Points PipeWire clients at the system-wide socket instead of a per-user one.
# This prevents gentoo-pipewire-launcher from starting a competing instance.
export PIPEWIRE_RUNTIME_DIR="/run/pipewire"
