# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3 cmake

#PKG_CONFIG_PATH="/usr/lib64/pkgconfig"
DESCRIPTION="Signalwire libks"
HOMEPAGE="https://github.com/signalwire/libks"
EGIT_REPO_URI="https://github.com/signalwire/libks.git"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	cmake_src_prepare
}

src_compile() {
	cd "${S}"
	cmake .
}

src_install() {
	cd "${S}"
	make
}

pkg_postinst() {
	cd "${S}"
	make install
}

