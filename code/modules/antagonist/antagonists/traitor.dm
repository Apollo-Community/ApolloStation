/datum/antagonist/traitor
	name = "Traitor"
	greeting = "You are a traitor."
	obligatory_contracts = 2

/datum/antagonist/traitor/equip()
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

	var/backpack = locate(/obj/item/weapon/storage/backpack) in M.contents
	if(backpack)
		new /obj/item/weapon/card/emag/weak(backpack)
		M << "Your employer has provided you with an Encryptic Sequencer in your backpack."

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
