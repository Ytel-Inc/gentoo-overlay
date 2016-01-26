/*
 * Copyright (C) 2006-2008:
 *		RMK Teknologies, Inc.
 *		Anthony Minesalle II
 *		Michael Jerris
 *
 * mod_amd.c -- Answering Machine Detection
 * This code is not free, it is not indended for redistribution.
 * This code may not be redistributed in case you didn't understand the line above.
 * Contact Ken Rice <krice@rmktek.com> for licensing details.
 *
 */

#include <switch.h>

#define AMD_EVENT "AMD::EVENT"
#define STATE_NONE   -1
#define STATE_SILENT  0
#define STATE_NOISE   1

typedef enum {
	AMD_STATUS_UNKNOWN = 0,
	AMD_STATUS_PERSON = 1,
	AMD_STATUS_MACHINE =2
} amd_status_t;

typedef enum {
	AMD_RESULT_TOO_LONG = 1,
	AMD_RESULT_MAX_COUNT,
	AMD_RESULT_MAX_INTRO,
	AMD_RESULT_SILENT_INITIAL,
	AMD_RESULT_SILENT_AFTER_INTRO
} amd_result_t;

SWITCH_MODULE_LOAD_FUNCTION(mod_amd_load);
SWITCH_MODULE_DEFINITION(mod_amd, mod_amd_load, NULL, NULL);

struct amd_settings {
	int silent_threshold;
	int silent_initial;
	int silent_after_intro;
	int silent_max_session;
	int noise_max_intro;
	int noise_min_length;
	int noise_inter_silence;
	int noise_max_count;
	int total_analysis_time;
	int debug;
};
typedef struct amd_settings amd_settings_t;

struct amd_helper {
	amd_settings_t *settings;
	switch_core_session_t *session;
    switch_channel_t *channel;
	switch_frame_t frame;

	int state;
	int state_silent_initial;
	int state_intro;
	int complete;

	amd_status_t amd_status;
	amd_result_t amd_result;

	int total_time;
	int total_noise_count;
	time_t total_call_time;
	int talking_min;

	switch_time_t end_session;
	switch_time_t last_noisy;
	switch_time_t last_silent;
	switch_time_t first_noisy;
	switch_time_t first_silent;
	switch_time_t intro_silent;

	int32_t samples_counted;		
	int32_t frame_count;
	int32_t noisy_frames;
	int32_t silent_frames;

	uint32_t hangover_hits;
	uint32_t hangunder_hits;
    int wait_for_answer;
};
typedef struct amd_helper amd_helper_t;


static struct {    
	amd_settings_t as;
} globals;

SWITCH_STANDARD_APP(result_function);
SWITCH_STANDARD_APP(voice_start_function);
SWITCH_STANDARD_APP(voice_stop_function);

static switch_status_t do_config();

static switch_status_t amd_function(amd_helper_t *ah_data, void *data, unsigned int len)
{
	amd_helper_t *ah = (amd_helper_t *) ah_data;
	amd_settings_t *as = ah->settings;
	switch_core_session_t *session = ah->session;
	switch_channel_t *channel = switch_core_session_get_channel(session);
	switch_codec_t *read_codec = switch_core_session_get_read_codec(session);
	uint32_t 
		hangover = 0,
		hangunder = 0,
		diff_level = 400;
	int32_t 
		count = 0,
		samples = 0,		
		j = 0;
	double energy, score;
	int16_t *fdata;

	energy = 0;

	fdata = (int16_t *) data;
	samples = len / sizeof(*fdata);
	ah->samples_counted += samples;

	for (count = 0; count < samples; count++) {
		energy += abs(fdata[j]);
		j += read_codec->implementation->number_of_channels;
	}
	score = energy / samples;

	ah->frame_count++;
	ah->total_time += len;

	if ((ah_data->total_time/1000) >= as->total_analysis_time) {
		if (as->debug)
			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*TOTAL TIME REACHED*:-----:%d, %d\n", ah_data->total_time, as->total_analysis_time); 
		ah->amd_result = AMD_RESULT_TOO_LONG;
		ah->amd_status = AMD_STATUS_UNKNOWN;

		/* Add Exit Bug Here */

		if (ah->end_session >= as->silent_max_session) {
			if (as->debug)
				switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*END FUNCTION REACHED*:---- %d, %d\n", (int)ah->end_session, (int)as->silent_max_session); 
			return SWITCH_STATUS_FALSE;
		} else {
			ah->end_session += ((switch_micro_time_now() - ah->last_noisy)/1000);
		}
	}

	if (score >= as->silent_threshold) {
		uint32_t diff = (uint32_t)(score - as->silent_threshold);
		if (ah->hangover_hits) {
			ah->hangover_hits--;
		}

		if (diff >= diff_level || ++ah->hangunder_hits >= hangunder) {
			ah->hangover_hits = ah->hangunder_hits = 0;

			if (!ah->state == STATE_NOISE) {
				switch_event_t *event;
				ah->state = STATE_NOISE;
				ah->first_noisy = switch_micro_time_now();
				if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, AMD_EVENT) == SWITCH_STATUS_SUCCESS) {
					switch_channel_event_set_data(channel, event);
					switch_event_add_header(event, SWITCH_STACK_BOTTOM, "Action", "start-talking");
					switch_event_fire(&event);
				}
			}

			/* TALKING */
			if ((switch_micro_time_now() - ah->first_noisy)/1000 >= as->noise_min_length)	{

				if (as->debug)
					switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*TALKING MIN REACHED*:-----:%d, %d\n",(int)(switch_micro_time_now() - ah->last_silent)/1000, (int)as->noise_min_length); 

				if (ah->talking_min == 1) {
					if (((switch_micro_time_now() - ah->last_silent)/1000) >= as->noise_inter_silence) {
						ah->total_noise_count++;
					}

					ah->talking_min = 0;

					if (as->debug)
						switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*TALKING MIN PASSED*:-----:%d, %d\n",(int)(switch_micro_time_now() - ah->last_silent)/1000, (int)as->noise_min_length); 

					if (ah->state_silent_initial == 1) {
						if (as->debug)
							switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*SILENT INITIAL END REACHED*:-----:%d, %d\n",(int)(switch_micro_time_now() - ah->last_silent)/1000, (int)as->noise_min_length); 
						ah->state_silent_initial = 0;
						ah->state_intro = 1;
					}

					if (ah->total_noise_count >= as->noise_max_count) {
						if (as->debug)
							switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*MAX NOISE COUNT REACHED*:-----:%d, %d\n",ah->total_noise_count, as->noise_max_count); 
						ah->amd_result = AMD_RESULT_MAX_COUNT;
						ah->amd_status = AMD_STATUS_MACHINE;
						return SWITCH_STATUS_FALSE;
					}
				}

				if (ah->state_intro == 1) {
					ah->intro_silent = switch_micro_time_now();

					if (((switch_micro_time_now() - ah->last_silent)/1000) >= as->noise_max_intro) {
						if (as->debug)
							switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*MAX NOISE INTRO REACHED*\n");
						ah->amd_result = AMD_RESULT_MAX_COUNT;
						ah->amd_status = AMD_STATUS_MACHINE;
						return SWITCH_STATUS_FALSE;
					}

					if (((switch_micro_time_now() - ah->last_noisy)/1000) >= as->noise_max_intro) {
						if (as->debug)
							switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*MAX NOISE INTRO*:-----:%d, %d\n",(int)((switch_micro_time_now() - ah->last_noisy)/1000), as->noise_max_intro); 
						ah->amd_result = AMD_RESULT_MAX_INTRO;
						ah->amd_status = AMD_STATUS_MACHINE;
						/* Add Exit Bug Here */
						if (ah->end_session >= as->silent_max_session) {
							if (as->debug)
								switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*END FUNCTION REACHED*:---- %d, %d\n", (int)ah->end_session, (int)as->silent_max_session); 
							return SWITCH_STATUS_FALSE;
						} else {
							ah->end_session += ((switch_micro_time_now() - ah->last_noisy)/1000);
						}
					}
				}
			}
		} 
	} else {
		if (ah->hangunder_hits) {
			ah->hangunder_hits--;
		}

		if (ah->state == STATE_NOISE) {
			switch_event_t *event;
			if (++ah->hangover_hits >= hangover) {
				ah->hangover_hits = ah->hangunder_hits = 0;
				ah->state = STATE_SILENT;
				ah->first_silent = switch_micro_time_now();
				if (switch_event_create_subclass(&event, SWITCH_EVENT_CUSTOM, AMD_EVENT) == SWITCH_STATUS_SUCCESS) {
					switch_channel_event_set_data(channel, event);
					switch_event_add_header(event, SWITCH_STACK_BOTTOM, "Action", "stop-talking");
					switch_event_fire(&event);
				}					

				/* SILENT */
				if (ah->state_silent_initial == 1 &&  (switch_micro_time_now() - ah->last_noisy)/1000 >= as->silent_initial) {
					if (as->debug)
						switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*SILENT INITIAL*:-----:%d, %d\n",(int)(switch_micro_time_now() - ah->last_noisy)/1000, (int)as->silent_initial); 
				}				
			}
		}

		if (ah->first_silent && ah->state_silent_initial == 1 && ((switch_micro_time_now() - ah->first_silent)/1000) >= as->silent_initial) {

			if (as->debug)
				switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*PERSON SILENT INITIAL*:-----:%d, %d\n",(int)((switch_micro_time_now() - ah->first_silent)/1000), (int)as->silent_initial); 

			/* Add Code here, someone picked up the phone and didn't say anything after silent_initial... person */

			ah->amd_result = AMD_RESULT_SILENT_INITIAL;
			ah->amd_status = AMD_STATUS_PERSON;

			/* Add Exit Bug Here */
			if (ah->end_session >= as->silent_max_session) {
				if (as->debug)
					switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*END FUNCTION REACHED*:---- %d, %d\n", (int)ah->end_session, (int)as->silent_max_session); 
				return SWITCH_STATUS_FALSE;
			} else {
				ah->end_session += ((switch_micro_time_now() - ah->last_noisy)/1000);
			}
		}

		if (as->debug)
			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*silent state*:-----: state %d, now %d, silent after %d\n",
						ah->state_intro, (int)((switch_micro_time_now() - ah->intro_silent)/1000), as->silent_after_intro); 
		if (ah->state_intro == 1 && ((switch_micro_time_now() - ah->intro_silent)/1000) >= as->silent_after_intro) {
			ah->state_intro = 0;

			if (as->debug)
				switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*PERSON AFTER INTRO*:-----:%d, %d\n",(int)((switch_micro_time_now() - ah->intro_silent)/1000), (int)as->silent_after_intro); 

			/* Add Code here, someone picked up the phone, said hello and didn't say anything for x=silent_after_intro... person */

			ah->amd_result = AMD_RESULT_SILENT_AFTER_INTRO;
			ah->amd_status = AMD_STATUS_PERSON;

			if (as->debug)
				switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*END FUNCTION REACHED*:---- %d, %d\n", (int)ah->end_session, (int)as->silent_max_session); 

			return SWITCH_STATUS_FALSE;
		}
	}

/*
	if (as->debug)
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "%s:-----:nf%d sf%d e%0.2f/s%0.2f\n", 
			ah->state ? "TALKING":"SILENT",
			ah->noisy_frames,
			ah->silent_frames,
			energy,
			score);
	if (as->debug) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG,
			"*CONFIG*:-----:s%d  ssi%d,si%d  tt%d,tnc%d  stn%d,ln%d,ls%d,fn%d,fs%d  sc%d,fc%d,nf%d,sf%d  hoh%d,huh%d\n",
			ah->state, ah->state_silent_initial, ah->state_intro, ah->total_time, ah->total_noise_count,
			(int)(switch_micro_time_now()), (int)ah->last_noisy, (int)ah->last_silent, (int)ah->first_noisy,
			(int)ah->first_silent, (int)ah->samples_counted, (int)ah->frame_count, (int)ah->noisy_frames, (int)ah->silent_frames, (int)ah->hangover_hits,
			(int)ah->hangunder_hits); 
	}
*/	

	if (ah->state == STATE_NOISE) {
		ah->noisy_frames++;
		ah->last_noisy = switch_micro_time_now();
	} else {
		ah->silent_frames++;
		ah->last_silent = switch_micro_time_now();
		ah->talking_min = 1;
		if (!ah->first_silent)
			ah->first_silent = switch_micro_time_now();
	}

	return SWITCH_STATUS_SUCCESS;
}

static switch_bool_t amd_callback(switch_media_bug_t *bug, void *user_data, switch_abc_type_t type)
{
	amd_helper_t *ah = (amd_helper_t *) user_data;
	switch_frame_t frame = { 0 };

	uint8_t data[SWITCH_RECOMMENDED_BUFFER_SIZE];
	frame.data = data;
	frame.buflen = SWITCH_RECOMMENDED_BUFFER_SIZE;

	switch (type) {               

	case SWITCH_ABC_TYPE_INIT:
		break;
	case SWITCH_ABC_TYPE_CLOSE:
		break;                      

	case SWITCH_ABC_TYPE_READ:
		if (ah) {
            switch_assert(ah != NULL);
			switch_assert(ah->session != NULL);
            
            if (ah->wait_for_answer && !switch_channel_test_flag(ah->channel, CF_ANSWERED)) {
                return SWITCH_TRUE;
            }

			if (switch_core_media_bug_read(bug, &frame, FALSE) == SWITCH_STATUS_SUCCESS) {
				switch_status_t status;

				if ((status = amd_function(ah, frame.data, frame.datalen) != SWITCH_STATUS_SUCCESS)) {
					switch_event_t *event;
					switch_channel_t *channel;
					const char *amd_stat, *amd_result;
					channel = switch_core_session_get_channel(ah->session);

					switch(ah->amd_status) {
						case AMD_STATUS_MACHINE:
							amd_stat = "machine";
							break;
						case AMD_STATUS_PERSON:
							amd_stat = "person";
							break;
						case AMD_STATUS_UNKNOWN:
						default:
							amd_stat = "unsure";
							break;
					}
					switch(ah->amd_result) {
						case AMD_RESULT_TOO_LONG:
							amd_result = "too-long";
							break;
						case AMD_RESULT_MAX_COUNT:
							amd_result = "max-count";
							break;
						case AMD_RESULT_MAX_INTRO:
							amd_result = "max-intro";
							break;
						case AMD_RESULT_SILENT_INITIAL:
							amd_result = "silent-initial";
							break;
						case AMD_RESULT_SILENT_AFTER_INTRO:
							amd_result = "silent-after-intro";
							break;
						default:
							amd_result = "";
							break;
					}

					switch_channel_set_variable(channel, "amd_result", amd_result);
					switch_channel_set_variable(channel, "amd_status", amd_stat);

					if (switch_event_create(&event, SWITCH_EVENT_DETECTED_SPEECH) == SWITCH_STATUS_SUCCESS) {
						switch_event_add_header(event, SWITCH_STACK_BOTTOM, "amd_result", amd_result);
						switch_event_add_header(event, SWITCH_STACK_BOTTOM, "amd_status", amd_stat);
						switch_event_add_body(event, "%s", "amd_complete");
					}

					if (switch_core_session_queue_event(ah->session, &event) != SWITCH_STATUS_SUCCESS) {

						switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Event queue failed!\n");
						switch_event_add_header(event, SWITCH_STACK_BOTTOM, "delivery-failure", "true");
						switch_event_fire(&event);
					}
					ah->complete = 1;
					return SWITCH_FALSE;
				}
			} 
		}
		break;

	case SWITCH_ABC_TYPE_WRITE:
		if (ah) {
			switch_assert(ah->session != NULL);
		}
		break;
	default:
		break;
	}
	return SWITCH_TRUE;  
}


/* Voice Start Function */
SWITCH_STANDARD_APP(voice_start_function)
{
	switch_media_bug_t *bug;
	switch_status_t status;
	switch_channel_t *channel = switch_core_session_get_channel(session);
	amd_helper_t *ah;
	amd_settings_t *as;

	char *argv[20], 
		*var,
		*val,
		*mydata;

	int argc;
	int x;
	const char *amdebug = switch_channel_get_variable(channel, "amd_debug");
	int debug = switch_true(amdebug);

	if ((bug = switch_channel_get_private(channel, "_amd_"))) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Only 1 AMD per channel please!\n");
		return;
	}

	ah = (amd_helper_t *) switch_core_session_alloc(session, sizeof(*ah));

	ah->state = STATE_SILENT;
	ah->state_silent_initial = 1;
	ah->state_intro = 0;
	ah->total_call_time = 3600000 + time(NULL);
	ah->total_time = 0;
	ah->total_noise_count = 0;
	ah->samples_counted = 0;		
	ah->frame_count = 0;
	ah->noisy_frames = 0;
	ah->silent_frames = 0;
	ah->hangover_hits = 0;
	ah->hangunder_hits = 0;
	ah->session = session;
    ah->channel = switch_core_session_get_channel(ah->session);

    if (switch_true(switch_channel_get_variable(channel, "amd_wait_for_answer"))) {
        ah->wait_for_answer = 1;
    }

	as = (amd_settings_t *) switch_core_session_alloc(session, sizeof(*as));
	ah->settings = as;
	memcpy(as, &globals.as, sizeof(globals.as));

	if (switch_strlen_zero(data)) {
		goto bug_install;
	}

	if (!((mydata = switch_core_session_strdup(session, data)))) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Memory Error!\n");
		switch_channel_hangup(channel, SWITCH_CAUSE_DESTINATION_OUT_OF_ORDER);
		return;
	}

	if ((argc = switch_separate_string(mydata, ',', argv, (sizeof(argv) / sizeof(argv[0]))))) {
		for(x = 0; x < argc; x++) {
			var = argv[x];
			if ((val = strchr(var, '='))) {
				*val++ = '\0';
			}

			if (!switch_strlen_zero(var) && !switch_strlen_zero(val)) {
				if (!strcasecmp(var, "silent_threshold")) {
					as->silent_threshold = atoi(val);
				} else if (!strcasecmp(var, "silent_initial")) {
					as->silent_initial = atoi(val);
				} else if (!strcasecmp(var, "silent_after_intro")) {
					as->silent_after_intro = atoi(val);
				} else if (!strcasecmp(var, "noise_max_intro")) {
					as->noise_max_intro = atoi(val);
				} else if (!strcasecmp(var, "noise_min_length")) {
					as->noise_min_length = atoi(val);
				} else if (!strcasecmp(var, "noise_inter_silence")) {
					as->noise_inter_silence = atoi(val);
				} else if (!strcasecmp(var, "noise_max_count")) {
					as->noise_max_count = atoi(val);
				} else if (!strcasecmp(var, "total_analysis_time")) {
					as->total_analysis_time = atoi(val);
				} else if (!strcasecmp(var, "debug")) {
					as->debug = switch_true(val);
				}
			}
		}
	}

bug_install:

	if (debug) {
		as->debug = 1;
	}

	switch_channel_set_private(channel, "_amd_", bug);
	switch_channel_set_private(channel, "_amd_handle_", ah);

	if ((status = switch_core_media_bug_add(session, "amd", NULL, amd_callback, ah, ah->total_call_time, SMBF_READ_STREAM, &bug)) != SWITCH_STATUS_SUCCESS) {
			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Bug Failure!\n");
			switch_channel_hangup(channel, SWITCH_CAUSE_DESTINATION_OUT_OF_ORDER);
	}
}


/* Voice Detection Stop Function */
SWITCH_STANDARD_APP(voice_stop_function) {

	switch_media_bug_t *bug;
	switch_channel_t *channel = switch_core_session_get_channel(session);

	switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*STOP FUNCTION REACHED*:----------------------------- waiting on end\n"); 

	switch_assert(channel != NULL);

	if ((bug = switch_channel_get_private(channel, "_amd_"))) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*STOP FUNCTION STARTED*:----------------------------- \n"); 
		switch_channel_set_private(channel, "_amd_", NULL);
		switch_core_media_bug_remove(session, &bug);
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_DEBUG, "*STOP FUNCTION ENDED*:----------------------------- \n"); 
	}
}       


/* Wait for an AMD Result */
SWITCH_STANDARD_APP(result_function)
{
	switch_channel_t *channel;
	amd_helper_t *ah;

	switch_assert(session != NULL);

	channel = switch_core_session_get_channel(session);
	switch_assert(channel != NULL);

	switch_channel_answer(channel);

	ah = switch_channel_get_private(channel, "_amd_handle_");

	if (!ah) return;

	for (;;) {
		const char *result;

		if (ah->complete) {
			if ((result = switch_channel_get_variable(channel, "amd_result"))) {
				switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_NOTICE,  "AMD RESULT FOUND: %s\n", result);
				break;
			}
		}

		if (switch_channel_get_state(channel) >= CS_HANGUP) {

			switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_NOTICE,  "CS HANGUP\n");
			switch_channel_set_variable(channel, "amd_wait_status", "hangup");
			switch_channel_set_variable(channel, "amd_wait_result", "hangup");
			switch_channel_hangup(channel, SWITCH_CAUSE_NORMAL_CLEARING);				
			break;
		}

		switch_yield(10000);
	}
}

/*     AMD Configuration Loader  */

static switch_status_t do_config() {
	char *cf = "amd.conf";
	switch_xml_t cfg, xml, settings, param;
	amd_settings_t *as = &globals.as;

	/* Program Defaults */
	as->silent_threshold = 256;
	as->silent_initial = 4500;
	as->silent_after_intro = 1000;
	as->silent_max_session = 200;
	as->noise_max_intro = 1250;
	as->noise_min_length = 120;
	as->noise_inter_silence = 30;
	as->noise_max_count = 6;
	as->total_analysis_time = 5000;

	if (!(xml = switch_xml_open_cfg(cf, &cfg, NULL))) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "open of %s failed\n", cf);
	} else {
		if ((settings = switch_xml_child(cfg, "settings"))) {

			for (param = switch_xml_child(settings, "param"); param; param = param->next) {
				char *var = NULL;
				char *val = NULL;

				var = (char *) switch_xml_attr_soft(param, "name");
				val = (char *) switch_xml_attr_soft(param, "value");

				if (!switch_strlen_zero(val) && !switch_strlen_zero(var)) {
					if (!strcasecmp(var, "silent_threshold")) {
						as->silent_threshold = atoi(val);
					} else if (!strcasecmp(var, "silent_initial")) {
						as->silent_initial = atoi(val);
					} else if (!strcasecmp(var, "silent_after_intro")) {
						as->silent_after_intro = atoi(val);
					} else if (!strcasecmp(var, "noise_max_intro")) {
						as->noise_max_intro = atoi(val);
					} else if (!strcasecmp(var, "noise_min_length")) {
						as->noise_min_length = atoi(val);
					} else if (!strcasecmp(var, "noise_inter_silence")) {
						as->noise_inter_silence = atoi(val);
					} else if (!strcasecmp(var, "noise_max_count")) {
						as->noise_max_count = atoi(val);
					} else if (!strcasecmp(var, "total_analysis_time")) {
						as->total_analysis_time = atoi(val);
					} else if (!strcasecmp(var, "debug")) {
						as->debug = switch_true(val);
					}
				}
			}
		}
		switch_xml_free(xml);
	}
	return SWITCH_STATUS_SUCCESS;
}


/*    Syntax Definitions  */

#define RESULT_USAGE " <timeout >"
#define RESULT_DESC " Wait for a Result from Media Bugs"
#define VOICE_START_USAGE " - "
#define VOICE_START_DESC "Start Voice Detection Media Bug"
#define VOICE_STOP_USAGE " - "
#define VOICE_STOP_DESC "Stop Voice Detection Media Bug"

/*    Called when the module is loaded  */
SWITCH_MODULE_LOAD_FUNCTION(mod_amd_load)
{
	switch_application_interface_t *app_interface;

	do_config();

	if (switch_event_reserve_subclass(AMD_EVENT) != SWITCH_STATUS_SUCCESS) {
		switch_log_printf(SWITCH_CHANNEL_LOG, SWITCH_LOG_ERROR, "Couldn't register subclass %s!", AMD_EVENT);
		return SWITCH_STATUS_TERM;
	}

	/* connect my internal structure to the blank pointer passed to me */
	*module_interface = switch_loadable_module_create_module_interface(pool, modname);

	SWITCH_ADD_APP(app_interface, "waitforresult", "Wait for Result", RESULT_DESC, result_function, RESULT_USAGE, SAF_NONE);
	SWITCH_ADD_APP(app_interface, "voice_start", "Voice Detection Start", VOICE_START_DESC, voice_start_function, VOICE_START_USAGE, SAF_NONE);
	SWITCH_ADD_APP(app_interface, "voice_stop", "Voice Detection Stop", VOICE_STOP_DESC, voice_stop_function, VOICE_STOP_USAGE, SAF_NONE);

	/* indicate that the module should continue to be loaded */
	return SWITCH_STATUS_SUCCESS;
}

/* For Emacs:
* Local Variables:
* mode:c
* indent-tabs-mode:nil
* tab-width:4
* c-basic-offset:4
* End:
* For VIM:
* vim:set softtabstop=4 shiftwidth=4 tabstop=4 expandtab:
*/

