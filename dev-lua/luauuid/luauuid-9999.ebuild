
# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit git-r3
LUAVERSION="5.4"
#PKG_CONFIG_PATH="/usr/lib64/pkgconfig"
DESCRIPTION="Lua UUID Generator"
HOMEPAGE="https://github.com/arcapos/luauuid/"
EGIT_REPO_URI="https://github.com/arcapos/luauuid.git"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="sys-apps/util-linux"

src_prepare() {
	eapply_user
	eapply "${FILESDIR}/${P}-configure.patch"
}

src_configure() {
	true
}

src_compile() {
	gcc `pkg-config lua${LUAVERSION} --cflags` -luuid `pkg-config lua${LUAVERSION} --libs` -fPIC -shared -Wall -o ${PORTAGE_BUILDDIR}/work/luauuid-9999/lua_uuid.so ${PORTAGE_BUILDDIR}/work/luauuid-9999/luauuid.c

}

src_install() {
	true
}

pkg_postinst() {
	cp ${PORTAGE_BUILDDIR}/work/luauuid-9999/lua_uuid.so /usr/share/lua/${LUAVERSION}/lib/lua/${LUAVERSION}/lua_uuid.so
}
