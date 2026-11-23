# bassdr — Personal Gentoo Overlay

Packages not available in the main Gentoo tree, or that diverge from it
(e.g. PipeWire/WirePlumber with OpenRC system-service support).

## Packages

| Package | Description |
|---|---|
| `app-emulation/anbox` | Android in a Box |
| `app-emulation/dxvk-nvapi` | NVAPI for DXVK (DLSS, Reflex), with a prefix setup script |
| `app-emulation/playonlinux` | Wine frontend |
| `dev-dotnet/nuget` | NuGet package manager |
| `dev-java/jargs` | Java CLI argument parsing library |
| `dev-java/yuicompressor` | YUI CSS/JS compressor |
| `dev-libs/libclangformat-ide` | libclang-format for IDE integration |
| `dev-libs/mongo-cxx-driver` | MongoDB C++ driver |
| `dev-libs/properties-cpp` | C++ properties library (Ubuntu/Canonical) |
| `dev-libs/wt` | C++ web toolkit |
| `dev-util/kilo-cli-bin` | Kilo Code CLI (binary), with an OpenRC `kilo-remote` service |
| `dev-util/monodevelop` | Mono/.NET IDE |
| `dev-util/pycharm` | JetBrains PyCharm IDE |
| `media-libs/alac` | Apple Lossless Audio Codec library |
| `media-libs/anttweakbar` | GUI overlay library for OpenGL apps |
| `media-plugins/vdr-vnsiserver` | VDR VNSI server plugin |
| `media-sound/GuitarPro6` | GuitarPro 6 (binary) |
| `media-sound/musescore-soundfont` | MuseScore General SoundFont |
| `media-sound/pipewire-module-spdif-encode` | PipeWire AC3/DTS encoding over S/PDIF and HDMI |
| `media-sound/shairport-sync` + acct | AirPlay audio receiver |
| `media-sound/timidity++` + acct | MIDI synthesizer, with an OpenRC system service |
| `media-video/karaokemugen-app` | Karaoke Mugen application |
| `media-video/pipewire` + acct | PipeWire, with OpenRC system-wide services |
| `media-video/wireplumber` | WirePlumber, with an OpenRC system-wide service |
| `net-misc/nqptp` + acct | NTP companion daemon for shairport-sync |
| `net-misc/omada-sdn-controller` | TP-Link Omada SDN controller (binary) |
| `net-print/epson-inkjet-printer` | Epson inkjet printer driver |
| `sys-apps/emerge-update` | Helper script for Portage system updates |

## Usage

```bash
eselect repository add bassdr git https://github.com/bassdr/gentoo-local-overlay.git
emerge --sync bassdr
```

## Use of generative AI

Parts of this overlay (ebuilds, patches, init scripts, helper scripts) were
written with the help of generative AI tools.

Feel free to reuse anything here. Just be aware that Gentoo
[does not accept AI-assisted contributions](https://wiki.gentoo.org/wiki/Project:Council/AI_policy)
to Gentoo or its official projects (including GURU), so submitting files from
this repository there may go against that policy.
