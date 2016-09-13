#define ARC_EMITTER_POWER_MIN 10 // 10kW
#define ARC_EMITTER_POWER_MAX 60 // 60kW
/obj/machinery/power/arc_emitter
	name = "Arc Emitter"
	desc = "It is a heavy duty industrial tesla emitter."
	icon = 'icons/obj/fusion.dmi'
	icon_state = "arc_emitter_off"
	anchored = 0
	density = 1
	req_access = list(access_engine_equip)
	use_power = 0	//uses powernet power, not APC power

	active_power_usage = ARC_EMITTER_POWER_MAX * 1000 * ( 2/3 )	//40kW of fuck you

	var/active = 0
	var/powered = 0
	var/state = 2
	anchored = 1
	var/locked = 0
	var/datum/wires/arc_emitter/wires = null
	var/disabled = 0
	var/arc_power = 40

/obj/machinery/power/arc_emitter/New()
	update_icon()
	..()

/obj/machinery/power/arc_emitter/initialize()
	..()
	if(state == 2 && anchored)
		connect_to_network()
	wires = new(src)

/obj/machinery/power/arc_emitter/update_icon()
	if (active && avail(active_power_usage))
		icon_state = "arc_emitter_active"
	else if (avail(active_power_usage))
		icon_state = "arc_emitter_on"
	else
		icon_state = "arc_emitter_off"

/obj/machinery/power/arc_emitter/process()
	if(stat & (BROKEN))
		return
	update_icon()
	if(src.state != 2 || !avail(active_power_usage))
		src.active = 0
		return
	update_icon()
	if(active)
		fire_bolt()
	update_icon()

//Fire bolt at a target
/obj/machinery/power/arc_emitter/proc/fire_bolt()
	//Shock unprotected humans
	var/list/targets = list()
	for(var/mob/living/carbon/human/M in oview(src, 5))
		if(!insulated(M))
			targets += M
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/mob/living/carbon/human/M = pick(targets)
			spawn(rand(0, 10))
				arc(M)
				M.apply_damage(rand(arc_power-30, arc_power-20), damagetype = BURN)
				M.apply_effect(rand(5, 10), effecttype = STUN)
				new/obj/effect/effect/sparks(get_turf(M))
		return

	//Shock any blobs
	for(var/obj/effect/blob/B in oview(src, 5))
		targets += B
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/obj/effect/blob/B = pick(targets)
			spawn(rand(0, 10))
				arc(B)
				B.take_damage(arc_power/6)		//diveded by 6 to get a max of 10 damage which will kill a standart blob in 3 shots.
		return

	//Shock any fusion cores
	for(var/obj/machinery/power/fusion/core/C in oview(src, 5))
		targets += C
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/obj/machinery/power/fusion/core/C = pick(targets)
			spawn(rand(0, 10))
				arc(C)
				c_energize(C)
		return

	//Shock any supermatter crystals
	for(var/obj/machinery/power/supermatter/S in oview(src, 5))
		targets += S
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/obj/machinery/power/supermatter/S = pick(targets)
			spawn(rand(0, 10))
				arc(S)
				s_energize(S)
		return

	//Shock any singulo field generators
	for(var/obj/machinery/field_generator/G in oview(src, 5))
		targets += G
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/obj/machinery/field_generator/G = pick(targets)
			spawn(rand(0, 10))
				arc(G)
				G.arc_act(arc_power)
		return

	//Shock any other machines
	for(var/obj/machinery/M in oview(src, 5))
		targets += M
	if(targets.len > 0)
		for(var/i=0, i <= 10, i+=5)
			var/obj/machinery/M = pick(targets)
			spawn(rand(i, i+5))
				arc(M)
				emp(M)

//Shoot a bolt from self to C
/obj/machinery/power/arc_emitter/proc/arc(obj/T)
	if(isnull(T))
		return
	var/datum/effect/effect/system/lightning_bolt/bolt = PoolOrNew(/datum/effect/effect/system/lightning_bolt)
	bolt.start(src, T, size = 1, sy_offset = rand(8, 11), dx_offset = rand(-5,5), dy_offset = rand(-5,5))
	playsound(src.loc, pick( 'sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg'), 100, 1)

//EMP at given obj
/obj/machinery/power/arc_emitter/proc/emp(obj/m)
	empulse(get_turf(m), 1, 1)

//Energize given core
/obj/machinery/power/arc_emitter/proc/c_energize(obj/machinery/power/fusion/core/c)
	c.heat += (arc_power*c.beam_coef*5)	//*5 because this ticks SO MUCH SLOWER !

/obj/machinery/power/arc_emitter/proc/s_energize(obj/machinery/power/supermatter/s)
	s.arc_act(arc_power)

//Check if given mob is wearing insulated cloathing
/obj/machinery/power/arc_emitter/proc/insulated(var/mob/living/carbon/human/m)
	if(isnull(m.head) || isnull(m.wear_suit))
		return 0
	if(!m.head.siemens_coefficient >= 0.9 || !m.wear_suit.siemens_coefficient >= 0.9)
		return 0
	return 1

//Attackby deals with wrenching, welding emagging ect..
/obj/machinery/power/arc_emitter/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "Turn off [src] first."
			return
		switch(state)
			if(0)
				if(istype(loc, /turf/space))
					user << "<span class='warning'>You try to secure the bolts to space. It doesn't work out too well.</span>"
					return

				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				user << "<span class='warning'>\The [src] needs to be unwelded from the floor.</span>"
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			user << "Turn off [src] first."
			return
		switch(state)
			if(0)
				user << "<span class='warning'>\The [src] needs to be wrenched to the floor.</span>"
			if(1)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld [src] to the floor.", \
						"You start to weld [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = 2
						user << "You weld [src] to the floor."
						connect_to_network()
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			if(2)
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut [src] free from the floor.", \
						"You start to cut [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20))
						if(!src || !WT.isOn()) return
						state = 1
						user << "You cut [src] free from the floor."
						disconnect_from_network()
				else
					user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user,icon_state,icon_state,W)
		return

	if(istype(W, /obj/item/device/multitool) || istype(W, /obj/item/weapon/wirecutters))
		if(emagged)
			user << "<span class='warning'>The power control circuitry is fried.</span>"
			return
		if(panel_open == 1)
			wires.Interact(user)
			message_admins("[key_name(user, user.client)] is messing with Arc emitter wires. (<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
			log_game("[user.ckey] is messing with Arc emitter wires. ([user]) in ([x],[y],[z])")
			investigate_log("wires where messed with by <font color='red'>off</font> by [user.key]","singulo")
			return
		if(locked)
			user << "<span class='warning'>The controls are locked!</span>"
			return

		var/new_power = input("Set arc emitter power in kW", "Arc Emitter power", active_power_usage / 1000) as num|null
		if(!new_power)
			return

		arc_power = Clamp(new_power, ARC_EMITTER_POWER_MIN, ARC_EMITTER_POWER_MAX)
		active_power_usage = arc_power * 1000

		user << "<span class='notice'>You set the arc emitter's bolt strength to [arc_power]kW.</span>"
		desc = "It is a heavy duty industrial arc emitter. The power dial is set to [arc_power]kW."
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			user << "<span class='warning'>The lock seems to be broken.</span>"
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				user << "The controls are now [src.locked ? "locked." : "unlocked."]"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "<span class='warning'>The controls can only be locked when [src] is online.</span>"
		else
			user << "<span class='warning'>Access denied.</span>"
		return


	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags [src].","<span class='warning'>You short out the lock.</span>")
		return

	..()
	return

/obj/machinery/power/arc_emitter/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	activate(user)



/obj/machinery/power/arc_emitter/proc/activate(mob/user as mob)
	if(stat & BROKEN)
		return

	if(state == 2)	//Not yet wrenched and welded
		if(!powernet)
			user << "\The [src] isn't connected to a wire."
			return 1
		if(!src.locked)
			if(src.active==1)
				if(disabled)
					user << "You try to turn [src] off but nothing happens."
					return 1
				src.active = 0
				user << "You turn off [src]."
				message_admins("Arc emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Arc emitter turned off by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")

			else if(avail(active_power_usage))
				if(disabled)
					user << "You try to turn [src] on but nothing happens."
					return 1
				src.active = 1
				user << "You turn on [src]."
				message_admins("Arc emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Arc mitter turned on by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")

			update_icon()
		else
			user << "<span class='warning'>The controls are locked!</span>"
	else
		user << "<span class='warning'>\The [src] needs to be firmly secured to the floor first.</span>"
		return 1