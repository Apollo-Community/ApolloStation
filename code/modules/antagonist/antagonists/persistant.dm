/datum/antagonist/traitor/persistant
	name = "Autonomous Agent"
	greeting = "You are an autonomous agent."
	obligatory_contracts = 0

/datum/antagonist/traitor/persistant/New(var/datum/mind/us, var/datum/faction/syndicate/join_faction)
	..(us)

	faction = join_faction

/datum/antagonist/traitor/persistant/greet()
	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	antag.current << "<B><font size=2 color=red>You are working for \The [faction.name].</font></B>"
	antag.current << "[faction.operative_notes]"
	antag.current << "You are an autonomous agent, and your employer has recently ordered you to <B>stand by for further instructions</B>."
	antag.current << ""

	switch(faction.friendly_identification)
		if(FACTION_ID_PHRASE)
			antag.current << "\The [faction.name] has provided all its agents with the following code phrases to identify other agents:"
			antag.current << "<B>[list2text(faction.phrase, ", ")]</B>"
			antag.current << ""

			antag.current.trigger_words += faction.phrase
		if(FACTION_ID_COMPLETE)
			if((faction.members.len - 1) > 0)
				antag.current << "\The [faction.name] has provided all its agents with the identity of their fellow agents. Your co-workers are as follows:"
				for(var/datum/mind/M in (faction.members - antag))
					if( !istype( M.antagonist, /datum/antagonist/traitor/persistant))
						antag.current << "<B>[M.current.real_name]</B>, [station_name] [M.assigned_role]"
			else
				antag.current << "\The [faction.name] has informed you that <B>you are the only active [faction.name] agent on [station_name]</B>."
			antag.current << ""

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != antag.current)
		antag.current << "There are credible reports claiming that <B>[M.real_name]</B> might be willing to help our cause. If you need assistance, consider contacting them."
		antag.current.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")
		antag.current << ""
