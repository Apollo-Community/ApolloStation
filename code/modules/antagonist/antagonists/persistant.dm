/datum/antagonist/traitor/persistant/setup(var/skip_greet=0)
	if(faction)
		faction_controller.join_faction(antag, faction)
	else
		faction_controller.get_syndie_faction(antag)

	if(!faction) // we need a faction
		message_admins("[antag.key]/([antag.current.real_name]) was made an antagonist, but failed to get a faction.")
		antag.antagonist = null
		ticker.mode.traitors -= antag
		qdel(src)
		return 0

	// notify any other agents in their faction about a new agent
	if(faction.friendly_identification == FACTION_ID_COMPLETE)
		for(var/datum/mind/M in (faction.members - antag))
			M.current << "Your employers have notified you that a fellow [faction.name] agent has been activated:"
			M.current << "<B>[M.current.real_name]</B>, [station_name] [M.assigned_role]"

	if(ticker.contracts_made) // for antags that are created mid-round, after the contracts have been made available
		pick_contracts()
		antag.current << "" // newline

	// greet the antagonist and give them any info concerning their task(s)
	if(!skip_greet)
		greet()

	equip()
