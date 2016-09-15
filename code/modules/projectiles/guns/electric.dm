obj/item/weapon/gun/energy/electric
	name = "Arc gun"
	desc = "Its a arc gun firing bolts of electricity."
	icon_state = "elaser"
	item_state = "laser"
	w_class = 3.0
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = /datum/effect/effect/system/lightning_bolt
	var/projectile_size = 1
	var/list/fire_sounds = list('sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg')
	var/list/damages = list(BURN = 30)
	var/list/effects = list(STUN = 20, AGONY = 20)

/obj/item/weapon/gun/energy/electric/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)//TODO: go over this
	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check)
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((CLUMSY in M.mutations) && prob(50))
				M << "<span class='danger'>[src] blows up in your face.</span>"
				M.take_organ_damage(0,20)
				M.drop_item()
				qdel(src)
				return

	if (!user.IsAdvancedToolUser())
		return
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (HULK in M.mutations)
			M << "<span class='danger'>Your fingers are much too large for the trigger guard!</span>"
			return

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	//Check if we can hit the target.
	//Can shoot trough glass but not trough walls.
	var/list/shootable = oview(user, 20)
	if(!(target in shootable))
		return

	if(!special_check(user))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!"
		return

	if(!load_into_chamber()) //CHECK
		return click_empty(user)

	var/tmp/t_def_zone = user.zone_sel.selecting
	if(targloc == curloc)
		//Shock self
		user.bullet_act(in_chamber)
		update_icon()
		return

	if(recoil)
		spawn()
			shake_camera(user, recoil + 1, recoil)

	fire_sound = pick(fire_sounds)

	if(silenced)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 80, 1)
		user.visible_message("<span class='warning'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
		"<span class='warning'>You fire [src][reflex ? "by reflex":""]!</span>", \
		"You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

	statistics.increase_stat("guns_fired")

	//var/tmp/shot_from = src
	var/tmp/yo = targloc.y - curloc.y
	var/tmp/xo = targloc.x - curloc.x

	//Decrease accuraty when shooter is hurt and in shock.
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/mob = user
		if(mob.shock_stage > 120)
			yo += rand(-2,2)
			xo += rand(-2,2)
		else if(mob.shock_stage > 70)
			yo += rand(-1,1)
			xo += rand(-1,1)

	var/tmp/tx_offset
	var/tmp/ty_offset
	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			tx_offset = text2num(mouse_control["icon-x"]) - 15	//We need to use -15 cause of the projectile effect wanting offsets from the center
		if(mouse_control["icon-y"])
			ty_offset = text2num(mouse_control["icon-y"]) - 15	//We need to use -15 cause of the projectile effect wanting offsets from the center

	var/tmp/list/offset = find_offset(user, target)

	spawn()
		//If we are shooting at a human.. fry it else free the machinery !
		if(istype(target, /mob/living/carbon))
			var/mob/living/carbon/human/M = target
			for(var/damtype in damages)
				M.apply_damage(damages[type], damagetype = damtype, def_zone = t_def_zone)
			for(var/efftype in effects)
				M.apply_effect(effect = effects[efftype], effecttype = efftype)
		//Fire the weapon
		var/datum/effect/effect/system/bolt = new projectile_type
		bolt.start(user, target, size = projectile_size, sx_offset = offset["x"], sy_offset = offset["y"], dx_offset = tx_offset, dy_offset = ty_offset)

	update_icon()
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun/energy/electric/load_into_chamber()
	if(!power_supply)	return 0
	if(!power_supply.use(charge_cost))	return 0
	return 1

/obj/item/weapon/gun/energy/electric/proc/find_offset(atom/user)
	var/tmp/user_dir = user.dir
	switch(user_dir)
		if(NORTH)
			. = list("x" = 0, "y" = 15)
		if(EAST)
			. = list("x" = 15, "y" = 0)
		if(SOUTH)
			. = list("x" = 0, "y" = -15)
		else //west
			. = list("x" = -15, "y" = 0)

/* Proof of concept
obj/item/weapon/gun/energy/electric/beam
	name = "Beam gun"
	desc = "Fires a misterious beam."
	icon_state = "elaser"
	item_state = "laser"
	w_class = 3.0
	origin_tech = "combat=4;materials=3;powerstorage=3"
	projectile_type = /datum/effect/effect/system/beam
	projectile_size = 2
	fire_sounds = list('sound/weapons/Laser.ogg')
	damages = list(BURN = 40)
	effects = list(EYE_BLUR = 4)
*/
