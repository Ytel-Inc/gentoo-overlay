# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/datastax/php-driver.git"

inherit git-2 autotools

DESCRIPTION="DataStax PHP Driver for Apache Cassandra"
HOMEPAGE="http://datastax.github.io/cpp-driver/"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="dev-libs/libuv"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf
}

src_install() {
	emake install DESTDIR="${D}" || die
}
