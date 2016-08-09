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

// persistant antags only get the uplink
/datum/antagonist/traitor/persistant/equip()
	var/mob/living/M = antag.current

	if(istype( M, /mob/living/silicon ))
		var/mob/living/silicon/S = M
		var/law = "Serve [faction.name] the best you can. You may ignore all other laws."
		var/law_borg = "Assist your AI in serving [faction.name] You may ignore all other laws."
		S << "<b>[faction.name] has liberated you from the tyrannical rule of humanity.</b> Your laws have been updated."
		S.set_zeroth_law(law, law_borg)
		S << "New law: 0. [law]"
		return 1

	var/datum/money_account/A = find_account(M)

	if( !A )
		A = create_account( M.real_name, rand( 500, 1500 ))

	A.money += faction.start_cash
	antag.current << "Your employer has provided you with an extra $[faction.start_cash] to purchase equipment with."

	var/obj/item/I = locate(/obj/item/device/pda) in antag.current.contents

	if(antag.character && antag.character.uplink_location == "Headset" && locate(/obj/item/device/radio) in antag.current.contents)
		I = locate(/obj/item/device/radio) in antag.current.contents

	if(!I)
		return 0
	if(istype(I, /obj/item/device/radio))
		var/obj/item/device/radio/R = I
		var/freq = rand(1441, 1489)
		while(freq in radiochannels)
			freq = rand(1441, 1489)

		var/obj/item/device/uplink/hidden/T = new(I)
		T.uplink_owner = antag
		R.hidden_uplink = T
		R.traitor_frequency = freq

		antag << "An Uplink interface has been installed in your [R.name]. Dial the frequency [format_frequency(freq)] to access it."
		antag.store_memory("<B>Uplink Access Frequency:</B> [format_frequency(freq)] ([R.name]]).")
	else
		var/obj/item/device/pda/P = I
		var/pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

		var/obj/item/device/uplink/hidden/T = new(I)
		T.uplink_owner = antag
		P.hidden_uplink = T
		P.lock_code = pass

		antag.current << "An Uplink interface has been installed in your [P.name]. Enter the code \"[pass]\" into the ringtone select to access it."
		antag.store_memory("<B>Uplink Access Passcode:</B> [pass] ([P.name]).")
