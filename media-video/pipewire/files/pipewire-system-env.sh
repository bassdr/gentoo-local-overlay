# /etc/profile.d/pipewire-system.sh
# Installed by media-video/pipewire[system-service] on OpenRC.
# Points PipeWire and PulseAudio clients at the system-wide sockets.
# This prevents gentoo-pipewire-launcher from starting a competing instance.
export PIPEWIRE_RUNTIME_DIR="/run/pipewire"
export PULSE_SERVER="unix:/run/pipewire/pulse/native"
