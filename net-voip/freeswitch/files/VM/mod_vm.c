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

SWITCH_MODULE_LOAD_FUNCTION(mod_vm_load);
SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_vm_shutdown);
SWITCH_MODULE_DEFINITION(mod_vm, mod_vm_load, mod_vm_shutdown, NULL);

static char DIAL_STR[] = "{suppress_cng=true,originate_timeout=4,progress_timeout=4,effective_caller_id_number=%s,origination_caller_id_number=%s,ignore_early_media=true,absolute_codec_string='PCMU'}sofia/internal/%s@sbc";


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
/*
static int split (const char *str, char c, char ***arr) {
    int count = 1;
    int token_len = 1;
    int i = 0;
    char *p;
    char *t;

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
            count++;
        p++;
    }

    *arr = (char**) malloc(sizeof(char*) * count);
    if (*arr == NULL)
        exit(1);

    p = str;
    while (*p != '\0')
    {
        if (*p == c)
        {
            (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
            if ((*arr)[i] == NULL)
                exit(1);

            token_len = 0;
            i++;
        }
        p++;
        token_len++;
    }
    (*arr)[i] = (char*) malloc( sizeof(char) * token_len );
    if ((*arr)[i] == NULL)
        exit(1);

    i = 0;
    p = str;
    t = ((*arr)[i]);
    while (*p != '\0')
    {
        if (*p != c && *p != '\0')
        {
            *t = *p;
            t++;
        }
        else
        {
            *t = '\0';
            i++;
            t = ((*arr)[i]);
        }
        p++;
    }
    return count;
}
*/
SWITCH_STANDARD_APP(dial_vm_app_function)
{
        char *argv[5] = { 0 };
        char *mydata = NULL;
        char *callerid1 = NULL;
        char *callerid2 = NULL;
        char *number = NULL;
        char *vmsystem = NULL;
        char *vmsystem1 = NULL;
        char *ringlessonly = NULL;
        char *dial_string = NULL;
	int origTimeoutInt = 20;
    	int destCount = 0;
    	int destPos = 0;
    	int calleridCount = 2;
    	int calleridPos = 0;
    	char *destArray[10] = { 0 };
    	char *callerIdArray[2] = { 0 };
    	int retryCount = 3;
    	int connectSuccess = 0;

	switch_channel_t *caller_channel = switch_core_session_get_channel(session);
        switch_core_session_t *peer_session = NULL;
        switch_call_cause_t cause = SWITCH_CAUSE_NORMAL_CLEARING;
        switch_status_t status = SWITCH_STATUS_FALSE;

        if (zstr(data)) {
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "vm app called with no arguments \n");
                return;
	}
	if (!(mydata = switch_core_session_strdup(session, data))) {
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Unable to copy arguments %s \n",data);
                return;
	}
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "arguments %s \n",mydata);
	switch_separate_string(mydata, ' ', argv, (sizeof(argv) / sizeof(argv[0])));

        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Done seperating %s \n",argv[1]);
	callerid1 = argv[0];
	vmsystem1 = argv[1];
	number = argv[2];
	ringlessonly = argv[3];
	callerid2 = argv[4];
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "going to copy vm line %s \n",argv[1]);
	if (!(vmsystem = switch_core_session_strdup(session, vmsystem1))) {
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Unable to process vm system mnumbers %s \n",argv[1]);
		return;
	}

    	//destCount = split(vmsystem,',', &destArray);
    	//destCount = split(vmsystem,',', &destArray);
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "going to parse vm line %s \n",argv[1]);
	destCount = switch_separate_string(vmsystem, ',', destArray, (sizeof(destArray) / sizeof(destArray[0])));

        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "done with vm line %s \n",destArray[0]);
	callerIdArray[0] = callerid1;
	callerIdArray[1] = callerid2;

	
	// Try to get an answer from Leg 2
        do {
        	dial_string = switch_core_session_sprintf(session, DIAL_STR,callerIdArray[calleridPos],callerIdArray[calleridPos],destArray[destPos]);
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Going to do a call for %s %d \n",dial_string,retryCount);
		if (!switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE)) {
			break;
		}
       		status = switch_ivr_originate(NULL, &peer_session, &cause, dial_string, origTimeoutInt, NULL, NULL, NULL, NULL, NULL, SOF_NONE, switch_channel_get_cause_ptr(caller_channel));
        	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Originate done. %s ",dial_string);
		if (status == SWITCH_STATUS_SUCCESS) {
			break;
		}
		if (calleridPos == calleridCount)
			calleridPos = 0;
		else
			calleridPos++;
		if (destPos == destCount)
			destPos = 0;
		else
			destPos++;
	} while (--retryCount > 0 && switch_channel_ready(caller_channel));

        if (switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE) && (status == SWITCH_STATUS_SUCCESS) ) {
                switch_channel_t *peer_channel = switch_core_session_get_channel(peer_session);
		char *dtmfInfo = switch_safe_strdup(number);
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Was success going to try to bridge %s \n",dial_string);
                strcat(dtmfInfo,"#@400");
                switch_core_session_execute_application(peer_session, "playback", "silence_stream://2000");
                switch_core_session_execute_application(peer_session, "send_dtmf", dtmfInfo);
		switch_ivr_sleep(peer_session, 8100, SWITCH_FALSE, NULL);

		if (!switch_channel_ready(caller_channel)) {
                	switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
			return;
		}

                // answer leg 1
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answer caller.\n");
                switch_channel_answer(caller_channel);
                switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answered caller.\n");
                if (switch_channel_ready(caller_channel) && switch_channel_ready(peer_channel)) {
                        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "channel is still ready.\n");
                        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "got peer channel.\n");
                       	if (switch_true(switch_channel_get_variable(caller_channel, SWITCH_BYPASS_MEDIA_AFTER_BRIDGE_VARIABLE)) ||
                               	switch_true(switch_channel_get_variable(peer_channel, SWITCH_BYPASS_MEDIA_AFTER_BRIDGE_VARIABLE))) {
                               	switch_channel_set_flag(caller_channel, CF_BYPASS_MEDIA_AFTER_BRIDGE);
                       	}
                       	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Going to bridge.\n");
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
                       	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Done bridging.\n");
                	if (peer_session) {
                        	switch_core_session_rwunlock(peer_session);
                	}
		}
		if (switch_channel_test_ready(peer_channel,SWITCH_TRUE,SWITCH_FALSE)) {
			switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
		}
	}
        if (switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE)) {
		if (connectSuccess) {
                	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_INFO, "Originate Failed.  Cause: %s\n", switch_channel_cause2str(cause));
			switch_channel_handle_cause(caller_channel, SWITCH_CAUSE_NORMAL_CLEARING);
		} else if (!strcasecmp(ringlessonly, "1")) {
			switch_channel_handle_cause(caller_channel, SWITCH_CAUSE_NORMAL_CIRCUIT_CONGESTION);
		}
	}
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "All done.\n");
}


SWITCH_MODULE_LOAD_FUNCTION(mod_vm_load)
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

	SWITCH_ADD_APP(app_interface, "ytel_dialvm", "Try call through Ruby.", "Try call through Ruby.", dial_vm_app_function, "<number> and more", SAF_SUPPORT_NOMEDIA);

	/* indicate that the module should continue to be loaded */
	return SWITCH_STATUS_SUCCESS;
}

SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_vm_shutdown)
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
