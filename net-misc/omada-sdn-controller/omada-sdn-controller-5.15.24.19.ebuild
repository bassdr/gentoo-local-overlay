EAPI=8

inherit java-pkg-2

DESCRIPTION="TP-Link Omada SDN Controller"
HOMEPAGE="https://www.omadanetworks.com"
SRC_URI="https://static.tp-link.com/upload/software/2025/202508/20250802/Omada_SDN_Controller_v${PV}_linux_x64_20250724152611.tar.gz -> ${P}.tar.gz"
LICENSE="proprietary"

SLOT="0"
KEYWORDS="amd64 arm64"

RDEPEND="dev-java/commons-daemon
	dev-db/mongodb
	net-misc/curl"
#>=dev-java/openjdk-17

S="${WORKDIR}/Omada_SDN_Controller_v5.15.24.19_linux_x64/"
