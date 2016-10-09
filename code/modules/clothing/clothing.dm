/obj/item/clothing
	name = "clothing"
	siemens_coefficient = 0.9
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots
	var/list/starting_accessories
	var/list/species_restricted = null //Only these species can wear this kit.
	var/list/accessories = list()
	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null

//Updates the icons of the mob wearing the clothing item, if any.
/obj/item/clothing/proc/update_clothing_icon()
	return

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M as mob, slot)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(species_restricted && istype(M,/mob/living/carbon/human))
		var/exclusive = null
		var/wearable = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = 1
			else
				if(H.species.name in species_restricted)
					wearable = 1

			if(!wearable && !(slot in list(slot_l_store, slot_r_store, slot_s_store)))
				H << "<span class='danger'>Your species cannot wear [src].</span>"
				return 0
	return 1

/obj/item/clothing/proc/refit_for_species(var/target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		if("Human", "Skrell")	//humanoid bodytypes
			species_restricted = list("exclude","Unathi","Tajara","Diona","Vox", "Xenomorph", "Xenomorph Drone", "Xenomorph Hunter", "Xenomorph Sentinel", "Xenomorph Queen","Wryn")
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/obj/item/clothing/head/helmet/refit_for_species(var/target_species)
	if(!species_restricted)
		return //this item doesn't use the species_restricted system

	//Set species_restricted list
	switch(target_species)
		if("Skrell")
			species_restricted = list("exclude","Unathi","Tajara","Diona","Vox", "Xenomorph", "Xenomorph Drone", "Xenomorph Hunter", "Xenomorph Sentinel", "Xenomorph Queen","Wryn")
		if("Human")
			species_restricted = list("exclude","Skrell","Unathi","Tajara","Diona","Vox", "Xenomorph", "Xenomorph Drone", "Xenomorph Hunter", "Xenomorph Sentinel", "Xenomorph Queen","Wryn")
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

///////////////////////////////////////////////////////////////////////
// Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = 1.0
	throwforce = 2
	slot_flags = SLOT_EARS

/obj/item/clothing/ears/attack_hand(mob/usr as mob)
	if (!usr) return

	if (src.loc != usr || !istype(usr,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = usr
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_TWOEARS )
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		usr.u_equip(O)
		if(!istype(src,/obj/item/clothing/ears/offear))
			qdel(O)
			O = src
	else
		O = src

	usr.u_equip(src)

	if (O)
		usr.put_in_hands(O)
		O.add_fingerprint(usr)

	if(istype(src,/obj/item/clothing/ears/offear))
		qdel(src)

/obj/item/clothing/ears/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_ears()

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = 5.0
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "block"
	slot_flags = SLOT_EARS | SLOT_TWOEARS

	New(var/obj/O)
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		set_dir(O.dir)

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS | SLOT_TWOEARS

///////////////////////////////////////////////////////////////////////
//Glasses
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	flags = GLASSESCOVERSEYES
	slot_flags = SLOT_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/eyes.dmi')

/obj/item/clothing/glasses/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()

///////////////////////////////////////////////////////////////////////
//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = 2.0
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.50
	var/wired = 0
	var/obj/item/weapon/cell/cell = 0
	var/clipped = 0
	body_parts_covered = HANDS
	slot_flags = SLOT_GLOVES
	attack_verb = list("challenged")
	species_restricted = list("exclude","Unathi","Tajara","Wryn")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/gloves.dmi')

/obj/item/clothing/gloves/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_gloves()

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		//why is this not part of the powercell code?
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()

// Called just before an attack_hand(), in mob/UnarmedAttack()
/obj/item/clothing/gloves/proc/Touch(var/atom/A, var/proximity)
	return 0 // return 1 to cancel attack_hand()

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/usr)
	if(istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		if (clipped)
			usr << "<span class='notice'>The [src] have already been clipped!</span>"
			update_icon()
			return

		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		usr.visible_message("<span class='alert'>[usr] cuts the fingertips off of the [src].</span>","<span class='alert'>You cut the fingertips off of the [src].</span>")

		clipped = 1
		name = "modified [name]"
		desc = "[desc]<br>They have had the fingertips cut off of them."
		if("exclude" in species_restricted)
			species_restricted -= "Unathi"
			species_restricted -= "Tajara"
		return

///////////////////////////////////////////////////////////////////////
//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	w_class = 2.0

	var/light_overlay = "helmet_light"
	var/light_applied
	var/brightness_on
	var/on = 0
	var/insulating = 0

/obj/item/clothing/head/New()
	..()
	if(!icon_action_button && brightness_on)
		icon_action_button = "[icon_state]"

/obj/item/clothing/head/attack_self(mob/usr)
	if(brightness_on)
		if(!isturf(usr.loc))
			usr << "You cannot turn the light on while in this [usr.loc]"
			return
		on = !on
		usr << "You [on ? "enable" : "disable"] the helmet light."
		toggle_light(usr)
	else
		return ..(usr)

/obj/item/clothing/head/proc/toggle_light(var/mob/usr = null)
	if(on && !light_applied)
		if(loc == usr)
			usr.set_light(usr.light_range + brightness_on)
		set_light(brightness_on)
		light_applied = 1
	else if(!on && light_applied)
		if(loc == usr)
			usr.set_light(usr.light_range - brightness_on)
		set_light(0)
		light_applied = 0
	update_icon(usr)

/obj/item/clothing/head/equipped(mob/usr)
	..()
	spawn(1)
		if(on && loc == usr && !light_applied)
			usr.set_light(usr.light_range + brightness_on)
			light_applied = 1

/obj/item/clothing/head/dropped(mob/usr)
	..()
	spawn(1)
		if(on && loc != usr && light_applied)
			usr.set_light(usr.light_range - brightness_on)
			light_applied = 0

/obj/item/clothing/head/update_icon(var/mob/usr)

	overlays.Cut()
	if(on)
		if(!light_overlay_cache["[light_overlay]_icon"])
			light_overlay_cache["[light_overlay]_icon"] = image("icon" = 'icons/obj/light_overlays.dmi', "icon_state" = "[light_overlay]")
		if(!light_overlay_cache["[light_overlay]"])
			light_overlay_cache["[light_overlay]"] = image("icon" = 'icons/mob/light_overlays.dmi', "icon_state" = "[light_overlay]")
		overlays |= light_overlay_cache["[light_overlay]_icon"]
	if(istype(usr,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = usr
		H.update_inv_head()

/obj/item/clothing/head/equipped(mob/usr)
	..()
	update_light(usr)

/obj/item/clothing/head/pickup(mob/usr)
	..()
	update_light(usr)

/obj/item/clothing/head/dropped(mob/usr)
	..()
	update_light(usr)

/obj/item/clothing/head/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_head()

///////////////////////////////////////////////////////////////////////
//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_MASK
	body_parts_covered = FACE|EYES
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/masks.dmi')

/obj/item/clothing/mask/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_mask()

/obj/item/clothing/mask/proc/filter_air(datum/gas_mixture/air)
	return

///////////////////////////////////////////////////////////////////////
//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_FEET

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	force = 2
	species_restricted = list("exclude","Unathi","Tajara","Wryn")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/shoes.dmi')

/obj/item/clothing/shoes/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_shoes()

///////////////////////////////////////////////////////////////////////
//Suit
/obj/item/clothing/
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9
	w_class = 3

/obj/item/clothing/suit/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_wear_suit()

///////////////////////////////////////////////////////////////////////
//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_uniforms.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_uniforms.dmi',
		)
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = 3
	var/has_sensor = SUIT_HAS_SENSORS //For the crew computer 2 = unable to change mode
	var/sensor_mode = 0
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	var/rolled_down = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled
	var/rolled_sleeves = -1 //0 = unrolled, 1 = rolled, -1 = cannot be toggled
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/uniform.dmi',
		)

	//convenience var for defining the icon state for the overlay used when the clothing is worn.
	//Also used by rolling/unrolling.
	var/worn_state = null
	valid_accessory_slots = list("utility","armband","rank","decor")
	restricted_accessory_slots = list("utility", "armband","rank")

/obj/item/clothing/under/get_mob_overlay(mob/usr_mob, slot)
	var/image/ret = ..()
	if(item_state_slots && item_state_slots[slot])
		ret.icon_state = item_state_slots[slot]
	else
		ret.icon_state = icon_state
	ret.icon_state = "[ret.icon_state]_s"

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			ret.overlays |= A.get_mob_overlay(usr_mob, slot)

	return ret


/obj/item/clothing/under/attack_hand(var/mob/usr)
	if(accessories && accessories.len)
		..()
	if ((ishuman(usr) || issmall(usr)) && src.loc == usr)
		return
	..()

/obj/item/clothing/under/MouseDrop(obj/over_object as obj)
	if ((ishuman(usr) || issmall(usr)) && over_object)		//Sanity check
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (!(src.loc == usr))
			return

		if (!( usr.restrained() ) && !( usr.stat ))
			switch(over_object.name)
				if("r_hand")
					usr.u_equip(src)
					usr.put_in_r_hand(src)
				if("l_hand")
					usr.u_equip(src)
					usr.put_in_l_hand(src)
			src.add_fingerprint(usr)
			return
	return

/obj/item/clothing/under/New()
	..()
	if(worn_state)
		if(!item_state_slots)
			item_state_slots = list()
		item_state_slots[slot_w_uniform] = worn_state
	else
		worn_state = icon_state

	//autodetect rollability
	if(rolled_down < 0)
		if((worn_state + "_d_s") in icon_states(default_onmob_icons[slot_w_uniform]))
			rolled_down = 0

/obj/item/clothing/under/proc/update_rolldown_status()
	var/mob/living/carbon/human/H
	if(istype(src.loc, /mob/living/carbon/human))
		H = src.loc


	var/icon/under_icon
	if(icon_override)
		under_icon = icon_override
	else if(H && sprite_sheets && sprite_sheets[H.species.get_bodytype()])
		under_icon = sprite_sheets[H.species.get_bodytype()]
	else if(item_icons && item_icons[slot_w_uniform])
		under_icon = item_icons[slot_w_uniform]
	else
		under_icon = default_onmob_icons[slot_w_uniform]

	// The _s is because the icon update procs append it.
	if(("[worn_state]_d_s") in icon_states(under_icon))
		if(rolled_down != 1)
			rolled_down = 0
	else
		rolled_down = -1
	if(H) update_clothing_icon()

/obj/item/clothing/under/proc/update_rollsleeves_status()
	var/mob/living/carbon/human/H
	if(istype(src.loc, /mob/living/carbon/human))
		H = src.loc

	var/icon/under_icon
	if(icon_override)
		under_icon = icon_override
	else if(H && sprite_sheets && sprite_sheets[H.species.get_bodytype(H)])
		under_icon = sprite_sheets[H.species.get_bodytype(H)]
	else if(item_icons && item_icons[slot_w_uniform])
		under_icon = item_icons[slot_w_uniform]
	else
		under_icon = default_onmob_icons[slot_w_uniform]

	// The _s is because the icon update procs append it.
	if(("[worn_state]_r_s") in icon_states(under_icon))
		if(rolled_sleeves != 1)
			rolled_sleeves = 0
	else
		rolled_sleeves = -1
	if(H) update_clothing_icon()

/obj/item/clothing/under/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_w_uniform()


/obj/item/clothing/under/examine(mob/usr)
	..(usr)
	switch(src.sensor_mode)
		if(0)
			usr << "Its sensors appear to be disabled."
		if(1)
			usr << "Its binary life sensors appear to be enabled."
		if(2)
			usr << "Its vital tracker appears to be enabled."
		if(3)
			usr << "Its vital tracker and tracking beacon appear to be enabled."

/obj/item/clothing/under/proc/set_sensors(mob/usr as mob)
	var/mob/M = usr
	if (istype(M, /mob/dead/)) return
	if (usr.stat || usr.restrained()) return
	if(has_sensor >= SUIT_LOCKED_SENSORS)
		usr << "The controls are locked."
		return 0
	if(has_sensor <= SUIT_NO_SENSORS)
		usr << "This suit does not have any sensors."
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		usr << "You have moved too far away."
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				usr.visible_message("[usr] adjusts the tracking sensor on \his [src.name].", "You disable your suit's remote sensing equipment.")
			if(1)
				usr.visible_message("[usr] adjusts the tracking sensor on \his [src.name].", "Your suit will now report whether you are live or dead.")
			if(2)
				usr.visible_message("[usr] adjusts the tracking sensor on \his [src.name].", "Your suit will now report your vital lifesigns.")
			if(3)
				usr.visible_message("[usr] adjusts the tracking sensor on \his [src.name].", "Your suit will now report your vital lifesigns as well as your coordinate position.")

	else if (ismob(src.loc))
		if(sensor_mode == 0)
			usr.visible_message("<span class='warning'>[usr] disables [src.loc]'s remote sensing equipment.</span>", "You disable [src.loc]'s remote sensing equipment.")
		else
			usr.visible_message("[usr] adjusts the tracking sensor on [src.loc]'s [src.name].", "You adjust [src.loc]'s sensors.")
	else
		usr.visible_message("[usr] adjusts the tracking sensor on [src]", "You adjust the sensor on [src].")

/obj/item/clothing/under/emp_act(var/severity)
	..()
	var/new_mode
	switch(severity)
		if(1)
			new_mode = pick(75;SUIT_SENSOR_OFF, 15;SUIT_SENSOR_BINARY, 10;SUIT_SENSOR_VITAL)
		if(2)
			new_mode = pick(50;SUIT_SENSOR_OFF, 25;SUIT_SENSOR_BINARY, 20;SUIT_SENSOR_VITAL, 5;SUIT_SENSOR_TRACKING)
		else
			new_mode = pick(25;SUIT_SENSOR_OFF, 35;SUIT_SENSOR_BINARY, 30;SUIT_SENSOR_VITAL, 10;SUIT_SENSOR_TRACKING)

	sensor_mode = new_mode

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)
	..()

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	update_rolldown_status()
	if(rolled_down == -1)
		usr << "<span class='notice'>You cannot roll down [src]!</span>"
	if((rolled_sleeves == 1) && !(rolled_down))
		rolled_sleeves = 0
		return

	rolled_down = !rolled_down
	if(rolled_down)
		body_parts_covered &= LOWER_TORSO|LEGS|FEET
		item_state_slots[slot_w_uniform] = "[worn_state]_d"
	else
		body_parts_covered = initial(body_parts_covered)
		item_state_slots[slot_w_uniform] = "[worn_state]"
	update_clothing_icon()

/obj/item/clothing/under/verb/rollsleeves()
	set name = "Roll Up Sleeves"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	update_rollsleeves_status()
	if(rolled_sleeves == -1)
		usr << "<span class='notice'>You cannot roll up your [src]'s sleeves!</span>"
		return
	if(rolled_down == 1)
		usr << "<span class='notice'>You must roll up your [src] first!</span>"
		return

	rolled_sleeves = !rolled_sleeves
	if(rolled_sleeves)
		body_parts_covered &= ~(ARMS|HANDS)
		item_state_slots[slot_w_uniform] = "[worn_state]_r"
		usr << "<span class='notice'>You roll up your [src]'s sleeves.</span>"
	else
		body_parts_covered = initial(body_parts_covered)
		item_state_slots[slot_w_uniform] = "[worn_state]"
		usr << "<span class='notice'>You roll down your [src]'s sleeves.</span>"
	update_clothing_icon()

/obj/item/clothing/under/rank/New()
	sensor_mode = pick(0,1,2,3)
	..()

