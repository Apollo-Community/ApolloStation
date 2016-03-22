/datum/antagonist/traitor
	name = "Traitor"
	greeting = "You are a traitor."
	
/datum/antagonist/traitor/equip()
	var/mob/living/M = antag.current

	var/backpack = locate(/obj/item/weapon/storage/backpack) in M.contents
	if(backpack)
		new /obj/item/weapon/card/emag/weak(backpack)
		M << "Your employer has provided you with an Encryptic Sequencer in your backpack."

	var/obj/item/I = locate(/obj/item/device/pda) in antag.current.contents

	if(antag.character.uplink_location == "Headset" && locate(/obj/item/device/radio) in antag.current.contents)
		I = locate(/obj/item/device/radio) in antag.current.contents

	if(!I)	return
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