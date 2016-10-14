/datum/event/grav_event	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grav_event/setup()
	endWhen = rand(60,120)

/datum/event/grav_event/start()
	for(var/area/A in world)
		A.gravitychange(0,A)

/datum/event/grav_event/announce()
	command_announcement.Announce("Feedback surge detected in mass-distributions systems. Artifical gravity has been disabled whilst the system reinitializes. Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day.")

/datum/event/grav_event/end()
	command_announcement.Announce("Gravity generators are again functioning within normal parameters. Sorry for any inconvenience.")
	for(var/area/A in world)
		A.gravitychange(1,A)