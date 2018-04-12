/* 
 * FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
 * Copyright (C) 2005-2010, Anthony Minessale II <anthm@freeswitch.org>
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is FreeSWITCH Modular Media Switching Software Library / Soft-Switch Application
 *
 * The Initial Developer of the Original Code is
 * Anthony Minessale II <anthm@freeswitch.org>
 *
 * The Initial Developer of this module is
 * Ken Rice <krice at tollfreegateway dot com>
 *
 * Portions created by the Initial Developer are Copyright (C)
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Ken Rice <krice at tollfreegateway dot com>
 * Rance Smith <rance at djrance dot com>
 *
 * mod_ytel.c -- Ytel Custom Routing
 *
 */

#include <switch.h>

#ifdef _MSC_VER					/* compilers are stupid sometimes */
#define TRY_CODE(code) for(;;) {status = code; if (status != SWITCH_STATUS_SUCCESS && status != SWITCH_STATUS_BREAK) { goto end; } break;}
#else
#define TRY_CODE(code) do { status = code; if (status != SWITCH_STATUS_SUCCESS && status != SWITCH_STATUS_BREAK) { goto end; } break;} while(status)
#endif

SWITCH_MODULE_LOAD_FUNCTION(mod_ytel_dial_load);
SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ytel_dial_shutdown);
SWITCH_MODULE_DEFINITION(mod_ytel_dial, mod_ytel_dial_load, mod_ytel_dial_shutdown, NULL);

typedef struct call_info {
	char number[26];
	char origTimeout[6];
	char progressTimeout[6];
	char dtmfVM[2];
	char sipGateway[256];
	int destCount;
	int callerIdCount;
	int retry;
	int origTimeoutInt;
	char *destArray[10];
	char callerIdArray[2];
} call_info_t;

static char DIAL_STR[] = "{suppress_cng=true,originate_timeout=%s,progress_timeout=%s,effective_caller_id_number=%s,origination_caller_id_number=%s,ignore_early_media=true,absolute_codec_string='PCMU'}sofia/internal/%s@%s";


static int parseInput(const char *inputStr, call_info_t *callInfo, switch_core_session_t *session) {

	char *argv[10] = { 0 };
	int argc = 0;
	char *mydata = NULL;
	char *vmSystemTmp = NULL;
	char *callerid1 = NULL;
	char *callerid2 = NULL;
	//call_info_t ci = *callInfo;

	//////
	// Input check
	/////
	if (zstr(inputStr)) {
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_WARNING, "No arguments passed\n");
		return SWITCH_FALSE;
	}
	if (!(mydata = switch_core_session_strdup(session, inputStr))) {
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_ERROR, "Unable to copy arguments %s \n",inputStr);
		return SWITCH_FALSE;
	}
	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "Splitting inbput string %s \n",mydata);
	argc = switch_separate_string(mydata, ' ', argv, (sizeof(argv) / sizeof(argv[0])));
	if (argc != 9) {
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_WARNING, "Required number of arguments not received (%d) %s \n",argc,inputStr);
		return SWITCH_FALSE;
	}
	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "Done seperating %s \n",mydata);

	//         return String.format(DIAL,config.getCallerid(),cr.getPrefix(),"1"+config.getCalled(),config.getCalled(),config.getCallerid2(),cr.getOrigTimeout(),cr.getProgressTimeout(),cr.getRetry(),cr.getSipGateway(),"0");
	//internal/+13038866029@208.94.33.34 ytel_dial(+13038866029 8028#13038866028 3038866028 3038866022 15 10 0 sbc 0)
	//mod_ytel_dial.c:161 YTELSTAT:  311 +3 8028#13038866028 NORMAL_TEMPORARY_FAILURE DIAL 0
	//mod_ytel_dial.c:243 YTELSTAT:  311 3 (null) NORMAL_TEMPORARY_FAILURE (null) END
	//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "YTELSTAT: %s %s %s %s %s %s END\n",&callInfo->dtmfVM,&callInfo->number,&callInfo->callerIdArray[calleridPos],callInfo->destArray[destPos],switch_channel_cause2str(cause),switch_channel_get_variable(caller_channel,"billmsec"));

	//switch_copy_string(callInfo->callerIdArray[0] , argv[0],25);
	callerid1 = &callInfo->callerIdArray[0];
	callerid2 = &callInfo->callerIdArray[1];
	switch_copy_string(callerid1 , argv[0],25);
	//callInfo->callerIdArray[0]  = callerid1;
	switch_copy_string(callerid2 , argv[3],25);
	//switch_copy_string(callInfo->callerIdArray[1] , argv[3],25);
	//callInfo->callerIdArray[1] = callerid2;
	callInfo->callerIdCount = 2;

	switch_copy_string(callInfo->number , argv[2],26);
	switch_copy_string(callInfo->origTimeout , argv[4],6);
	switch_copy_string(callInfo->progressTimeout , argv[5],6);
	switch_copy_string(callInfo->sipGateway , argv[7],256);
	switch_copy_string(callInfo->dtmfVM , argv[8],2);
	callInfo->origTimeoutInt = atoi(argv[4]);
	callInfo->retry = atoi(argv[6]);

	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "going to copy vm line %s \n",argv[1]);
	if (!(vmSystemTmp = switch_core_session_strdup(session, argv[1]))) {
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_WARNING, "Unable to process vm system mnumbers %s \n",argv[1]);
		return SWITCH_FALSE;
	}
	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "going to parse vm line %s \n",vmSystemTmp);
	callInfo->destCount = switch_separate_string(vmSystemTmp, ',', callInfo->destArray, (sizeof(callInfo->destArray) / sizeof(callInfo->destArray[0])));
	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_DEBUG, "Done with vm line %s %d \n",callInfo->destArray[0],callInfo->destCount);

	//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Parsed: dtmf %s number %s callid %s callid %s dest %s otimeout %s ptimeout %s gw %s retry %d destcount %d callid count %d \n",callInfo->dtmfVM,callInfo->number,&callInfo->callerIdArray[0],&callInfo->callerIdArray[1],callInfo->destArray[0],callInfo->origTimeout,callInfo->progressTimeout,callInfo->sipGateway,callInfo->retry,callInfo->destCount,callInfo->callerIdCount);
	return SWITCH_TRUE;
}

static switch_status_t bridge_on_dtmf(switch_core_session_t *session, void *input, switch_input_type_t itype, void *buf, unsigned int buflen)
{
	char *str = (char *) buf;
	if (str && input && itype == SWITCH_INPUT_TYPE_DTMF) {
		switch_dtmf_t *dtmf = (switch_dtmf_t *) input;
		if (strchr(str, dtmf->digit)) {
			return SWITCH_STATUS_BREAK;
		}
	}
	return SWITCH_STATUS_SUCCESS;
}

SWITCH_STANDARD_APP(ytel_dial_app_function)
{

	//////
	// Variable defs
	/////
	char *dial_string = NULL;
	int destPos = 0;
	int calleridPos = 0;
	int lastDestPos = 0;
	int lastCalleridPos = 0;
	int connectSuccess = 0;
	call_info_t *callInfo;

	switch_channel_t *caller_channel = switch_core_session_get_channel(session);
	switch_core_session_t *peer_session = NULL;
	switch_call_cause_t cause = SWITCH_CAUSE_NORMAL_CLEARING;
	switch_status_t status = SWITCH_STATUS_FALSE;

    switch_zmalloc(callInfo, sizeof(call_info_t));
    switch_assert(callInfo);
    memset(callInfo, 0, sizeof(*callInfo));

    // if required parameters are passed.
	if (!parseInput(data,callInfo,session))
		return;

	//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Parsed: dtmf %s number %s callid %s callid %s dest %s otimeout %s ptimeout %s gw %s retry %d destcount %d callid count %d \n",callInfo->dtmfVM,callInfo->number,&callInfo->callerIdArray[0],&callInfo->callerIdArray[1],callInfo->destArray[0],callInfo->origTimeout,callInfo->progressTimeout,callInfo->sipGateway,callInfo->retry,callInfo->destCount,callInfo->callerIdCount);
	///////
	// Connect to remote Answering machine
	//////
	do {
		lastDestPos = destPos;
		lastCalleridPos = calleridPos;
		dial_string = switch_core_session_sprintf(session, DIAL_STR,callInfo->origTimeout,callInfo->progressTimeout,&callInfo->callerIdArray[calleridPos],&callInfo->callerIdArray[calleridPos],callInfo->destArray[destPos],callInfo->sipGateway);
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Going to call %s for real num %s retrycount %d \n",callInfo->destArray[destPos],callInfo->number,callInfo->retry);
		if (!switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE)) {
			break;
		}
		status = switch_ivr_originate(NULL, &peer_session, &cause, dial_string, callInfo->origTimeoutInt, NULL, NULL, NULL, NULL, NULL, SOF_NONE, switch_channel_get_cause_ptr(caller_channel));
		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "YTELSTAT: %s %s %s %s %s DIAL %d\n",callInfo->dtmfVM,callInfo->number,&callInfo->callerIdArray[calleridPos],callInfo->destArray[destPos],switch_channel_cause2str(cause),callInfo->retry);
		if (status == SWITCH_STATUS_SUCCESS)
			break;

		if (calleridPos == callInfo->callerIdCount)
			calleridPos = 0;
		else
			calleridPos++;
		if (destPos == callInfo->destCount)
			destPos = 0;
		else
			destPos++;
	} while (--callInfo->retry > 0 && switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE) && status != SWITCH_STATUS_SUCCESS);

	///////
	// Bridge calls together if we are still conneced on leg1
	//////
	if (switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE) && (status == SWITCH_STATUS_SUCCESS) ) {
		switch_channel_t *peer_channel = switch_core_session_get_channel(peer_session);
		// IF we are to send DTMF for answering machine service,  Send a bit of silence to start audio stream on our side.
		if (strcmp(callInfo->dtmfVM , "1") == 0) {
			char *dtmfInfo = switch_safe_strdup(callInfo->number);
			strcat(dtmfInfo,"#@400");
			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Got answer for Direct VM for real num %s \n",callInfo->destArray[lastDestPos]);
			/// outbound leg
			switch_core_session_execute_application(peer_session, "playback", "silence_stream://2000");
			switch_core_session_execute_application(peer_session, "send_dtmf", dtmfInfo);
			switch_ivr_sleep(peer_session, 8100, SWITCH_FALSE, NULL);
		} else {
			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Got answer for real num %s \n",callInfo->destArray[lastDestPos]);
			switch_core_session_execute_application(peer_session, "playback", "silence_stream://800");
		}
		// make sure we are ready to go. set caller channel to 183 ringing
		if (!switch_channel_ready(caller_channel)) {
			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "YTELSTAT: %s %s %s %s %s %d END\n",callInfo->dtmfVM,callInfo->number,&callInfo->callerIdArray[lastCalleridPos],callInfo->destArray[lastDestPos],switch_channel_cause2str(cause),0);
			switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
			return;
		}

		// Answer leg 1
		//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answer caller.\n");
		switch_channel_answer(caller_channel);
		//witch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answered caller.\n");
		if (switch_channel_ready(caller_channel) && switch_channel_ready(peer_channel)) {
			//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "channel is still ready.\n");
			//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "got peer channel.\n");
			if (switch_true(switch_channel_get_variable(caller_channel, SWITCH_BYPASS_MEDIA_AFTER_BRIDGE_VARIABLE)) ||
					switch_true(switch_channel_get_variable(peer_channel, SWITCH_BYPASS_MEDIA_AFTER_BRIDGE_VARIABLE))) {
				switch_channel_set_flag(caller_channel, CF_BYPASS_MEDIA_AFTER_BRIDGE);
			}
			//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Going to bridge.\n");
			if (switch_channel_test_flag(caller_channel, CF_PROXY_MODE)) {
				switch_ivr_signal_bridge(session, peer_session);
			} else {
				char *a_key = (char *) switch_channel_get_variable(caller_channel, "bridge_terminate_key");
				char *b_key = (char *) switch_channel_get_variable(peer_channel, "bridge_terminate_key");
				int ok = 0;
				switch_input_callback_function_t func = NULL;
				if (a_key) {
					a_key = switch_core_session_strdup(session, a_key);
					ok++;
				}
				if (b_key) {
					b_key = switch_core_session_strdup(session, b_key);
					ok++;
				}
				if (ok) {
					func = bridge_on_dtmf;
				} else {
					a_key = NULL;
					b_key = NULL;
				}
				switch_ivr_multi_threaded_bridge(session, peer_session, func, a_key, b_key);
			}
			connectSuccess = 1;
			//switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Done bridging.\n");
			if (peer_session)
				switch_core_session_rwunlock(peer_session);
		}
		if (switch_channel_test_ready(peer_channel,SWITCH_TRUE,SWITCH_FALSE))
			switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
	} else if ( (status == SWITCH_STATUS_SUCCESS)) {
		switch_channel_t *peer_channel = switch_core_session_get_channel(peer_session);
		if (switch_channel_test_ready(peer_channel,SWITCH_TRUE,SWITCH_FALSE)) {
			switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
		}
	}
	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "YTELSTAT: %s %s %s %s %s %s END\n",callInfo->dtmfVM,callInfo->number,&callInfo->callerIdArray[lastCalleridPos],callInfo->destArray[lastDestPos],switch_channel_cause2str(cause),switch_channel_get_variable(caller_channel,"billmsec"));
	if (connectSuccess && switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE))
		switch_channel_handle_cause(caller_channel, SWITCH_CAUSE_NORMAL_CLEARING);
}


SWITCH_MODULE_LOAD_FUNCTION(mod_ytel_dial_load)
{
	//switch_api_interface_t *api_interface;
	switch_application_interface_t *app_interface;

	//memset(&globals, 0, sizeof(globals));
	//globals.pool = pool;
	//switch_mutex_init(&globals.mutex, SWITCH_MUTEX_NESTED, globals.pool);

	if (pool == NULL) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_CRIT, "mod_vm Received NULL pool\n");
	}
	if (modname == NULL) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_CRIT, "mod_vm Received NULL modname\n");
	}

	*module_interface = switch_loadable_module_create_module_interface(pool, modname);
	/* connect my internal structure to the blank pointer passed to me */

	SWITCH_ADD_APP(app_interface, "ytel_dial", "Dial external call and only answer leg 1 if we connect.", "ytel dial method.", ytel_dial_app_function, "<callerid1> <dialNumber(s)> <destinationNumber> <callerid2> <orig timeout> <progress Timeout> <retries> <sipgateway> <do dtmf vmsystem>", SAF_SUPPORT_NOMEDIA);

	/* indicate that the module should continue to be loaded */
	return SWITCH_STATUS_SUCCESS;
}

SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ytel_dial_shutdown)
{
	//switch_safe_free(globals.default_techprofile);
	//switch_safe_free(globals.default_gateway);

	//switch_core_destroy_memory_pool(&globals.pool);
	return SWITCH_STATUS_UNLOAD;
}

/* For Emacs:
 * Local Variables:
 * mode:c
 * indent-tabs-mode:t
 * tab-width:4
 * c-basic-offset:4
 * End:
 * For VIM:
 * vim:set softtabstop=4 shiftwidth=4 tabstop=4:
 */
