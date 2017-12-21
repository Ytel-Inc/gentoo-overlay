# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

IUSE="debug"

inherit eutils flag-o-matic git-2 autotools

EGIT_REPO_URI="https://github.com/Netflix/dynomite.git"
#EGIT_BRANCH="v0.5.9"

DESCRIPTION="Dynomite built by netflix"
HOMEPAGE="https://github.com/Netflix/dynomite"
LICENSE="Apache"
SLOT="0"
KEYWORDS=""

DEPEND="dev-db/redis"

S="${WORKDIR}/dynomite"

src_unpack() {
  git-2_src_unpack
  cd "${S}"
}

src_configure() {
  autoreconf -fvi  || die
  # recreate configure etc.
  econf || die "econf failed"
}

src_compile() {
  emake || die "emake failed"
}

src_install() {
  mkdir -p "${D}"/etc/dynomite
  mkdir -p "${D}"/var/log/dynomite

  default_src_install
  newinitd "${FILESDIR}"/dynomite.initd dynomite || die "newinitd failed"
  newconfd "${FILESDIR}"/dynomite.confd dynomite || die "newconfd failed"

  cp "${FILESDIR}"/dynomite.yml "${D}"/etc/dynomite/
  cp "${FILESDIR}"/recon_key.pem "${D}"/etc/dynomite/
  cp "${FILESDIR}"/recon_iv.pem "${D}"/etc/dynomite/
  cp "${FILESDIR}"/dynomite.pem "${D}"/etc/dynomite/
}
