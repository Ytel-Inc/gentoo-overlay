# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id:$

EAPI=8
PYTHON_COMPAT=( python{3_10,3_11} )
PYTHON_REQ_USE='threads(+)'

inherit autotools flag-o-matic python-any-r1 java-pkg-opt-2

append-cppflags -Wno-array-parameter -Wno-error=deprecated-declarations -Wno-error=array-bounds

DESCRIPTION="FreeSWITCH telephony platform"
HOMEPAGE="http://www.freeswitch.org/"

KEYWORDS="~amd64 ~x86"
LICENSE="MPL-1.1"
SLOT="0"
S="/var/tmp/portage/net-voip/${P}/work/${P}.-release"
SRC_URI="http://files.freeswitch.org/releases/freeswitch/${P}.-release.tar.xz"
# No idea what USE=libedit is actually good for
IUSE="esl libedit odbc +resampler sctp +zrtp debug ffmpeg"

LIBVVAR="lib64"

LANGS="de en es es_ar fa fr he hr hu it ja nl pl pt ru sv th zh"

FREETDM_MODULES="
	libpri misdn r2 sng_isdn sng_ss7 wanpipe
"

ESL="perl python lua java managed"

# TODO: Add support for mod_bert
FM_APPLICATIONS="
	abstraction avmd blacklist callcenter cidlookup cluechoo
	+commands +conference curl +db directory distributor +dptools
	easyroute +enum +esf esl +expr +fifo fsk fsv +hash +httapi
	http_cache ladspa lcr +limit memcache mongo nibblebill
	osp rad_auth random redis rss skel +sms snapshot
	snom soundtouch +spandsp spy stress +valet_parking vmd
	+voicemail voicemail_ivr amd ruby vm ytel_dial av
"
FM_TTS="
	cepstral flite pocketsphinx tts_commandline
"
FM_CODECS="
	+amr amrwb +bv codec2 com_g729 dahdi_codec +g723_1 +g729
	+h26x +ilbc isac mp4v +opus sangoma_codec silk siren skel_codec
	theora
"
FM_DIALPLANS="
	dialplan_asterisk +dialplan_directory +dialplan_xml
"
FM_DIRECTORIES="
	ldap
"
FM_ENDPOINTS="
	alsa freetdm gsmopen h323 khomp +loopback opal
	portaudio reference rtc rtmp skinny skypopen +sofia unicall verto signalwire
"
FM_EVENT_HANDLERS="
	+cdr_csv cdr_mongodb cdr_pg_csv cdr_sqlite erlang_event
	event_multicast +event_socket event_test event_zmq json_cdr
	radius_cdr snmp
"
FM_FORMATS="
	+local_stream +native_file png portaudio_stream shell_stream
	shout +sndfile +tone_stream vlc
"
FM_LANGUAGES="
	java lua managed perl python yaml
"
FM_LOGGERS="
	+console +logfile +syslog
"
FM_TIMERS="
	posix_timer timerfd
"
FM_XML="
	xml_cdr xml_curl xml_ldap xml_rpc xml_scgi
"
FM_EXTERNAL="
	ssh
"
FM="
	${FM_APPLICATIONS}
	${FM_TTS}
	${FM_CODECS}
	${FM_DIALPLANS}
	${FM_DIRECTORIES}
	${FM_ENDPOINTS}
	${FM_EVENT_HANDLERS}
	${FM_FORMATS}
	${FM_LANGUAGES}
	${FM_LOGGERS}
	${FM_TIMERS}
	${FM_XML}
"

FM_BROKEN=""

#? mod_mp4 -> want mp4.h (which was in older versions of libmp4v2

REQUIRED_USE="
	|| ( linguas_de linguas_en linguas_es linguas_fa linguas_fr linguas_he linguas_hr linguas_hu linguas_it linguas_ja linguas_nl linguas_pt linguas_ru linguas_th linguas_zh )
	esl? ( freeswitch_modules_esl )
	freeswitch_modules_esl? ( esl )
	freeswitch_modules_limit? ( freeswitch_modules_db freeswitch_modules_hash )
	freeswitch_modules_nibblebill? ( odbc )
	freeswitch_modules_easyroute? ( odbc )
	freeswitch_modules_lcr? ( odbc )
	freeswitch_modules_gsmopen? ( freeswitch_modules_spandsp )
	freeswitch_modules_portaudio_stream? ( freeswitch_modules_portaudio )
	freeswitch_modules_freetdm? ( freetdm_modules_libpri )
	freeswitch_modules_verto? ( freeswitch_modules_rtc )
	freetdm_modules_libpri? ( freeswitch_modules_freetdm )
	freetdm_modules_misdn? ( freeswitch_modules_freetdm )
	freetdm_modules_r2? ( freeswitch_modules_freetdm )
	freetdm_modules_sng_isdn? ( freeswitch_modules_freetdm )
	freetdm_modules_sng_ss7? ( freeswitch_modules_freetdm )
	freetdm_modules_wanpipe? ( freeswitch_modules_freetdm )
"

# Though speex is obsolete (see https://wiki.freeswitch.org/wiki/Mod_speex), configure fails without it
RDEPEND="virtual/libc
	dev-lua/luauuid
	dev-lang/yasm
	media-libs/libvpx
	net-analyzer/fping
	media-libs/libpng
	net-libs/libsrtp
	!dev-lang/nasm
	>=media-libs/speex-1.2_rc1
	media-libs/speexdsp
	libedit? ( dev-libs/libedit )
	odbc? ( dev-db/unixODBC )
	esl_java? ( >=dev-java/openjdk-bin-8:* )
	esl_lua? ( || ( dev-lang/lua dev-lang/luajit:2 ) )
	esl_managed? ( >=dev-lang/mono-1.9 )
	esl_perl? ( dev-lang/perl )
	esl_python? ( dev-lang/python )
	ffmpeg? ( media-video/ffmpeg dev-libs/apr-util dev-libs/apr dev-libs/libvformat )
	freeswitch_modules_alsa? ( media-libs/alsa-lib )
	freeswitch_modules_radius_cdr? ( net-dialup/freeradius-client )
	freeswitch_modules_xml_curl? ( net-misc/curl )
	freeswitch_modules_enum? ( >=net-libs/ldns-1.6.6 )
	freeswitch_modules_xml_ldap? ( net-nds/openldap )
	freeswitch_modules_ldap? ( net-nds/openldap )
	freeswitch_modules_java? ( >=dev-java/openjdk-bin-8:* )
	freeswitch_modules_h323? ( || ( net-libs/openh323 net-libs/ptlib ) )
	freeswitch_modules_opal? ( net-libs/opal[h323,iax] )
	freeswitch_modules_opus? ( media-libs/opus )
	freeswitch_modules_osp? ( >=net-libs/osptoolkit-4.0.3 )
	freeswitch_modules_perl? ( dev-lang/perl[ithreads] )
	freeswitch_modules_python? ( dev-lang/python )
	freeswitch_modules_managed? ( >=dev-lang/mono-1.9 )
	freeswitch_modules_sndfile? ( media-libs/libsndfile )
	freeswitch_modules_sofia? ( net-libs/sofia-sip-ua )
	freeswitch_modules_soundtouch? ( media-libs/libsoundtouch )
	freeswitch_modules_skypopen? ( x11-base/xorg-server x11-apps/xhost net-im/skype media-fonts/font-misc-misc media-fonts/font-cursor-misc )
	freeswitch_modules_memcache? ( net-misc/memcached )
	freeswitch_modules_erlang_event? ( dev-lang/erlang )
	freeswitch_modules_shout? ( media-libs/libogg >=media-sound/mpg123-1.20 media-libs/libshout media-sound/lame )
	freeswitch_modules_spandsp? ( virtual/jpeg media-libs/libjpeg-turbo media-libs/spandsp3 )
	freeswitch_modules_redis? ( dev-db/redis )
	freeswitch_modules_cdr_pg_csv? ( dev-db/postgresql )
	freeswitch_modules_gsmopen? ( net-libs/ctb[-gpib] app-mobilephone/gsmlib )
	freeswitch_modules_xml_ldap? ( net-nds/openldap[sasl] )
	freeswitch_modules_ladspa? ( media-libs/ladspa-sdk )
	freeswitch_modules_freetdm? (
	freetdm_modules_misdn? ( >=net-dialup/misdnuser-2.0.0 )
	freetdm_modules_libpri? ( >=net-libs/libpri-1.4.0 )
	freetdm_modules_wanpipe? ( net-misc/wanpipe )
	freetdm_modules_sng_isdn? ( net-libs/libsng-isdn )
	freetdm_modules_sng_ss7? ( net-libs/libsng-ss7 )
	freetdm_modules_r2? ( net-misc/openr2 )
	)
"
#	freeswitch_modules_mp4? ( media-libs/libmp4v2 )

DEPEND="${RDEPEND}
	>=dev-build/autoconf-2.71-r6
	>=dev-build/automake-1.16.5-r2
	virtual/pkgconfig
	=dev-lang/lua-5.4*
	dev-db/sqlite
	media-sound/sox
	media-libs/tiff
	sctp? ( kernel_linux? ( net-misc/lksctp-tools ) )
	esl_java? ( >=dev-java/openjdk-bin-8:* >=dev-lang/swig-4.0.0 )
	esl_lua? ( dev-lang/lua >=dev-lang/swig-4.0.0 )
	esl_managed? ( >=dev-lang/swig-4.0.0 )
	esl_perl? ( >=dev-lang/swig-4.0.0 )
	esl_python? ( >=dev-lang/swig-4.0.0 )
	freeswitch_modules_java? ( >=dev-java/openjdk-bin-8:* )
"

PDEPEND="media-sound/freeswitch-sounds
	media-sound/freeswitch-sounds-music
	freeswitch_modules_ssh? ( net-voip/freeswitch-mod_ssh )
"

# patches
#PATCHES=(
#	"${FILESDIR}/${P}-configure.ac.patch"
#)


for x in ${FM} ${FM_EXTERNAL}; do
	IUSE="${IUSE} ${x//[^+]/}freeswitch_modules_${x/+}"
done

for x in ${FREETDM_MODULES}; do
	IUSE="${IUSE} ${x//[^+]/}freetdm_modules_${x/+}"
done
for x in ${ESL}; do
	IUSE="${IUSE} esl_${x}"
done
for x in ${LANGS}; do
	IUSE="${IUSE} linguas_${x}"
done
for x in ${FM_BROKEN}; do
	IUSE="${IUSE//${x}}"
done

FREESWITCH_USER=${FREESWITCH_USER:-freeswitch}
FREESWITCH_GROUP=${FREESWITCH_GROUP:-freeswitch}

pkg_pretend() {
	if use freeswitch_modules_h323; then
		ewarn "You're about to using mod_h323, which depends on "
		ewarn "'dead' openh323 library. We're suggest you to use mod_opal instead."
		if has_version net-libs/ptlib; then
			die "Can't use mod_h323 with net-libs/ptlib. Please, use mod_opal instead."
		fi
	fi
}

pkg_setup() {
	if use freeswitch_modules_cepstral; then
		SWIFT_HOME="${SWIFT_HOME:-/opt/swift}"

		if [ ! -d "${SWIFT_HOME}" ]; then
			eerror "No cepstral installation found in \"${SWIFT_HOME}\""
			eerror 'Try to set SWIFT_HOME="/path/to/swift_tts_engine" in your make.conf'
			die "No cepstral installation found in \"${SWIFT_HOME}\""
		fi

		if [ ! -e "${SWIFT_HOME}/lib/libswift.so" ]; then
			eerror "Cepstral library not found in \"${SWIFT_HOME}\""
			die "Cepstral library not found!"
		fi

		einfo "Cepstral installation found in \"${SWIFT_HOME}\""

		export SWIFT_HOME
	fi
	python-any-r1_pkg_setup
	enewgroup "${FREESWITCH_GROUP}"
	enewuser "${FREESWITCH_USER}" -1 -1 "/var/lib/${PN}" "${FREESWITCH_GROUP}"
}

fs_set_module() {
	local config="modules.conf"
	local mod="$2"

	case ${mod} in
	mod_freetdm)
		category="../../libs/freetdm"
		;;
	*)
		category="$(ls -d src/mod/*/${mod} | cut -d'/' -f3)"
		;;
	esac

	[ -z "${category}" ] && {
		die "Unable to determine category for module \"${mod}\"."
	}

	case $1 in
	enable)
		einfo "  ++ Enabling ${mod}"
		echo "${category}/${mod}" >> "${config}"
		;;

	disable)
		einfo "  -- Disabling ${mod}"
		echo "#${category}/${mod}" >> "${config}"
		;;
	*)
		eerror "fs_set_module <enable|disable> <module_path>"
		return 1
		;;
	esac

	return 0
}

setup_modules() {
	local x mod action

	[ -f "modules.conf" ] && {
		rm -f "modules.conf" || die "Failed to remove existing modules.conf"
	}
	einfo "Setting up modules"
	for x in ${FM}; do
		mod="${x/+}"
		action="enable"

		[ -n "${mod}" ] && {
			use freeswitch_modules_${mod} || action="disable"
			fs_set_module "${action}" "mod_${mod}"
		}
	done

	einfo "Language modules:"
	for x in ${LANGS}; do
		mod="${x/+}"
		action="enable"

		[ -n "${mod}" ] && {
			use linguas_${mod} || action="disable"
			fs_set_module "${action}" "mod_say_${mod}"
		}
	done
}

esl_modname() {
	[ -z "$1" ] && return 1
	case "$1" in
	"python")
		echo "pymod"
		;;
	*)
		echo "${1#*-}mod"
		;;
	esac
	return 0
}

esl_dopymod() {
	(
		insinto $(python_get_sitedir)

		for x in ${@}; do
			insopts -m644

			[ "${x}" != "${x%.so}" ] && insopts -m755

			doins "${x}" || die "failed to install ${x}"
		done
	) || die "failed to install $@"
}

esl_doluamod() {
	(
		insinto $(pkg-config lua --variable INSTALL_CMOD)
		insopts -m755
		doins "$@"
	) || die "failed to install $@"
}

esl_doperlmod() {
	(
		eval "$(${PERL:-/usr/bin/perl} -V:installvendorarch)"
		eval "$(${PERL:-/usr/bin/perl} -V:installvendorlib)"

		for x in ${@}; do
			target="lib"

			[ "${x}" != "${x%.so}" ] && target="arch"

			case "${target}" in
			"lib")
				insinto "${installvendorlib}"
				insopts -m644
				doins -r "${x}" || die "failed to install ${x}"
				;;
			"arch")
				insinto "${installvendorarch}"
				insopts -m755
				doins "${x}" || die "failed to install ${x}"
				;;
			esac
		done
	) || die "failed to install $@"
}

src_prepare() {
	default
#	eapply "${FILESDIR}/${P}-gcc-11.patch"
	eapply "${FILESDIR}/${P}-configure.ac.patch"
	eapply "${FILESDIR}/${P}-no-werror.patch"
	eautoconf
	eautomake
	patch -p1 < /ytel/repos/gentoo-overlay/net-voip/freeswitch/files/freeswitch-1.10.8-configbug.patch

	einfo
	einfo "Adding AMD module"
	einfo
	cp -R "${FILESDIR}/AMD" "${S}/src/mod/applications/mod_amd"
	einfo
	einfo "Adding Ruby module"
	einfo
	cp -R "${FILESDIR}/RUBY" "${S}/src/mod/applications/mod_ruby"
	einfo
	einfo "Adding VM module"
	einfo
	cp -R "${FILESDIR}/VM" "${S}/src/mod/applications/mod_vm"
	einfo
	einfo "Adding ytel_dial module"
	einfo
	cp -R "${FILESDIR}/YTEL_DIAL" "${S}/src/mod/applications/mod_ytel_dial"
	setup_modules

}

src_configure() {
	local java_opts config_opts
	use freeswitch_modules_java && \
		java_opts="--with-java=$(/usr/bin/java-config -O)"
	use freetdm_modules_libpri && \
		config_opts="--with-libpri"
	use freetdm_modules_misdn && \
		config_opts="--with-misdn"

	use debug || config_opts="${config_opts} --disable-debug"

	if use debug; then
		export CFLAGS="-g -ggdb"
		export MOD_CFLAGS="-g -ggdb"
	fi



	einfo "Configuring FreeSWITCH..."
		touch noreg
		FREESWITCH_HTDOCS="${FREESWITCH_HTDOCS:-/var/www/localhost/htdocs/${PN}}"
		econf \
		--disable-option-checking \
		${CTARGET:+--target=${CTARGET}} \
		$(use_enable libedit core-libedit-support) \
		--localstatedir="/var" \
		--sysconfdir="/etc" \
		--with-modinstdir="/usr/$(get_libdir)/${PN}/mod" \
		--with-rundir="/var/run/${PN}" \
		--with-logfiledir="/var/log/${PN}" \
		--with-dbdir="/var/lib/${PN}/db" \
		--with-htdocsdir="/usr/share/${PN}/htdocs" \
		--with-soundsdir="/usr/share/${PN}/sounds" \
		--with-grammardir="/usr/share/${PN}/grammar" \
		--with-scriptdir="/usr/share/${PN}/scripts" \
		--with-recordingsdir="/var/lib/${PN}/recordings" \
		--with-pkgconfigdir="/usr/$(get_libdir)/pkgconfig" \
		$(use_enable sctp) \
		$(use_enable zrtp) \
		$(use_with freeswitch_modules_python python "${PYTHON}") \
		$(use_enable resampler resample) \
		$(use_enable odbc core-odbc-support) \
		${java_opts} ${config_opts} || die "failed to configure FreeSWITCH"

	if use freeswitch_modules_freetdm; then
		pushd "${S}/libs/freetdm"
		einfo "Configuring FreeTDM..."
		econf \
			--with-modinstdir="/usr/$(get_libdir)/${PN}/mod" \
			--with-pkgconfigdir=/usr/$(get_libdir)/pkgconfig \
			${config_opts} || die "failed to configure FreeTDM"
		popd
	fi
}

src_compile() {
	local esl_lang

	if use freeswitch_modules_freetdm; then
#	# breaks freetdm:
#	filter-flags -fvisibility-inlines-hidden
		einfo "Building FreeTDM..."
		emake -C libs/freetdm || die "failed to build FreeTDM"
	fi
	einfo "Building FreeSWITCH... (this can take a long time)"
	emake MONO_SHARED_DIR="${T}" || die "failed to build FreeSWITCH"
	for esl_lang in ${ESL}; do
		use esl_${esl_lang} || continue

		esl_lang="${esl_lang#*_}"

		einfo "Building esl module for ${esl_lang}..."
		emake -C libs/esl/"${esl_lang}" reswig || die "Failed to reswig esl module for language \"${esl_lang}\""
		emake -C libs/esl "$(esl_modname ${esl_lang})" || die "Failed to build esl module for language \"${esl_lang}\""
	done
	if use esl; then
		einfo "Building libesl..."
		emake -C libs/esl || die "Failed to build libesl"
	fi
}

src_install() {
	local esl_lang
	einfo "Installing freeswitch core and modules..."
	emake install DESTDIR="${D}" MONO_SHARED_DIR="${T}" || die "Installation of freeswitch core failed"
	einfo "Installing documentation and misc files..."
	dodoc AUTHORS NEWS README ChangeLog INSTALL

	insinto "/usr/share/${PN}/scripts/rss"
	doins scripts/rss/rss2ivr.pl

	keepdir /var/lib/"${PN}"/{cores,storage}

	newinitd "${FILESDIR}"/freeswitch.initd freeswitch
	newconfd "${FILESDIR}"/freeswitch.confd freeswitch

	use freeswitch_modules_managed && keepdir "/usr/$(get_libdir)/${PN}/mod/managed"
#	# TODO: install contributed stuff

	if use freeswitch_modules_skypopen ; then
		docinto skypopen
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/README"
		dodoc   "${S}/src/mod/endpoints/mod_skypopen/configs/"*
	fi

	find "${ED}" -name "*.la" -delete || die "Failed to cleanup .la files"

	if use esl_python; then
		einfo "Installing esl module for python..."
		esl_dopymod libs/esl/python/{_ESL.so,ESL.py}
	fi

	if use esl_lua; then
		einfo "Installing esl module for lua..."
		esl_doluamod libs/esl/lua/ESL.so
	fi

	if use esl_perl; then
		einfo "Installing esl module for perl..."
		esl_doperlmod libs/esl/perl/{ESL,ESL.so,ESL.pm}
	fi

	if use esl_java; then
		einfo "Installing esl module for java..."
		java-pkg_dojar libs/esl/java/esl.jar
		java-pkg_doso libs/esl/java/libesljni.so
	fi

	if use esl_managed; then
		einfo "Installing esl module for Mono..."
		insinto "/usr/$(get_libdir)/${PN}/mod/managed"
		doins libs/esl/managed/ESL.so
	fi

	if use esl; then
		einfo "Installing libesl..."
		insinto "/usr/$(get_libdir)"
		doins libs/esl/.libs/libesl.a
	fi

	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/etc/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/usr/$(get_libdir)/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/run/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/log/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/usr/share/${PN}"
	fowners -Rf ${FREESWITCH_USER}:${FREESWITCH_GROUP} "/var/lib/${PN}"
}

pkg_postinst() {

	einfo
	einfo "FreeSWITCH has been successfully emerged!"
	einfo
	einfo "More information about FreeSWITCH and how to configure it"
	einfo "can be found on one of these sites:"
	einfo
	einfo "    http://www.freeswitch.org/"
	einfo "    http://wiki.freeswitch.org/"
	einfo

	if use freeswitch_modules_skypopen ; then
		einfo "To setup the Skype endpoint module mod_skypopen and the Skype client,"
		einfo "follow the instructions in the guide:"
		einfo
		einfo "  http://wiki.freeswitch.org/wiki/Skypiax"
		einfo
		einfo
	fi
}
