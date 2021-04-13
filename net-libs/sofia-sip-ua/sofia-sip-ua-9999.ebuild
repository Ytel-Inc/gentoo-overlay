# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3
DESCRIPTION="RFC3261 compliant SIP User-Agent library"
HOMEPAGE="https://packages.gentoo.org/packages/net-libs/sofia-sip"
EGIT_REPO_URI="https://github.com/freeswitch/sofia-sip.git"


LICENSE="LGPL-2.1+ BSD public-domain" # See COPYRIGHT
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~ia64 ppc ~ppc64 sparc x86 ~x86-linux"
IUSE="libressl ssl"
# tests are broken, see bugs 304607 and 330261
RESTRICT="test"

RDEPEND="
	dev-libs/glib:2
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	sh autogen.sh && ./configure.gnu --prefix=/usr --libdir=/usr/lib64
	econf \
		--disable-static \
		$(use_with ssl openssl)
}

src_install() {
	default
	dodoc RELEASE

	# no static archives
	find "${D}" -name '*.la' -delete || die
}
