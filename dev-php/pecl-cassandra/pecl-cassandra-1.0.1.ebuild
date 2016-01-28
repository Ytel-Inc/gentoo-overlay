# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PHP_EXT_NAME="cassandra"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"

USE_PHP="php5-4 php5-5 php5-6"

inherit php-ext-pecl-r2

DESCRIPTION="DataStax PHP Driver for Apache Cassandra"
LICENSE="Apache License 2.0"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"
DEPEND="dev-libs/cpp-driver"
RDEPEND="${DEPEND}"
