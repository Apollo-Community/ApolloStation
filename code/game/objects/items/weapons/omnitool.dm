/*
 * Wrench
 */
/obj/item/weapon/wrench/omni
	name = "omnitool wrench"
	desc = "You shouldn't see this."
	slot_flags = 0

/*
 * Screwdriver
 */
/obj/item/weapon/screwdriver/omni
	name = "omnitool screwdriver"
	desc = "You shouldn't see this."
	slot_flags = 0

/*
 * Wirecutters
 */
/obj/item/weapon/wirecutters/omni
	name = "omnitool wirecutters"
	desc = "You shouldn't see this."
	slot_flags = 0

/*
 * Welding Tool
 */
/obj/item/weapon/weldingtool/omni
	name = "omnitool pocket welder"
	desc = "You shouldn't see this."
	slot_flags = 0
	max_fuel = 6 	//The max amount of fuel the welder can hold

//Toggles the welder off and on
/obj/item/weapon/weldingtool/omni/toggle(var/message = 0)
	if(!status)	return
	src.welding = !( src.welding )
	if (src.welding)
		if (remove_fuel(1))
			usr << "\blue You switch the [src] on."
			src.force = 15
			src.damtype = "fire"
			processing_objects.Add(src)
		else
			usr << "\blue Need more fuel!"
			src.welding = 0
			return
	else
		if(!message)
			usr << "\blue You switch the [src] off."
		else
			usr << "\blue The [src] shuts off!"
		src.force = 3
		src.damtype = "brute"
		src.welding = 0

/*
 * Crowbar
 */

/obj/item/weapon/crowbar/omni
	name = "omnitool prybar"
	desc = "You shouldn't see this."
	slot_flags = 0

/*
 * Knife
 */

/obj/item/weapon/knifetool/omni
	name = "omnitool knife"
	desc = "You shouldn't see this."
	force = 14
	slot_flags = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/*
 * Omnitool
 */

/obj/item/weapon/omnitool
	name = "omnitool"
	desc = "It's like a toolbox in your pocket!"
	icon = 'icons/obj/items.dmi'
	icon_state = "omnitool_closed"
	force = 2
	slot_flags = SLOT_BELT
	flags = CONDUCT
	throwforce = 7
	throw_range = 4
	throw_speed = 3
	w_class = 2
	attack_verb = list("patted", "tapped")
	icon_action_button = "omnitool_action"
	action_button_name = "Switch Tool"
	var/obj/item/weapon/active = null
	var/obj/item/weapon/last_active = null
	var/obj/item/weapon/wrench/wrench
	var/obj/item/weapon/screwdriver/screwdriver
	var/obj/item/weapon/wirecutters/cutters
	var/obj/item/weapon/weldingtool/welder
	var/obj/item/weapon/crowbar/crowbar
	var/obj/item/weapon/knifetool/knife

/obj/item/weapon/omnitool/ui_action_click()
	if( src in usr )
		switch_tool()

/obj/item/weapon/omnitool/New()
	..()
	wrench = new /obj/item/weapon/wrench/omni( src)
	screwdriver = new /obj/item/weapon/screwdriver/omni( src)
	cutters = new /obj/item/weapon/wirecutters/omni( src)
	welder = new /obj/item/weapon/weldingtool/omni( src)
	crowbar = new /obj/item/weapon/crowbar/omni( src)
	knife = new /obj/item/weapon/knifetool/omni( src)

/obj/item/weapon/omnitool/examine()
	..()
	if (active)
		usr << "[active.name] is currently selected."
		usr << "[src.name] contains [welder.get_fuel()]/[welder.max_fuel] units of fuel!"

/obj/item/weapon/omnitool/attack_self(mob/user)
	if (active && !istype(active, /obj/item/weapon/weldingtool))
		last_active = active
		active = null
		update_icon()
	else if (active)
		welder.toggle()
		if(welder.welding)
			icon_state = "omnitool_welder1"
			w_class = 4.0
		else
			icon_state = "omnitool_welder0"
			w_class = 2.0
	else if (last_active)
		active = last_active
		update_icon()
	else
		active = knife
		update_icon()

/obj/item/weapon/omnitool/verb/switch_tool()
	set name = "Switch Tool"
	set category = "Object"
	if(istype(last_active, /obj/item/weapon/crowbar))
		last_active = knife
		active = knife
	else if(istype(last_active, /obj/item/weapon/knifetool))
		last_active = screwdriver
		active = screwdriver
	else if(istype(last_active, /obj/item/weapon/screwdriver))
		last_active = wrench
		active = wrench
	else if(istype(last_active, /obj/item/weapon/wrench))
		last_active = welder
		active = welder
	else if(istype(last_active, /obj/item/weapon/weldingtool))
		last_active = cutters
		active = cutters
	else if(istype(last_active, /obj/item/weapon/wirecutters))
		last_active = crowbar
		active = crowbar
	else
		last_active = knife
		active = knife
	welder.welding = 0
	w_class = 2.0
	update_icon()

/obj/item/weapon/omnitool/update_icon()
	if(!istype(loc, /mob))
		return
	var/mob/user = loc
	playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
	if(istype(active, /obj/item/weapon/knifetool))
		icon_state = "omnitool_knife"
	else if(istype(active, /obj/item/weapon/wrench))
		icon_state = "omnitool_wrench"
	else if(istype(active, /obj/item/weapon/crowbar))
		icon_state = "omnitool_prybar"
	else if(istype(active, /obj/item/weapon/screwdriver))
		icon_state = "omnitool_screwdriver"
	else if(istype(active, /obj/item/weapon/weldingtool))
		icon_state = "omnitool_welder0"
		if (welder.welding)
			icon_state = "omnitool_welder1"
	else if(istype(active, /obj/item/weapon/wirecutters))
		icon_state = "omnitool_cutters"
	else
		icon_state = "omnitool_closed"

/obj/item/weapon/omnitool/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(active)
		return 1
	else
		..()

/obj/item/weapon/omnitool/afterattack(var/atom/target, var/mob/living/user, proximity, params)
	if(!proximity)
		return 0
	if(!active)
		return 0
	active.loc = user
	var/resolved = target.attackby(active,user)
	if(!resolved && active && target)
		active.afterattack(target,user,1)
	if(active)
		active.loc = src

/*
 * Syndietool // Different appearance and text. Slightly more robust.
 */

/obj/item/weapon/omnitool/syndie
	name = "red omnitool"
	desc = "It's like a torture kit in your pocket!"
	icon_state = "synditool_closed"
	force = 5
	attack_verb = list("whacked", "beat")

/obj/item/weapon/omnitool/syndie/New()
	..()
	knife.force = 18
	welder.max_fuel = 12

/obj/item/weapon/omnitool/syndie/update_icon()
	if(!istype(loc, /mob))
		return
	var/mob/user = loc
	playsound(user, 'sound/weapons/flipblade.ogg', 15, 1)
	if(istype(active, /obj/item/weapon/knifetool))
		icon_state = "synditool_knife"
	else if(istype(active, /obj/item/weapon/wrench))
		icon_state = "synditool_wrench"
	else if(istype(active, /obj/item/weapon/crowbar))
		icon_state = "synditool_prybar"
	else if(istype(active, /obj/item/weapon/screwdriver))
		icon_state = "synditool_screwdriver"
	else if(istype(active, /obj/item/weapon/weldingtool))
		icon_state = "synditool_welder0"
	else if(istype(active, /obj/item/weapon/wirecutters))
		icon_state = "synditool_cutters"
	else
		icon_state = "synditool_closed"

/obj/item/weapon/omnitool/attack_self(mob/user)
	if (active && !istype(active, /obj/item/weapon/weldingtool))
		last_active = active
		active = null
	else if (active)
		welder.toggle()
	else if (last_active)
		active = last_active
	else
		active = knife
	update_icon()