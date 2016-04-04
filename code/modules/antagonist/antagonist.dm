/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take /datum/contracts, and are rewarded for successful completion.
*/

/datum/antagonist
	var/name = "Antagonist" 							// Name of the type of antagonist (Changeling, traitor, etc.)
	var/greeting = "You are an antagonist." 			// Shown when the antag is setup, informing them they're an antagonist
	var/obligatory_contracts = 1 						// How many contracts the antagonist is forced to take from round start
	var/list/datum/contract/active_contracts = list() 	// Currently active contracts for the antagonist
	var/notoriety = 0

	var/datum/faction/syndicate/faction = null // Defining this (type path) in the antagonist datum will force all antagonists of that type to be part of this faction
	var/list/datum/contract/completed_contracts = list()
	var/list/datum/contract/failed_contracts = list()
	var/datum/mind/antag = null

	// fun facts for the round end, but could also be used for statistics?
	var/money_spent = 0

/datum/antagonist/New( var/datum/mind/us )
	..()

	if(!us) // who the fuck am i?
		log_debug("A new antagonist was made, but it doesn't know what mind it belongs to!")

	antag = us

// This randomizes the antag character, used for any non-persistant antags
/datum/antagonist/proc/randomize_character()
	var/datum/character/C = new( antag.current.client.ckey )
	C.randomize_appearance( 1 )
	antag.current.client.prefs.selected_character.copy_metadata_to( C )
	C.temporary = 1
	antag.current.client.prefs.selected_character = C

	if( istype( antag.current, /mob/living/carbon/human ))
		C.copy_to( antag.current ) // for latespawns

/datum/antagonist/proc/setup(var/skip_greet=0)
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

	notoriety = antag.character.antag_data["notoriety"]

	// notify any other agents in their faction about a new agent
	if( world.time > ( ticker.game_start + 100 )) // hacky hacks
		if(faction.friendly_identification == FACTION_ID_COMPLETE)
			for(var/datum/mind/M in (faction.members - antag))
				M.current << "Your employers have notified you that a fellow [faction.name] agent has been activated:"
				M.current << "<B>[M.current.real_name]</B>, [station_name] [M.assigned_role]"

	// greet the antagonist and give them any info concerning their task(s)
	if(!skip_greet)
		greet()

	equip()

/datum/antagonist/proc/greet()
	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	antag.current << "<B><font size=2 color=red>You are working for \The [faction.name].</font></B>"
	if(!ticker.contracts_made)
		antag.current << "You are a sleeper cell agent, and your employer has recently ordered you to <B>stand by for further instructions</B>."
	else
		antag.current << "Your services have been requested <B>now</B>."
	antag.current << ""

	switch(faction.friendly_identification)
		if(FACTION_ID_PHRASE)
			antag.current << "\The [faction.name] has provided all its agents with the following code phrases to identify other agents:"
			antag.current << "<B>[list2text(faction.phrase, ", ")]</B>"
			antag.current << ""
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

// Equip the antagonist here
/datum/antagonist/proc/equip()
	return

/datum/antagonist/proc/contract_start(var/datum/contract/C)
	active_contracts += C

/datum/antagonist/proc/contract_ended(var/datum/contract/C, var/success = 0)
	active_contracts -= C
	if(success)
		completed_contracts += C
	else
		failed_contracts += C

	var/obj/item/I = locate(/obj/item/device/pda) in antag.current.contents

	if(antag.character.uplink_location == "Headset" && locate(/obj/item/device/radio) in antag.current.contents)
		I = locate(/obj/item/device/radio) in antag.current.contents

	if(!I)	return
	if(istype(I, /obj/item/device/radio))
		antag.current << "<span class='notice'>You feel your headset vibrate.</span>"
	else
		antag.current << "<span class='notice'>You feel your PDA vibrate.</span>"