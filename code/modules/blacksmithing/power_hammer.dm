/*
	Power hammer - used for converting metal objects into weapon shapes.

	TODO: Get weapon sprites


*/

/obj/machinery/power_hammer
	name = "Power Hammer"
	desc = "A large machine capable of smashing down with forces up to 3 tonnes"
	icon = 'icons/obj/machines/weapon_lab.dmi'
	icon_state = "hammer_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = 0

/obj/machinery/power_hammer/examine()
	..()
	if(on)
		usr << "The power hammer is currently in-use"

/obj/machinery/power_hammer/attackby(obj/item/I, mob/user)				// <== this item is getting more and more convoluted >.>
	user << "You put [I.name] on the power hammer"
	user.drop_item()
	I.loc = src

	if(istype(I, /obj/item/forge/heated_metal))
		var/obj/item/forge/heated_metal/S = I
		if(S.temperature)
			user.anchored = 1			//stop them moving
			on = 1
			sleep(100)

			user << "YEW WIN SOMETHAN"
			//TODO: make an input box for the weapon shapes.

			user.anchored = 0
			on = 0
		else
			user << "It looks like the [I.name] has cooled down. I'll need to heat it up again before shaping it."
			user.put_in_hands(I)
			return
	else
		user << "\blue You place [I.name] into the power hammer and turn the machine on."
		user.anchored = 1
		on = 1
		sleep(150)	//make those smart asses wait a little longer!

		//handles people putting things other than superheated bars in.
		if(I.matter)
			if(I.matter.Find("metal"))
				user << "After hammering a little you are left with a clump of metal, you feel dissapointed you didn't make something better."
				var/obj/item/forge/scrap_metal/S = new(get_turf(src))
				S.matter = I.matter
				user.put_in_hands(S)
				del(I)
				return
			else if(I.matter.Find("glass"))
				user << "[I.name] shattered after the first strike, but you kept on smashing to let out some rage. You might have a problem."
				var/obj/item/weapon/shard/S = new(get_turf(src))
				user.put_in_hands(S)
				del(I)
				return

		user << "You smashed [I.name] up so good you're just left with a pile of dust now."
		var/obj/effect/decal/cleanable/ash/S = new(get_turf(src))
		S.name = "Dust"
		user.put_in_hands(S)

		user.anchored = 0
		on = 0

		del(I)
