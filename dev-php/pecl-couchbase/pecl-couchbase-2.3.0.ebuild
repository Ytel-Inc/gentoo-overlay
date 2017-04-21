# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

S="${WORKDIR}/couchbase-${PV}"

PHP_EXT_NAME="couchbase"
USE_PHP="php7-0"

inherit php-ext-source-r2

DESCRIPTION="The PHP client library provides fast access to documents stored in a Couchbase Server."
HOMEPAGE="https://developer.couchbase.com/server/other-products/release-notes-archives/php-sdk"
SRC_URI="http://pecl.php.net/get/couchbase-${PV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="igbinary"

DEPEND=">=dev-libs/libcouchbase-9999
        >=dev-php/igbinary-2.0.1
        >=dev-php/pecl-pcs-1.3.3"