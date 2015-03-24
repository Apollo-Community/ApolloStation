/*

	The blacksmiths forge, used in the weapons research lab. This machine adds an orange glow to metals added to it that dissapates over time.

*/

/obj/machinery/forge
	name = "Blacksmiths Forge"
	desc = "An elegant machine that can superheat metals into a malleable form"
	icon = 'icons/obj/machines/weapon_lab.dmi'
	icon_state = "forge_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	var/on = 0
	var/obj/item/forge/heated_metal/heating = null


	var/set_temperature = T20C
	var/max_temperature = T20C + 1980 				//2000c        steel melts @ 1400c , iron melts @ 1500c

	var/max_power_rating = 20000	//power rating when the usage is turned up to 100
	var/power_setting = 100

/obj/machinery/forge/update_icon()
	if(on)
		icon_state = "forge_on"
	else
		icon_state = "forge_off"

/obj/machinery/forge/examine()
	..()
	if(heating)
		usr << "It appears that [heating] is glowing red hot"

/obj/machinery/forge/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/forge/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]
	data["on"] = on ? 1 : 0
	data["minTemperature"] = 0
	data["maxTemperature"] = round(max_temperature)
	data["targetTemperature"] = round(set_temperature)

	var/temp_class = "bad"

	if(heating)
		data["name"] = heating.name
		data["nameclass"] = "good"
		data["desc"] = heating.desc
		data["Temperature"] = round(heating.temperature)
		data["matter"] = heating.matter["metal"]
		if (heating.temperature > (T20C+1300))
			temp_class = "good"

		switch(heating.temperature)
			if(T0C to T0C+200)			data["state"] = "A hunk of metal"
			if(T0C+200 to T0C+350)		data["state"] = "[heating.name] begins to appear blue"
			if(T0C+350 to T0C+650)		data["state"] = "[heating.name] begins to turn red"
			if(T0C+650 to T0C+900)		data["state"] = "[heating.name] begins to turn bright orange"
			if(T0C+900 to T0C+1100)		data["state"] = "[heating.name] begins to turn bright yellow"
			else						data["state"] = "[heating.name] is glowing!"
	else
		data["Temperature"] = round(T0C)
		data["name"] = "Nothing is in the furnace"
		data["desc"] = ""
		data["state"] = ""
		data["matter"] = ""
		data["nameclass"] = "bad"

	data["TemperatureClass"] = temp_class


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "forge.tmpl", "Forge", 500, 300)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/forge/Topic(href, href_list)
	if (href_list["toggleStatus"])
		on = !on
		update_icon()
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.set_temperature = min(src.set_temperature+amount, max_temperature)
		else
			src.set_temperature = max(src.set_temperature+amount, 0)

	src.add_fingerprint(usr)
	return 1

/obj/machinery/forge/process()
	..()

	if(!on)
		if(heating)
			heating.temperature = min(heating.temperature - rand(5), 500+rand(75))			//if forge is off but item is still inside, decay slightly
		return

	if(heating)
		if(set_temperature >= heating.temperature - 100)			// Need some wiggle room
			heating.temperature = min(heating.temperature + (set_temperature * 0.03), set_temperature+rand(25))
		else
			heating.temperature = min(heating.temperature - rand(5), 500+rand(75))			// Got some wierd behaviour with it dropping 100's of degrees in a second without this

/obj/machinery/forge/attackby(obj/item/I, mob/user)
	//Allows you to get the metal out with tongs.
	if(istype(I, /obj/item/weapon/tongs))
		if(on)
			usr << "\blue You worry you will burn your hands with those raging flames."
			return
		if(heating)
			var/obj/item/weapon/tongs/T = I
			var/obj/item/forge/heated_metal/S = heating
			T.held = S
			S.loc = T
			T.icon_state = "tongs_heated"

			if(S.temperature > T20C+20)
				//Sets up the metal.
				S.l_color = "#FF704D"
				S.SetLuminosity(4)

				S.color = "#FF704D"

			playsound(loc, 'sound/effects/tong_pickup.ogg', 50, 1, -1)

			heating = null
			on = 0
			return
		else
			//They need to load superheated metal back into the forge
			var/obj/item/weapon/tongs/T = I
			heating = new()
			heating.name = T.held.name
			heating.icon = T.held.icon
			heating.icon_state = T.held.icon_state
			heating.matter = T.held.matter
			heating.desc = T.held.desc
			heating.loc = src
			T.held = null
			T.icon_state = "tongs"

//Only accepts objects with metal in their matter list
	if(I.matter)
		if(I.matter.Find("metal"))
			usr << "You put [I.name] into the forge."
			user.drop_item()
			heating = new()
			heating.name = I.name					// only copy the important stuff --
			heating.icon = I.icon
			heating.icon_state = I.icon_state
			heating.matter = I.matter
			heating.desc = I.desc
			heating.loc = src
			del(I)
			return

	usr << "You don't feel that [I.name] is suitable for heating."

/obj/item/forge/heated_metal
	name = "Forge superheated object holder"
	desc = "If you can see this description the code for the forge fucked up."
	icon = 'icons/obj/weapons_lab.dmi'
	icon_state = "holder_bar"
	origin_tech = "combat=2;materials=2"

	var/temperature = T20C

/obj/item/forge/heated_metal/ignot
	name = "Metal Ignot"
	desc = "A bar of superheated metal"
	icon_state = "metal_ignot"
	origin_tech = "materials=3"
	matter = list("metal" = 450)

/obj/item/forge/heated_metal/process()
	if(temperature > 0)
		temperature -= 2+rand(4)
	else
		//sends a message to people in view range
		for(var/mob/M in viewers(src, null))
			M.show_message("\red The [src.name] has cooled down and reverts to its original form.")

		SetLuminosity(0)
		color = null
		temperature = 0
		processing_objects -= src

/obj/item/forge/heated_metal/pickup(mob/living/user)
	if(temperature > T20C+20)
		//only an idiot would pick up a superheated chunk of metal -sigh-
		user << "\red <B>You pick-up the [src.name]!</B>"
		user.adjustFireLoss(temperature / 50)
		user << "\red <B>Your hands burn!</B>"
		if(temperature > T20C+40)		//Just for you kwaky..
			user.drop_item()
			user.emote("scream")

/obj/item/forge/heated_metal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype( W, /obj/item/weapon/tongs ))
		var/obj/item/weapon/tongs/T = W
		T.pick_up( src )
		T.icon_state = "tongs_heated"
		return

	..()