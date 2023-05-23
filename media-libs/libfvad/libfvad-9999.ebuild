# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools eutils flag-o-matic multilib versionator git-r3

DESCRIPTION="Voice activity detection (VAD) library, based on WebRTC's VAD engine"
HOMEPAGE="https://github.com/dpirch/libfvad"
EGIT_REPO_URI="https://github.com/dpirch/libfvad.git"
LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ppc ppc64 ~sparc x86"
IUSE="doc fixed-point cpu_flags_x86_mmx cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 static-libs"

RDEPEND="media-libs/libsndfile"
DEPEND="${RDEPEND}"

# Enabled implicitly by the build system. Really useless.
REQUIRED_USE="
	cpu_flags_x86_sse3? ( cpu_flags_x86_sse2 )
	cpu_flags_x86_sse2? ( cpu_flags_x86_sse )
	cpu_flags_x86_sse? ( cpu_flags_x86_mmx )"

S=${WORKDIR}/${PN}-$(get_version_component_range 1-3)
src_prepare() {
    eapply "${FILESDIR}/${P}-configure.ac.patch"
	eapply_user
	eautoreconf
}

src_configure() {
	#./bootstrap.sh && ./configure.gnu --prefix=/usr --libdir=/usr/lib64 --enable-mmx --enable-sse --enable-sse2
    #autoreconf --install && autoreconf -i && ./configure --prefix=/usr --libdir=/usr/lib64 --enable-mmx --enable-sse --enable-sse2
	econf \
        --prefix=/usr \
		--libdir=/usr/lib64 \
		$(use_enable doc) \
		$(use_enable fixed-point) \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable cpu_flags_x86_sse2 sse2) \
		$(use_enable cpu_flags_x86_sse3 sse3) \
		$(use_enable static-libs static)

}

src_install() {
	emake DESTDIR="${D}" install
	#dodoc AUTHORS ChangeLog DueDiligence NEWS README

	if ! use static-libs; then
		# remove useless la file when not installing static lib
		find "${ED}" -name '*.la' -delete || die
	fi

}
