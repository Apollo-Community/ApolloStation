/var/global/spacevines_spawned = 0

/datum/event/spacevine/start()
	//Announce the vines as a level 5
	command_announcement.Announce("Confirmed Level 5 biohazard within the station. All personnel must contain the outbreak.", "Biohazard Alert", new_sound = 'sound/AI/outbreak5.ogg')
	//biomass is basically just a resprited version of space vines
	if(prob(50))
		spacevine_infestation()
	else
		biomass_infestation()
	spacevines_spawned = 1