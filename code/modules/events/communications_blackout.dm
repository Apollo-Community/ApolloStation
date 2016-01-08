/datum/event/communications_blackout/announce()
	var/alert = pick(	"Electrical anomalies detected. Temporary telecommunication failure imminent. Engineering personnel must repai-*%fj00)`5vc-BZZT", \
						"Electrical anomalies detected. Temporary telecommunication failu*3mga;b4;'1v¬-BZZZT", \
						"Electrical anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT", \
						"Electrical anomalies dete'fZ\\kg5_0-BZZZZZT", \
						"Electrica:%£ MCayj^j<.3-BZZZZZZT", \
						"#4nd%;f4y6,>£%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		A << "<br>"
		A << "<span class='warning'><b>[alert]</b></span>"
		A << "<br>"

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		command_announcement.Announce(alert, "AUTOMATED ALERT: Electrical Anomaly", new_sound = 'sound/misc/interference.ogg')

/datum/event/communications_blackout/start()
	communications_blackout()

/proc/communications_blackout(var/silent = 1)
	if(!silent)
		command_announcement.Announce("Electrical anomalies detected. Temporary telecommunication failure imminent. Engineering personnel must repai-", "AUTOMATED ALERT: Electrical Anomaly", new_sound = 'sound/misc/interference.ogg')
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)
