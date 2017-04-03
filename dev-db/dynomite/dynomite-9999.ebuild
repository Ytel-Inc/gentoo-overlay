# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

IUSE="debug"

inherit eutils flag-o-matic git-2 autotools

EGIT_REPO_URI="https://github.com/Netflix/dynomite.git"
#EGIT_BOOTSTRAP="./autoreconf -fvi"

DESCRIPTION="Dynomite built by netflix"
HOMEPAGE="https://github.com/Netflix/dynomite"
LICENSE="MPL-1.0"
SLOT="0"
KEYWORDS=""

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
  default_src_install
  newinitd "${FILESDIR}"/dynomite.initd dynomite || die "newinitd failed"

  cp ${FILESDIR}/dynomite.yml /etc/dynomite/
}
