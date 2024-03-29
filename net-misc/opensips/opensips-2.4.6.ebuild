# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$
EAPI=7
inherit eutils

DESCRIPTION="OpenSIPS - flexible and robust SIP (RFC3261) server"
HOMEPAGE="http://www.opensips.org/"
MY_P="${P}"
SRC_URI="http://opensips.org/pub/opensips/${PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="b2bua cpl debug hep httpd ipv6 jabber json load_balancer mysql postgres presence radius registrar redis rest_client siptrace ssl unixodbc xmlrpc"

RDEPEND="
    rest_client? ( net-misc/curl )
    json? ( dev-libs/json-c )
    httpd? ( net-libs/libmicrohttpd )
    b2bua? ( dev-libs/libxml2 )
    presence? ( dev-libs/libxml2 )
    xmlrpc? ( dev-libs/xmlrpc-c[abyss] )
    redis? ( dev-db/redis dev-libs/hiredis )
    mysql? ( dev-db/mysql )
    radius? ( net-dialup/radiusclient-ng )
    postgres? ( dev-db/postgresql )
    jabber? ( dev-libs/expat )
    ssl? ( dev-libs/openssl )
    cpl? ( dev-libs/libxml2 )
    unixodbc? ( dev-libs/unixodbc )"

inc_mod=""
make_options=""

pkg_setup() {
    use load_balancer && \
        inc_mod="${inc_mod} load_balancer"

    use rest_client && \
        inc_mod="${inc_mod} rest_client"

    use json && \
        inc_mod="${inc_mod} json"

    use httpd && \
        inc_mod="${inc_mod} httpd"

    use b2bua && \
        inc_mod="${inc_mod} b2b_entities b2b_logic"

    use presence && \
        inc_mod="${inc_mod} presence presence_dialoginfo presence_mwi presence_xcapdiff presence_xml pua pua_bla pua_dialoginfo pua_mi pua_usrloc pua_xmpp rls xcap_client"

    use mysql && \
        inc_mod="${inc_mod} db_mysql"

    use postgres && \
        inc_mod="${inc_mod} db_postgres"

    use radius && \
        inc_mod="${inc_mod} aaa_radius peering"

    use jabber && \
        inc_mod="${inc_mod} jabber"

    use cpl && \
        inc_mod="${inc_mod} cpl_c"

    use unixodbc && \
        inc_mod="${inc_mod} db_unixodbc"

    use xmlrpc && \
        inc_mod="${inc_mod} mi_xmlrpc_ng"

    use redis && \
        inc_mod="${inc_mod} cachedb_redis"

    use registrar && \
        inc_mod="${inc_mod} mid_registrar signaling tm usrloc"

    use ssl && \
        inc_mod="${inc_mod} tls_mgm proto_tls"

    use hep && \
        inc_mod="${inc_mod} proto_hep"

    use siptrace && \
        inc_mod="${inc_mod} siptrace"

    export inc_mod
}

src_unpack() {
    unpack ${MY_P}.tar.gz

    cd ${S}
    use ipv6
}

src_prepare() {
    epatch "${FILESDIR}/${P}-fs.patch"
	epatch_user
	eapply_user
	eautoreconf
}

src_compile() {
    local compile_options

    pkg_setup

    # optimization can result in strange debuging symbols so omit it in case
    if use debug; then
        compile_options="${compile_options} mode=debug"
    else
        compile_options="${compile_options} CFLAGS=${CFLAGS}"
    fi

    if use ssl; then
        compile_options="TLS=1 ${compile_options}"
    fi

    emake all "${compile_options}" \
        prefix=${ROOT}/ \
        include_modules="${inc_mod}" \
        cfg_prefix=${ROOT}/ \
        cfg_target=${ROOT}/etc/opensips/ || die
}

src_install () {
    local install_options

    emake install \
        prefix=${D}/ \
        include_modules="${inc_mod}" \
        bin_prefix=${D}/usr/sbin \
        bin_dir="" \
        cfg_prefix=${D}/etc \
        cfg_dir=opensips/ \
        cfg_target=${D}/etc/opensips \
        modules_prefix=${D}/usr/lib/opensips \
        modules_dir=modules \
        modules_target=${D}/usr/lib/opensips/modules/ \
        man_prefix=${D}/usr/share/man \
        man_dir="" \
        doc_prefix=${D}/usr/share/doc \
        doc_dir=${PF} || die
    newconfd ${FILESDIR}/opensips.default opensips
    exeinto /etc/init.d
    newexe ${FILESDIR}/opensips.init opensips

    # fix what the Makefile don't do
    use mysql || \
        rm ${D}/usr/sbin/opensips_mysql.sh
}

pkg_postinst() {
    einfo "WARNING: If you upgraded from a previous OpenSIPS version"
    einfo "please read the README, NEWS and INSTALL files in the"
    einfo "documentation directory because the database and the"
    einfo "configuration file of old OpenSIPS versions are incompatible"
    einfo "with the current version."
}

pkg_prerm () {
    ${D}/etc/init.d/opensips stop >/dev/null
}
