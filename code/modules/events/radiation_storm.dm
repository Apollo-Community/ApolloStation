/datum/event/radiation_storm
	var/const/enterBelt		= 30
	var/const/radIntervall 	= 5	// Enough time between enter/leave belt for 10 hits, as per original implementation
	var/const/leaveBelt		= 80
	var/const/revokeAccess	= 135
	announceWhen			= 1
	endWhen					= revokeAccess
	var/postStartTicks 		= 0

/datum/event/radiation_storm/announce()
//	command_announcement.Announce("High levels of radiation detected near the station. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert", new_sound = 'sound/AI/radiation.ogg')

/datum/event/radiation_storm/start()
	spawn()
		command_announcement.Announce("High levels of radiation have been detected. Please evacuate into one of the shielded maintenance tunnels.", "AUTOMATED ALERT: Radiation Anomaly", new_sound = 'sound/AI/radiation.ogg')
		sleep(rand(60,600))
		make_maint_all_access()

/datum/event/radiation_storm/tick()
	if(activeFor == enterBelt)
		command_announcement.Announce("The station has entered the radiation belt. Please remain in a sheltered area until we have passed the radiation belt.", "AUTOMATED ALERT: Radiation Anomaly")
		radiate()
		change_space(list("#00ff99", "#00ff00", "#33cc33", "#66ff33", "#99ff66"))

	if(activeFor >= enterBelt && activeFor <= leaveBelt)
		postStartTicks++

	if(postStartTicks == radIntervall)
		postStartTicks = 0
		radiate()
		for(var/obj/machinery/power/rad_collector/R in rad_collectors)
			R.receive_pulse(200)

	else if(activeFor == leaveBelt)
		command_announcement.Announce("The station has passed the radiation belt. Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly.", "AUTOMATED ALERT: Radiation Anomaly")
		change_space()

/datum/event/radiation_storm/proc/change_space(var/list/col)
	for(var/turf/space/s in world)
		if(!s.z in overmap.station_levels)	continue
		if(!(.++%100))	sleep(rand(0,world.tick_lag))		//so it doesn't appear/dissapear all at once
		if(col)			s.color = pick(col)
		else			s.color = null

/datum/event/radiation_storm/proc/radiate()
	for(var/mob/living/carbon/C in living_mob_list)
		var/area/A = get_area(C)
		if(!A)
			continue
		if(!(A.z in overmap.station_levels))
			continue
		if(A.rad_shielded)
			continue

		if(istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			H.apply_effect((rand(15,35)),IRRADIATE,0)
			if(prob(5))
				H.apply_effect((rand(40,70)),IRRADIATE,0)
				if (prob(75))
					randmutb(H) // Applies bad mutation
					domutcheck(H,null,MUTCHK_FORCED)
				else
					randmutg(H) // Applies good mutation
					domutcheck(H,null,MUTCHK_FORCED)

/datum/event/radiation_storm/end()
	revoke_maint_all_access()
