# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
WANT_AUTOMAKE=none

inherit autotools flag-o-matic ssl-cert user

DESCRIPTION="Powerful SMS and WAP gateway"
HOMEPAGE="http://www.kannel.org/"
#SRC_URI="http://www.kannel.org/download/${PV}/gateway-${PV}.tar.gz"
SRC_URI="https://mirrors.ytel.com/portage/app-mobilephone/kannel/kannel-snapshot.tar.gz"

LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc mysql libressl pam pcre postgres sqlite ssl redis opensmppbox"

RESTRICT="test" # some tests fail with "address already in use"

RDEPEND="
	sys-libs/e2fsprogs-libs
	dev-libs/libxml2:2
	dev-lang/perl
	sys-libs/zlib
	ssl? (
		libressl? ( dev-libs/libressl:0= )
		!libressl? ( dev-libs/openssl:0= ) )
	mysql? ( virtual/mysql )
	sqlite? ( dev-db/sqlite:3 )
	postgres? ( dev-db/postgresql:=[server] )
	pcre? ( dev-libs/libpcre:3 )
	pam? ( virtual/pam )
	redis? ( dev-libs/hiredis )
"
DEPEND="${RDEPEND}
	>=sys-devel/bison-2.2
	doc? ( media-gfx/transfig
		app-text/jadetex
		app-text/docbook-dsssl-stylesheets
		app-text/docbook-sgml-dtd:3.1 )
"

S="${WORKDIR}/kannel-snapshot"

PATCHES=(
	"${FILESDIR}/${PN}-1.5.0-custom-wap-ports.patch"
	"${FILESDIR}/${PN}-1.4.3-autotools.patch"
)

pkg_setup() {
	enewgroup kannel
	enewuser kannel -1 -1 /var/log/kannel kannel
}

src_prepare() {
	default

	#by default, use current directory for logging
	sed -i -e 's:/tmp/::' doc/examples/kannel.conf

	mv configure.in configure.ac || die
	eautoconf
}

src_configure() {
	append-flags -fno-strict-aliasing # some code breaks strict aliasing
	econf \
		--enable-localtime \
		--disable-start-stop-daemon \
		--without-sqlite2 \
		$(use_enable pam) \
		$(use_enable debug debug) \
		$(use_enable pcre) \
		$(use_enable doc docs) \
		$(use_enable ssl) \
		$(use_with mysql) \
		$(use_with sqlite sqlite3) \
		$(use_with postgres pgsql) \
		$(use_with redis redis)


	# do opensmppbox
	if use opensmppbox; then
		pushd "${S}/addons/opensmppbox"
		einfo "Configuring OpenSMPPbox..."
		econf
		popd
	fi
}

# phase disabled by RESTRICT
# src_test() {
# 	emake check || die "emake check failed"
# }

src_install() {
	default

	if use doc; then
		emake -j1 DESTDIR="${D}" install-docs || die "emake install-docs failed"
	fi

	# do opensmppbox
	if use opensmppbox; then
		einfo "Building OpenSMPPbox..."
		emake -C addons/opensmppbox DESTDIR="${D}" install
	fi

	diropts -g kannel -m0750
	dodir /etc/kannel
	insinto /etc/kannel
	newins doc/examples/kannel.conf kannel.conf.sample

	local f
	for f in bearerbox smsbox wapbox; do
		newinitd "${FILESDIR}/kannel-$f.initd" kannel-$f
	done

	# do opensmppbox config
	if use opensmppbox; then
		einfo "Building OpenSMPPbox..."
		newinitd "${FILESDIR}/kannel-opensmppbox.initd" kannel-opensmppbox
	fi


	diropts -g kannel -m0770
	keepdir /var/log/kannel
}

pkg_postinst() {
	if use ssl; then
		elog "SSL certificate can be created by running"
		elog "   emerge --config =${CATEGORY}/${PF}"
	fi
}

pkg_config() {
	if use ssl; then
		if install_cert /etc/ssl/kannel; then
			chown kannel "${ROOT}"etc/ssl/kannel.{pem,key}
			einfo "For using this certificate, you have to add following line to your kannel.conf:"
			einfo '   ssl-client-certkey-file = "/etc/ssl/kannel.pem"'
			einfo '   ssl-server-cert-file = "/etc/ssl/kannel.crt"'
			einfo '   ssl-server-key-file = "/etc/ssl/kannel.key"'
		fi
	else
		eerror "This phase exists only for creating kannel SSL certificate"
		eerror "and ssl USE flag is disabled for this package!"
	fi
}
