# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

PHP_EXT_NAME="couchbase"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"

USE_PHP="php5-5 php7-0"

inherit php-ext-pecl-r3

KEYWORDS="~amd64"

DESCRIPTION="The PHP client library provides fast access to documents stored in a Couchbase Server."
LICENSE="PHP-3.01"
SLOT="0"
IUSE="igbinary"

DEPEND="igbinary? ( dev-php/igbinary )
        >=dev-php/pecl-pcs-1.3.3"
RDEPEND="$DEPEND"

S="${WORKDIR}/${MY_P}"

src_configure() {
    local PHP_EXT_ECONF_ARGS=(
        --with-couchbase
    )
    php-ext-source-r3_src_configure
}

