# bassdr — Personal Gentoo Overlay

Packages not available in the main Gentoo tree.

## Packages

| Package | Description |
|---|---|
| `media-sound/shairport-sync` + acct | AirPlay audio receiver |
| `net-misc/nqptp` + acct | NTP companion daemon for shairport-sync |
| `dev-util/pycharm` | JetBrains PyCharm IDE |
| `dev-util/monodevelop` | Mono/.NET IDE |
| `dev-libs/wt` | C++ web toolkit |
| `dev-libs/mongo-cxx-driver` | MongoDB C++ driver |
| `dev-libs/libclangformat-ide` | libclang-format for IDE integration |
| `dev-libs/properties-cpp` | C++ properties library (Ubuntu/Canonical) |
| `dev-python/openconnect-sso` | OpenConnect SSO authentication helper |
| `media-libs/alac` | Apple Lossless Audio Codec library |
| `media-libs/anttweakbar` | GUI overlay library for OpenGL apps |
| `media-plugins/vdr-vnsiserver` | VDR VNSI server plugin |
| `media-sound/GuitarPro6` | GuitarPro 6 (binary) |
| `media-video/karaokemugen-app` | Karaoke Mugen application |
| `net-misc/omada-sdn-controller` | TP-Link Omada SDN controller (binary) |
| `net-print/epson-inkjet-printer` | Epson inkjet printer driver |
| `app-emulation/anbox` | Android in a Box |
| `app-emulation/playonlinux` | Wine frontend |
| `dev-dotnet/nuget` | NuGet package manager |
| `dev-java/jargs` | Java CLI argument parsing library |
| `dev-java/yuicompressor` | YUI CSS/JS compressor |
| `sys-apps/emerge-update` | Helper script for Portage system updates |

## Usage

```bash
eselect repository add bassdr git https://github.com/bassdr/gentoo-local-overlay.git
emerge --sync bassdr
```
