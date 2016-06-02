/obj
	//Used to store information about the contents of the object.
	var/list/matter

	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/sharp = 0		// whether this object cuts
	var/edge = 0		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0
	var/buildstage = 0
	var/panel_open = 0
	var/base_name = ""

/obj/Destroy()
	processing_objects -= src
	..()

/obj/Topic(href, href_list, var/nowindow = 0)
	// Calling Topic without a corresponding window open causes runtime errors
	if(nowindow)
		return 0
	return ..()

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/process()
	processing_objects.Remove(src)
	return 0

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot) || (isobserver(usr) && check_rights(R_ADMIN|R_MOD)))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if (istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	src.machine = null

/mob/proc/set_machine(var/obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return


/obj/proc/hear_talk(mob/M as mob, text, verb, datum/language/speaking)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
		*/
	return

/obj/proc/see_emote(mob/M as mob, text, var/emote_type)
	return

/obj/proc/attackby_construction(obj/item/I as obj, mob/user as mob, var/m_icon_state)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(buildstage == 2)
			default_deconstruction_screwdriver(user,"[m_icon_state]_frame_wired","[m_icon_state]",I)
			return 1
		else
			user << "There is no panel to open or close yet."
			return 1

	else if(panel_open == 1)
		switch(buildstage)
			if(2)
				if(istype(I, /obj/item/weapon/crowbar))
					user << "You pry out the circuitboard!"
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					spawn(1)
						var/type = text2path("/obj/item/weapon/[src.base_name]_electronics")
						var/obj/item/weapon/S = new type()
						S.loc = user.loc
						buildstage = 1
					return 1

			if(1)
				if (istype(I, /obj/item/weapon/wirecutters))
					user.visible_message("<span class='alert'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					var/obj/item/stack/cable_coil/S = new /obj/item/stack/cable_coil()
					S.amount = 2
					S.icon_state = "coil2"
					S.loc = user.loc
					buildstage = 0
					return 1

				else if(istype(I, text2path("/obj/item/weapon/[src.base_name]_electronics")))
					qdel(I)
					user.visible_message("<span class='alert'>[user] You put the circuitboard inside \the [src].</span>", "You put the circuitboard inside \the [src] finishing it.")
					buildstage = 2
					return 1
			if(0)
				if(istype(I, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/C = I
					if (C.use(2))
						user << "<span class='notice'>You wire \the [src].</span>"
						buildstage = 1
						return 1
					else
						user << "<span class='warning'>You need 2 pieces of cable to do wire \the [src].</span>"
						return 1
				if(istype(I, /obj/item/weapon/wrench))
					user << "You remove the fire alarm assembly from the wall!"
					var/obj/item/intercom_frame/frame = new /obj/item/intercom_frame()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
					return 1
		update_build_icon(m_icon_state)
		return 0
	return 0

obj/proc/default_deconstruction_screwdriver(var/mob/user, var/icon_state_open, var/icon_state_closed, var/obj/item/weapon/screwdriver/S)
	if(istype(S))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			icon_state = icon_state_open
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = icon_state_closed
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return 1
	return 0

obj/proc/update_build_icon(m_icon_state)
	switch(buildstage)
		if(0)
			icon_state = "[base_name]_frame"
		if(1)
			icon_state = "[base_name]_frame_wired"
		if(2)
			if(panel_open)
				icon_state = "[base_name]_frame_wired"