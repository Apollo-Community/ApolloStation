/obj/item/weapon/doorjack
	name = "door jack"
	desc = "Funnily enough, this is actually used to open airlocks."
	icon = 'icons/obj/items.dmi'
	icon_state = "jack_retracted"
	var/obj/machinery/door/airlock/door = null

/obj/item/weapon/doorjack/attack_hand(var/mob/user)
	if(isnull(door))
		return ..(user)
	..(user)
	user << "You carefully retract the door jack and remove it from the airlock."
	icon_state = "jack_retracted"
	anchored = 0
	door.autoclose = 1
	door.close()
	door = null