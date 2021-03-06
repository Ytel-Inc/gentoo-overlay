# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools base eutils multilib user systemd git-2 flag-o-matic

DESCRIPTION="Janus WebRTC Gateway: Janus is an open source, general purpose, WebRTC gateway designed and developed by Meetecho."
HOMEPAGE="http://janus.conf.meetecho.com/"
EGIT_REPO_URI="https://github.com/meetecho/janus-gateway.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="websockets rabbitmq mqtt debug docs opus ogg data-channels plugin-audiobridge plugin-recordplay plugin-sip plugin-videoroom plugin-voicemail post-processing plugin-videocall plugin-lua sample-event-handler mqtt-event-handler rabbitmq-event-handler"
DEPEND="docs? ( app-doc/doxygen media-gfx/graphviz )
	opus? ( media-libs/opus )
	ogg? ( media-libs/libogg )
	websockets? ( net-libs/libwebsockets dev-util/cmake )
	rabbitmq? ( net-libs/rabbitmq-c )
	mqtt? ( dev-python/paho-mqtt )
	plugin-lua? ( dev-lang/lua )
	data-channels? ( net-libs/usrsctp )
	net-libs/libmicrohttpd
	dev-libs/jansson
	net-libs/libnice[-upnp]
	dev-libs/openssl
	>=net-libs/libsrtp-1.5.2-r1
	net-libs/sofia-sip
	dev-libs/glib
	app-misc/screen
	dev-util/gengetopt
	dev-libs/ding-libs"

# janus-gateway-0.0.9
S="${WORKDIR}/janus-gateway-master"

src_prepare() {
  use debug && epatch "${FILESDIR}/janus_debug.patch"
	./autogen.sh || die "Autogen script failed"
}

src_configure() {
	local vmst

	export PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig"

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
	export PREFIX="/usr"
	MAKEOPTS="-j1" emake
}

src_install() {

  mkdir -p "${D}"/etc/janus
	mkdir -p "${D}"/var/log/janus

  dodir /usr/sbin


  newinitd "${FILESDIR}"/janus-initd janus || die "newinitd failed"
  newconfd "${FILESDIR}"/janus-confd janus || die "newconfd failed"

	emake DESTDIR="${D}" installdirs
	emake DESTDIR="${D}" install


}
