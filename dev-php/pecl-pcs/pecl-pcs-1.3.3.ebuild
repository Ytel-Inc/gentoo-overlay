# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

S="${WORKDIR}/pcs-${PV}"

PHP_EXT_NAME="pcs"
USE_PHP="php7-0"

inherit php-ext-source-r2

DESCRIPTION="PCS provides a fast and easy way to mix C and PHP code in your PHP extension."
HOMEPAGE="http://pcs.tekwire.net/"
SRC_URI="http://pecl.php.net/get/pcs-${PV}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-php/pear-1.10.3"