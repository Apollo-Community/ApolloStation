/datum/antagonist/traitor
	name = "Traitor"
	greeting = "You are a traitor."
	
/datum/antagonist/traitor/equip()
	var/mob/living/M = antag.current

	var/backpack = locate(/obj/item/weapon/storage/backpack) in M.contents
	if(backpack)
		new /obj/item/weapon/card/emag/weak(backpack)
		M << "Your employer has provided you with an Encryptic Sequencer in your backpack."

	