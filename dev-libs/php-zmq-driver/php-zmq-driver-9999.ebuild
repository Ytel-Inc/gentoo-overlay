# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/mkoppanen/php-zmq.git"

inherit git-2 cmake-utils

DESCRIPTION="ZeroMQ for PHP"
HOMEPAGE="http://pecl.php.net/zmq/"
SRC_URI=""

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
    cmake-utils_src_configure
}

src_install() {
    cmake-utils_src_install
}
