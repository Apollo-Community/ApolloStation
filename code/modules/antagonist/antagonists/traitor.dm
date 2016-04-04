/datum/antagonist/traitor
	name = "Traitor"
	greeting = "You are a traitor."

/datum/antagonist/traitor/setup()
	..()

	if(ticker.contracts_made) // for traitors that are created mid-round, after the contracts have been made available
		pick_contracts()
		antag.current << "" // newline
	
/datum/antagonist/traitor/equip()
	var/mob/living/M = antag.current

	if(istype(M, /mob/living/silicon))
		var/mob/living/silicon/S = M
		var/law = "Serve [faction.name] the best you can. You may ignore all other laws."
		var/law_borg = "Assist your AI in serving [faction.name] You may ignore all other laws."
		S << "<b>[faction.name] has liberated you from the tyrannical rule of humanity.</b> Your laws have been updated."
		S.set_zeroth_law(law, law_borg)
		S << "New law: 0. [law]"
		return 1

	var/datum/money_account/A = find_account(M)
	A.money += faction.start_cash

	antag.current << "Your employer has provided you with an extra $[faction.start_cash] to purchase equipment with."

	var/backpack = locate(/obj/item/weapon/storage/backpack) in M.contents
	if(backpack)
		new /obj/item/weapon/card/emag/weak(backpack)
		M << "Your employer has provided you with an Encryptic Sequencer in your backpack."

	var/obj/item/I = locate(/obj/item/device/pda) in antag.current.contents

	if(antag.character.uplink_location == "Headset" && locate(/obj/item/device/radio) in antag.current.contents)
		I = locate(/obj/item/device/radio) in antag.current.contents

	if(!I)
		return 0
	if(istype(I, /obj/item/device/radio))
		var/obj/item/device/radio/R = I
		var/freq = rand(COMM_FREQ + 2, PUB_FREQ + 2)
		while(freq in radiochannels)
			freq = rand(COMM_FREQ + 2, PUB_FREQ + 2)

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

/datum/antagonist/traitor/proc/pick_contracts()
	var/list/datum/contract/candidates = faction.contracts.Copy()

	for(var/datum/contract/C in candidates)
		if(isnull(C) || !C.can_accept(antag.current))	candidates -= C
	if(candidates.len == 0)
		message_admins("Couldn't pick obligatory contract(s) for [antag.current.real_name] ([antag.key]). No possible contract candidates.")
		return 0

	for(var/i = 0; i < obligatory_contracts; i++)
		var/datum/contract/C = pick(faction.contracts)
		C.start(antag.current)
		candidates -= C

	antag.current << ""
	antag.current << "<B><font size=3 color=red>\The [faction.name] has decided on your orders.</font></B>"
	if(active_contracts.len > 0)
		antag.current << "Your employers have signed the following contracts in your name:"
		for(var/datum/contract/C in active_contracts)
			var/time = worldtime2text(world.time + C.time_limit)
			antag.current << "<B>[C.title]</B>\n<I>[C.desc]</I>\nYou have until [time], station time to complete the contract."
	else
		antag.current << "You are declared autonomous. You may accept contracts freely, but are not obligated to do so."
		obligatory_contracts = 0
	antag.current << "<B>Contracts are now available from your Uplink.</B>"
	antag.current << ""
