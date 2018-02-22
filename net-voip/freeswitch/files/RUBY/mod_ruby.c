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

SWITCH_MODULE_LOAD_FUNCTION(mod_ruby_load);
SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ruby_shutdown);
SWITCH_MODULE_DEFINITION(mod_ruby, mod_ruby_load, mod_ruby_shutdown, NULL);

static char DIAL_STR[] = "{suppress_cng=true,originate_timeout=%s,progress_timeout=%s,effective_caller_id_number=%s,origination_caller_id_number=%s,ignore_early_media=true,absolute_codec_string='PCMU'}sofia/internal/%s@%s";

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

SWITCH_STANDARD_APP(dial_ruby_app_function)
{
	int argc = 0;
        char *argv[5] = { 0 };
        char *mydata = NULL;
        char *callerid = NULL;
        char *number = NULL;
        char *origTimeout = NULL;
        char *progressTimeout = NULL;
        char *sipGateway =  NULL;
        char *dial_string = NULL;
	int origTimeoutInt = 10;
	int connectSuccess = 0;
        //switch_call_cause_t cancel_cause = 0;

	switch_channel_t *caller_channel = switch_core_session_get_channel(session);
        switch_core_session_t *peer_session = NULL;
        switch_call_cause_t cause = SWITCH_CAUSE_NORMAL_CLEARING;
        switch_status_t status = SWITCH_STATUS_FALSE;
	
        if (zstr(data)) {
                return;
        }
	if (!(mydata = switch_core_session_strdup(session, data))) {
                return;
        }
	if ((argc = switch_separate_string(mydata, ' ', argv, (sizeof(argv) / sizeof(argv[0]))))) {

	}
        callerid = argv[0];
        number = argv[1];
        origTimeout = argv[2];
        progressTimeout = argv[3];
        sipGateway = argv[4];
        dial_string = NULL;

	origTimeoutInt = atoi(origTimeout);

	// create dial string and create new session
        dial_string = switch_core_session_sprintf(session, DIAL_STR,origTimeout,progressTimeout,callerid,callerid,number,sipGateway);
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Going to make new call %s .\n",dial_string);
       	status = switch_ivr_originate(NULL,&peer_session, &cause, dial_string, origTimeoutInt, NULL, NULL, NULL, NULL, NULL, SOF_NONE, switch_channel_get_cause_ptr(caller_channel));
       	//status = switch_ivr_originate(NULL,&peer_session, &cause, dial_string, origTimeoutInt, NULL, NULL, NULL, NULL, NULL, SOF_NONE, &cancel_cause);
        if ( (status == SWITCH_STATUS_SUCCESS) )
        	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Originate done. was success ");
	else
        	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Originate done. was failure ");

        switch_ivr_sleep(session, 2000, SWITCH_FALSE, NULL);

        if ( (status == SWITCH_STATUS_SUCCESS) && switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE) ) {
                switch_channel_t *peer_channel = switch_core_session_get_channel(peer_session);
                // answer leg 1
        	if ( !switch_channel_ready(caller_channel) ) {
        		switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Originate done. was failure ");
			return;
		} else {
                	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answer caller.\n");
                	switch_channel_answer(caller_channel);
                	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Answered caller.\n");
                        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "channel is still ready.\n");
                        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "got peer channel.\n");
                	if (switch_channel_ready(peer_channel)) {
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
                        	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "Done bridging.\n");
			}
			connectSuccess = 1;	
                	if (peer_session) {
                        	switch_core_session_rwunlock(peer_session);
                	}
        		if (switch_channel_test_ready(peer_channel,SWITCH_TRUE,SWITCH_TRUE)) {
                        	switch_channel_handle_cause(peer_channel, SWITCH_CAUSE_NORMAL_CLEARING);
			}
		}
	}

        if (switch_channel_test_ready(caller_channel,SWITCH_TRUE,SWITCH_FALSE)) {
                if (connectSuccess) {
                	switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_INFO, "Originate Failed.  Cause: %s\n", switch_channel_cause2str(cause));
                        switch_channel_handle_cause(caller_channel, SWITCH_CAUSE_NORMAL_CLEARING);
                }
        }
        switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(session), SWITCH_LOG_NOTICE, "All done.\n");
}


SWITCH_MODULE_LOAD_FUNCTION(mod_ruby_load)
{
	//switch_api_interface_t *api_interface;
	switch_application_interface_t *app_interface;

	//memset(&globals, 0, sizeof(globals));
	//globals.pool = pool;
	//switch_mutex_init(&globals.mutex, SWITCH_MUTEX_NESTED, globals.pool);


	if (pool == NULL) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_CRIT, "mod_ruby Received NULL pool\n");
	}
	if (modname == NULL) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_CRIT, "mod_ruby Received NULL modname\n");
	}

	*module_interface = switch_loadable_module_create_module_interface(pool, modname);
	/* connect my internal structure to the blank pointer passed to me */

	SWITCH_ADD_APP(app_interface, "ytel_dialruby", "Try call through Ruby.", "Try call through Ruby.", dial_ruby_app_function, "<number> and more", SAF_SUPPORT_NOMEDIA);
	//SWITCH_ADD_APP(app_interface, "ytel_dialruby", "Try call through Ruby.", "Try call through Ruby.", dial_ruby_app_function, "<number> and more", SAF_ROUTING_EXEC);

	/* indicate that the module should continue to be loaded */
	return SWITCH_STATUS_SUCCESS;
}

SWITCH_MODULE_SHUTDOWN_FUNCTION(mod_ruby_shutdown)
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
