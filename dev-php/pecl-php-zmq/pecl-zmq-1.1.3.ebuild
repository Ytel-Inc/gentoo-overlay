# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PHP_EXT_NAME="zmq"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"

USE_PHP="php7-0"

inherit php-ext-pecl-r2

DESCRIPTION="ZeroMQ for PHP"
LICENSE="BSD License"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"
DEPEND="dev-libs/php-zmq-driver"
RDEPEND="${DEPEND}"
