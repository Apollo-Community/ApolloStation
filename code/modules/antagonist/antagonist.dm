/*
	As of the antagonist update, all antagonists are now handled via antagonist datums!
	Antagonist take /datum/contracts, and are rewarded for successful completion.
*/

/datum/antagonist
	var/name = "Antagonist" 							// Name of the type of antagonist (Changeling, traitor, etc.)
	var/greeting = "You are an antagonist." 			// Shown when the antag is setup, informing them they're an antagonist
	var/can_buy = 1										// Whether or not the antagonist can use the uplink market
	var/obligatory_contracts = 1 						// How many contracts the antagonist is forced to take from round start
	var/list/datum/contract/active_contracts = list() 	// Currently active contracts for the antagonist
	var/notoriety = 0

	var/datum/faction/syndicate/faction = null // Defining this (type path) in the antagonist datum will force all antagonists of that type to be part of this faction
	var/list/datum/contract/completed_contracts = list()
	var/list/datum/contract/failed_contracts = list()
	var/datum/mind/antag = null

	var/uplink_blocked = 0 // adminbuse var

	// fun facts for the round end, but could also be used for statistics?
	var/money_spent = 0

/datum/antagonist/New( var/datum/mind/us )
	..()

	if(!us) // who the fuck am i?
		log_debug("A new antagonist was made, but it doesn't know what mind it belongs to!")

	antag = us

/datum/antagonist/Destroy()
	..()

	for(var/datum/contract/C in active_contracts)
		C.workers -= antag.current

	faction_controller.leave_faction(antag, faction)

// This randomizes the antag character, used for any non-persistant antags
/datum/antagonist/proc/randomize_character()
	if( !antag.original_character )
		antag.original_character = antag.current.client.prefs.selected_character

	var/datum/character/C = new( antag.current.client.ckey )
	C.randomize_appearance( 1 )
	antag.current.client.prefs.selected_character.copy_metadata_to( C )
	C.temporary = 1
	antag.current.client.prefs.selected_character = C

	// for latespawns
	if( istype( antag.current, /mob/living ))
		C.copy_to( antag.current )
		antag.current.fully_replace_character_name(antag.original_character.name, antag.current.name)

	antag.current << "<span class='ooc_notice'>You are a non-persistent antagonist and have received a randomized character!</span>"

/datum/antagonist/proc/setup(var/skip_greet=0)
	if(faction) 
		faction = faction_controller.join_faction(antag, faction)
	else
		faction = faction_controller.get_syndie_faction(antag)

	if(!faction) // we need a faction
		message_admins("[antag.key]/([antag.current.real_name]) was made an antagonist, but failed to get a faction.")
		antag.antagonist = null
		ticker.mode.traitors -= antag
		qdel(src)
		return 0

	notoriety = antag.character.antag_data["notoriety"]

	// greet the antagonist and give them any info concerning their task(s)
	if(!skip_greet)
		greet()

	equip()

/datum/antagonist/proc/greet()
	antag.current << "<B><font size=3 color=red>[greeting]</font></B>"
	antag.current << "<B><font size=2 color=red>You are working for \The [faction.name].</font></B>"
	antag.current << "[faction.operative_notes]"
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

	// How many contracts you have to complete
	if(obligatory_contracts)
		antag.current << "[faction.name] has ordered you to complete <B>at least [obligatory_contracts] contracts</B> during this shift."
	else
		antag.current << "[faction.name] has given you free reigns. They are not expecting you to complete any contracts this shift."

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