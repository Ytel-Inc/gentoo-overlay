
function on_input(a, b, c, d)
{
	var amd_result = b.getHeader("amd_result");
	var amd_status = b.getHeader("amd_status");
	var body = b.getBody();

	console_log("input: " + a + ":" + b +":" + c + " - " + body + " - ar: " + amd_result + " - as: " + amd_status + " *************\n");

	session.setVariable("Cause-Result", amd_result +"|" + amd_status);

	if (amd_status == "machine")
	{
		return "restart";
	}

}

//2007-11-22 00:30:06 [NOTICE] switch_core_state_machine.c:134 switch_core_standard_on_execute() Execute javascript(pvscid.js)
//2007-11-22 00:30:06 [DEBUG] pvscid.js:1 console_log() VOX - state: CS_EXECUTE result: false
//2007-11-22 00:30:06 [DEBUG] pvscid.js:1 console_log() time_elapsed: false milliseconds
//2007-11-22 00:30:06 [DEBUG] pvscid.js:1 console_log() samples_elapsed: false samples
//2007-11-22 00:30:06 [DEBUG] pvscid.js:1 console_log() bye CS_EXECUTE
//waitForAnswer();
console_log("VOX - state: " + session.state + " result: " + session.getVariable("amd_result") + "\n");
//console_log("time_elapsed: " + session.getVariable("amd_time_elapsed") + " milliseconds\n");
//console_log("samples_elapsed: " + session.getVariable("amd_samples_elapsed") + " samples\n");

var samples_elapsed = session.getVariable("amd_samples_elapsed");
var result = session.getVariable("amd_result");

if (!samples_elapsed)
	samples_elapsed = 0;

//session.info();

if (result == "timeout")
{
        // Session Timed Out 
        session.hangup();

} else if (result == "audio_failure") {

        // Audio Failure 
        session.hangup();

} else if (result == "break_digit") {

        // Digits 
        session.streamFile("/root/13-vista-track-1.wav", on_input, "wee", 0);

} else if (result == "person") {

        // Is a Person 
        session.streamFile("/root/13-vista-track-1.wav", on_input, "wee", 0);

} else if (result == "machine") {

        // Is a Machine 
        session.streamFile("/root/13-vista-track-1.wav", on_input, "wee", 0);

} else {

	// No result .. no AMD
        session.streamFile("/root/13-vista-track-1.wav", on_input, "wee", 0);
}


console_log("bye " + session.state + "\n");
session.hangup();


