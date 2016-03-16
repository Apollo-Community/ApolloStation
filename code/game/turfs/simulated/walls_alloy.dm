/*
 * Alloy walls
 * See code\game\objects\items\stack\sheets\alloy.dm for more info.
*/

/turf/simulated/wall/alloy
	name = "alloy wall"
	desc = "A big chunk of alloy used to separate rooms."
	icon_state = "r_wall"
	walltype = "rwall"

	damage_cap = 300

	var/list/materials = list()
	var/unique_id = ""
	var/list/effects = list()
	var/mineral_multiplier = 1

	var/d_state = 0

/turf/simulated/wall/alloy/New(var/loc)
	..(loc)

	// for mapped walls more than anything, so that they get their effects/name applied
	// it'll fail at the sanity check if materials/effects aren't set anyways
	set_materials(materials, effects, 1)

// don't think New can be called "properly" considering how girders handle wall building
// that's why this proc is a thing
// override is for reinforced walls, it forces a materials update
/turf/simulated/wall/alloy/proc/set_materials(var/list/comp, var/list/effs)
	if(!comp || !effs)
		return

	effects = effs.Copy()
	materials = comp.Copy()

	var/sum = 0
	var/pre = ""
	var/post = ""
	for(var/M in materials)
		sum += materials[M]
		if(alloy_prefix[M])
			pre = alloy_prefix[M]
		else
			post = alloy_postfix[M]
	// need a name. this is also an indicator that something isn't right with the comp list
	if(pre == "" && post == "")
		return
	if(!istype(src, /turf/simulated/wall/alloy/reinforced))
		name = "[pre][post] wall"
		desc = "A big chunk of [pre][post] alloy used to separate rooms."

	for(var/M in materials)
		materials[M] /= sum
		unique_id += "[M][materials[M]]"
		if(M != "metal" || M != "glass")
			mineral_multiplier = materials[M] * 2

	// catametallic = reinforced, if platinum amount is >= 40%
	// in honor of being lazy we'll use mineral_multiplier, which is why we check for 0.8 instead of 0.4
	if(name == "catametallic wall" && mineral_multiplier >= 0.8)
		var/turf/simulated/wall/alloy/reinforced/R = new(get_turf(src))
		R.set_materials(materials)
		qdel(src)
		return

	// alloy benefits, woo!
	for(var/E in effects)
		switch(E)
			if("str")
				damage_cap += (damage_cap * mineral_multiplier * effects[E])
			if("tempres")
				max_temperature *= mineral_multiplier * effects[E]
			if("projarmor")
				armor = effects[E]
			if("acidres")
				unacidable = effects[E]

/turf/simulated/wall/alloy/attackby(obj/item/W as obj, mob/user as mob)

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	//get the user's location
	if( !istype(user.loc, /turf) )	return	//can't do this stuff whilst inside objects and such

	if( istype( W, /obj/item/weapon/paint_can ))
		if( !paint )
			paint = new()

		var/obj/item/weapon/paint_can/paint_can = W
		paint_can.paint( src, user )
		return

	if( istype( W, /obj/item/weapon/paint_brush ))
		if( !paint )
			paint = new()

		var/obj/item/weapon/paint_brush/brush = W
		brush.paint( src, user )
		return

	if(rotting)
		if(istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				user << "<span class='notice'>You burn away the fungi with \the [WT].</span>"
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					del E
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			user << "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>"
			src.dismantle_wall()
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if( thermite )
		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			user << "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>"
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		user << "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>"
		return

	if(damage && istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user << "<span class='notice'>You start repairing the damage to [src].</span>"
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, max(5, damage / 5)) && WT && WT.isOn())
				user << "<span class='notice'>You finish repairing the damage to [src].</span>"
				take_damage(-damage)
			return
		else
			user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				src.d_state = 1
				src.icon_state = "r_wall-1"
				new /obj/item/stack/rods( src )
				user << "<span class='notice'>You cut the outer grille.</span>"
				return

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				user << "<span class='notice'>You begin removing the support lines.</span>"
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( d_state == 1 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 2
					src.icon_state = "r_wall-2"
					user << "<span class='notice'>You remove the support lines.</span>"
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if( istype(W, /obj/item/stack/rods) )
				var/obj/item/stack/O = W
				src.d_state = 0
				src.icon_state = "r_wall"
				relativewall_neighbours()	//call smoothwall stuff
				user << "<span class='notice'>You replace the outer grille.</span>"
				if (O.amount > 1)
					O.amount--
				else
					qdel(O)
				return

		if(2)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the metal cover.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					sleep(60)
					if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )	return

					if( d_state == 2 && user.loc == T && user.get_active_hand() == WT )
						src.d_state = 3
						src.icon_state = "r_wall-3"
						user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the metal cover.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( d_state == 2 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 3
					src.icon_state = "r_wall-3"
					user << "<span class='notice'>You press firmly on the cover, dislodging it.</span>"
				return

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				user << "<span class='notice'>You struggle to pry off the cover.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				sleep(100)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( d_state == 3 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 4
					src.icon_state = "r_wall-4"
					user << "<span class='notice'>You pry off the cover.</span>"
				return

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				user << "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>"
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				sleep(40)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( d_state == 4 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 5
					src.icon_state = "r_wall-5"
					user << "<span class='notice'>You remove the bolts anchoring the support rods.</span>"
				return

		if(5)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if( WT.remove_fuel(0,user) )

					user << "<span class='notice'>You begin slicing through the support rods.</span>"
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					sleep(100)
					if( !istype(src, /turf/simulated/wall) || !user || !WT || !WT.isOn() || !T )	return

					if( d_state == 5 && user.loc == T && user.get_active_hand() == WT )
						src.d_state = 6
						src.icon_state = "r_wall-6"
						new /obj/item/stack/rods( src )
						user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return

			if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )

				user << "<span class='notice'>You begin slicing through the support rods.</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				sleep(70)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( d_state == 5 && user.loc == T && user.get_active_hand() == W )
					src.d_state = 6
					src.icon_state = "r_wall-6"
					new /obj/item/stack/rods( src )
					user << "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>"
				return

		if(6)
			if( istype(W, /obj/item/weapon/crowbar) )

				user << "<span class='notice'>You struggle to pry off the outer sheath.</span>"
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				sleep(100)
				if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

				if( user.loc == T && user.get_active_hand() == W )
					user << "<span class='notice'>You pry off the outer sheath.</span>"
					dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))

		user << "<span class='notice'>You begin to drill though the wall.</span>"

		sleep(200)
		if( !istype(src, /turf/simulated/wall) || !user || !W || !T )	return

		if( user.loc == T && user.get_active_hand() == W )
			user << "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>"
			dismantle_wall()

	//REPAIRING
	else if( istype(W, /obj/item/stack/sheet/metal) && d_state )
		var/obj/item/stack/sheet/metal/MS = W

		user << "<span class='notice'>You begin patching-up the wall with \a [MS].</span>"

		sleep( max(20*d_state,100) )	//time taken to repair is proportional to the damage! (max 10 seconds)
		if( !istype(src, /turf/simulated/wall) || !user || !MS || !T )	return

		if( user.loc == T && user.get_active_hand() == MS && d_state )
			src.d_state = 0
			src.icon_state = "r_wall"
			relativewall_neighbours()	//call smoothwall stuff
			user << "<span class='notice'>You repair the last of the damage.</span>"
			if (MS.amount > 1)
				MS.amount--
			else
				qdel(MS)

	//APC
	else if( istype(W,/obj/item/apc_frame) )
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)

	else if( istype(W,/obj/item/alarm_frame) )
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/frame/light))
		var/obj/item/frame/light/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/frame/light/small))
		var/obj/item/frame/light/small/AH = W
		AH.try_build(src)
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

// Urametallic walls give partial or full rot immunity
/turf/simulated/wall/alloy/rot()
	if(effects["rot"])
		var/rot_prob = 100 - (effects["rot"] * 100)
		if(prob(rot_prob))
			..()

// Osimetallic walls handle explosions much better - they are never guaranteed to get dismantled
/turf/simulated/wall/alloy/ex_act(severity)
	if(effects["blastres"])
		// !!! this needs to be changed by someone better at maths. done this way, you won't see any benefit from the blast resistance until you pass 10% mineral !!!
		var/damage = Clamp(250 / (mineral_multiplier * effects["blastres"]), 0, 250)
		switch(severity)
			if(1)
				if(prob(50 + (mineral_multiplier * 50)))
					take_damage(rand(damage, damage + 100))
				else
					dismantle_wall(1,1)
			if(2)
				take_damage(rand(damage, damage + 50))
			if(3)
				take_damage(rand(0, damage * 2))
	else
		..()

/*
 *	Catametallic walls (classic reinforced walls)
 *	Defined here like this to make stuff a bit easier (especially mapping)
*/

/turf/simulated/wall/alloy/reinforced
	name = "reinforced wall"
	desc = "A big chunk of catametallic alloy used to separate rooms."

	materials = list("platinum" = 0.5, "metal" = 0.5)
	effects = list("str" = 0.67, "blastres" = 1.5, "projarmor" = 0.15, "tempres" = 5)

/turf/simulated/wall/alloy/reinforced/New(var/turf/loc, var/list/comp)
	..(loc)
	set_materials(comp, effects)
