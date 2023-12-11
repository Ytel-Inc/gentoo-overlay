# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8
inherit autotools multilib systemd git-r3 flag-o-matic

DESCRIPTION="Janus WebRTC Gateway: Janus is an open source, general purpose, WebRTC gateway designed and developed by Meetecho."
HOMEPAGE="http://janus.conf.meetecho.com/"
EGIT_REPO_URI="https://github.com/meetecho/janus-gateway.git"
EGIT_OVERRIDE_BRANCH_MEETECHO_JANUS_GATEWAY="0.x"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="websockets rabbitmq mqtt debug docs opus ogg data-channels plugin-audiobridge plugin-recordplay plugin-sip plugin-videoroom plugin-voicemail post-processing plugin-videocall plugin-lua sample-event-handler mqtt-event-handler rabbitmq-event-handler"
DEPEND="docs? ( app-doc/doxygen media-gfx/graphviz )
	opus? ( media-libs/opus )
	ogg? ( media-libs/libogg )
	websockets? ( net-libs/libwebsockets[ssl] dev-util/cmake )
	rabbitmq? ( net-libs/rabbitmq-c )
	mqtt? ( dev-python/paho-mqtt )
	plugin-lua? ( dev-lang/lua )
	data-channels? ( net-libs/usrsctp )
	net-libs/libmicrohttpd
	dev-libs/jansson
	net-libs/libnice[-upnp]
	dev-libs/openssl
	net-libs/libsrtp:2[openssl]
	net-libs/sofia-sip
	dev-libs/glib
	dev-libs/libconfig
	app-misc/screen
	dev-util/gengetopt
	dev-libs/ding-libs
	virtual/pkgconfig
	sys-libs/zlib
	dev-libs/glib"

# janus-gateway-0.0.9
S="${WORKDIR}/janus-9999"

src_prepare() {
	use debug && epatch "${FILESDIR}/janus_debug.patch"
	./autogen.sh || die "Autogen script failed"
	default
	eautoreconf
}

src_configure() {
#	local vmst

#	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig"

		econf \
			--prefix=/usr \
			$(use_enable websockets) \
			$(use_enable rabbitmq) \
			$(use_enable mqtt) \
			$(use_enable data-channels) \
			$(use_enable rabbitmq-event-handler) \
			$(use_enable sample-event-handler) \
			$(use_enable mqtt-event-handler) \
			$(use_enable plugin-audiobridge) \
			$(use_enable plugin-recordplay) \
			$(use_enable plugin-sip) \
			$(use_enable plugin-videoroom) \
			$(use_enable plugin-voicemail) \
			$(use_enable post-processing) \
			$(use_enable plugin-videocall) \
			$(use_enable plugin-lua) \
			$(use_enable docs)
}

src_compile() {
	default
#	export PREFIX="/usr"
#	MAKEOPTS="-j1" emake
}

src_install() {

	emake DESTDIR="${D}" configs
	default


	newinitd "${FILESDIR}"/janus-initd janus || die "newinitd failed"
	newconfd "${FILESDIR}"/janus-confd janus || die "newconfd failed"


}
