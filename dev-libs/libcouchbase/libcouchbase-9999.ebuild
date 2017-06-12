# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/couchbase/libcouchbase.git"

inherit git-2 cmake-utils

DESCRIPTION="Couchbase C Client Library"
HOMEPAGE="https://github.com/couchbase/libcouchbase"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~x86"

RDEPEND="dev-libs/libevent
dev-libs/openssl:*"
DEPEND="${RDEPEND}
dev-util/cmake"

src_configure() {
    cmake-utils_src_configure
}

src_install() {
    cmake-utils_src_install
}