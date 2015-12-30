#define DAMAGE			1
#define FIRE			2
#define HUD_STATS_STATES 7 // how many levels are in each stat panel

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel. This one looks rather bare."
	icon = 'icons/48x48/pods.dmi'
	icon_state = "pod"
	density = 1
	opacity = 0
	anchored = 1
	unacidable = 1
	layer = 3.9
	infra_luminosity = 15

	var/mob/living/pilot = null
	var/list/passengers = list()

	var/datum/spacepod/equipment/equipment_system
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = 0

	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin

	var/lights = 0
	var/lights_power = 12

	var/inertia_dir = 0
	var/hatch_open = 0
	var/next_firetime = 0 // Used for weapon firing

	var/health = 100 // pods without armor are tough as a spongecake
	var/max_health = 100
	var/fire_threshold_health = 0.2 // threshold heat for fires to start

	var/empcounter = 0 //Used for disabling movement when hit by an EMP
	var/frozen = 0 // Used to stop the spacepod from moving

	var/datum/effect/effect/system/ion_trail_follow/space_trail/ion_trail
	var/list/pod_overlays

	var/global/enter_time = 15 // How much time it takes to move in / out of the spacepod

/obj/spacepod/New()
	. = ..()

	dir = EAST
	bound_width = 64
	bound_height = 64

	equipment_system = new(src)
	equipment_system.equip( new /obj/item/device/spacepod_equipment/seat )
	equipment_system.equip( new /obj/item/weapon/card/id/spacepod )

	add_cabin()
	add_airtank()
	src.use_internal_tank = 1
	pr_int_temp_processor = new /datum/global_iterator/pod_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/pod_tank_give_air(list(src))

	src.ion_trail = new /datum/effect/effect/system/ion_trail_follow/space_trail()
	src.ion_trail.set_up(src)
	src.ion_trail.start()

	spacepods_list += src

	update_icon()

/obj/spacepod/Destroy()
	spacepods_list -= src

	// Dumping the occupants
	if( pilot )
		pilot.loc = src.loc
	for( var/mob/passenger in passengers )
		passenger.loc = src.loc

	..()

/obj/spacepod/process()
	if(src.empcounter > 0)
		src.empcounter--
	else
		processing_objects.Remove(src)

/obj/spacepod/update_icon()
	..()

	if( equipment_system.armor )
		icon_state = equipment_system.armor.pod_icon
	else
		icon_state = "pod"

	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="[equipment_system.armor ? equipment_system.armor.pod_damage_icon : "pod_damage"]")
		pod_overlays[FIRE] = image(icon, icon_state="[equipment_system.armor ? equipment_system.armor.pod_fire_icon : "pod_fire"]")

	overlays.Cut()

	if(health <= round(initial(health)/2))
		overlays += pod_overlays[DAMAGE]
	if( is_on_fire() )
		overlays += pod_overlays[FIRE]

/obj/spacepod/proc/is_on_fire()
	if( equipment_system )
		if( equipment_system.engine_system )
			return equipment_system.engine_system.fire
	return 0

/obj/spacepod/proc/fire_hazard()
	return health/initial(health) <= fire_threshold_health

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	if(P.damage && !P.nodamage)
		if( equipment_system.shield_system )
			equipment_system.shield_system.hit( P.damage )
		else
			deal_damage(P.damage)
	else if(P.flag == "energy" && istype(P,/obj/item/projectile/ion)) //needed to make sure ions work properly
		empulse(src, 1, 1)

/obj/spacepod/blob_act()
	deal_damage(30)
	return

/obj/spacepod/proc/deal_damage(var/damage)
	var/oldhealth = health
	health = max(0, health - damage)
	var/percentage = (health / initial(health)) * 100
	if( oldhealth > health && percentage <= 25 && percentage > 0)
		play_interior_sound('sound/effects/engine_alert2.ogg')
	if( oldhealth > health && !health)
		play_interior_sound('sound/effects/engine_alert1.ogg')
	if(!health)
		explode()

	update_icon()
	update_HUD( pilot )

/obj/spacepod/proc/play_interior_sound( var/sound )
	var/sound/S = sound(sound)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = 50
	if( pilot )
		pilot << S

	for( var/mob/passenger in passengers )
		passenger << S

/obj/spacepod/proc/fadeout()
	frozen = 1

	if( pilot )
		pilot.fadeout()

	for( var/mob/passenger in passengers )
		passenger.fadeout()

/obj/spacepod/proc/fadein()
	frozen = 0

	if( pilot )
		pilot.fadein()

	for( var/mob/passenger in passengers )
		passenger.fadein()

/obj/spacepod/proc/explode()
	spawn(0)
		occupants_announce( "The pilot's console lights up with a hundred different alarms! You better bail out now!", 2, 1 )

		for(var/i = 10, i >= 0; --i)
			occupants_announce( "Alert: [i] seconds until detonation.", 2 )

			if(i == 0)
				explosion(loc, 2, 4, 8)
				qdel(src)
			sleep(10)

/obj/spacepod/proc/repair_damage(var/repair_amount)
	if(health)
		health = min(initial(health), health + repair_amount)
		update_icon()
		update_HUD( pilot )

/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			qdel(ion_trail)
			qdel(src)
		if(2)
			deal_damage(100)
		if(3)
			if(prob(40))
				deal_damage(50)

/obj/spacepod/emp_act(severity)
	var/obj/item/weapon/cell/battery = equipment_system.battery

	switch(severity)
		if(1)
			occupants_announce( "The pod console flashes 'HEAVY EMP WAVE DETECTED'.", 2 ) //warn the occupants

			if(battery)
				battery.charge = max(0, battery.charge - 5000) //Cell EMP act is too weak, this pod needs to be sapped.
			src.deal_damage(100)
			if(src.empcounter < 40)
				src.empcounter = 40 //Disable movement for 40 ticks. Plenty long enough.
			processing_objects.Add(src)

		if(2)
			occupants_announce( "The pod console flashes 'EMP WAVE DETECTED'.", 2 ) //warn the occupants

			src.deal_damage(40)
			if(battery)
				battery.charge = max(0, battery.charge - 2500) //Cell EMP act is too weak, this pod needs to be sapped.
			if(src.empcounter < 20)
				src.empcounter = 20 //Disable movement for 20 ticks.
			processing_objects.Add(src)

/obj/spacepod/attackby(obj/item/W as obj, mob/user as mob, params)
	if( istype( W, /obj/item/weapon/tank ))
		equipment_system.fill_engine( W )
		update_HUD( pilot )
		return

	if(iscrowbar(W))
		hatch_open = !hatch_open
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		user << "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>"
		return

	else if(istype(W, /obj/item/weapon/cell))
		if(!hatch_open)
			user << "<span class='warning'>The maintenance hatch is closed!</span>"
			return
		if(equipment_system.battery)
			user << "<span class='warning'>The pod already has a battery.</span>"
			return

		equipment_system.equip(W, user)
		update_HUD( pilot )
		return
	else if(istype(W, /obj/item/device/spacepod_equipment))
		if(!hatch_open)
			user << "<span class='warning'>The maintenance hatch is closed!</span>"
			return

		// Adding the equipment to the system
		equipment_system.equip(W, user)
		update_HUD( pilot )
		return
	else if(istype(W, /obj/item/pod_parts/armor))
		if(!hatch_open)
			user << "<span class='warning'>The maintenance hatch is closed!</span>"
			return
		if(equipment_system.armor)
			user << "<span class='warning'>The pod already has armor.</span>"
			return

		equipment_system.equip(W, user)
		update_HUD( pilot )
		return
	else if(istype( W, /obj/item/weapon/card/id ))
		if(!hatch_open)
			user << "<span class='warning'>The maintenance hatch is closed!</span>"
			return
		if( equipment_system.card )
			user << "<span class='warning'>The pod already an access card.</span>"
			return

		equipment_system.equip(W, user)
		update_HUD( pilot )
		return
	else if(istype(W, /obj/item/weapon/weldingtool))
		if(!hatch_open)
			user << "<span class='warning'>You must open the maintenance hatch before attempting repairs.</span>"
			return
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			user << "<span class='warning'>The welder must be on for this task.</span>"
			return
		if (health < initial(health))
			user << "<span class='notice'>You start welding the spacepod...</span>"
			playsound(loc, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, 20))
				if(!src || !WT.remove_fuel(3, user)) return
				repair_damage(10)
				user << "<span class='notice'>You mend some [pick("dents","bumps","damage")] with \the [WT]</span>"
				return
		else
			user << "<span class='notice'><b>\The [src] is fully repaired!</b></span>"
			return
	else if( equipment_system.cargohold )
		equipment_system.cargohold.put_inside( W, user )

/obj/spacepod/attack_hand(mob/user as mob)
	if(!hatch_open)
		return ..()
	if(!equipment_system || !istype(equipment_system))
		user << "<span class='warning'>This pod is non-operational. Please contact maintenance.</span>"
		return

	// Removing the equipment
	var/obj/item/SPE = input(user, "Remove which equipment?", null, null) as null|anything in equipment_system.spacepod_equipment
	if( SPE )
		equipment_system.dequip( SPE, user )
		update_HUD( pilot )

	return

/obj/spacepod/verb/leave_planet()
	if(usr == src.pilot)
		set name = "Leave Planet"
		set category = "Spacepod"
		set src = usr.loc
		set popup_menu = 0

		if( istype( get_area( src ), /area/planet ))
			occupants_announce( "<span class='notice'>Leaving the planet surface and returning to space.</span>" )
			overmapTravel()
		else
			usr << "<span class='warning'>Not currently on a planet.</span>"

		return

/obj/spacepod/verb/toggle_internal_tank()
	if(usr == src.pilot)
		set name = "Toggle internal airtank usage"
		set category = "Spacepod"
		set src = usr.loc
		set popup_menu = 0

		use_internal_tank = !use_internal_tank
		occupants_announce( "<span class='warning'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>" )
		return

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.gas["oxygen"] = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.gas["nitrogen"] = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.temperature
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.temperature
	return

/obj/spacepod/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	if(H && H.client && H in range(1))
		if( put_in_seat( H ))
			return 1

	return 0

/obj/spacepod/proc/occupants_announce( var/message )
	if( pilot )
		pilot << message

	for( var/passenger in passengers )
		passenger << message

/obj/spacepod/proc/addPilot( mob/user as mob )
	if( !user || !istype( user ))
		return 0

	if( pilot )
		return 0

	pilot = user
	add_HUD(pilot)
	update_HUD(pilot)

	user.loc = src
	user.reset_view(src)
	user.stop_pulling()
	user.forceMove(src)

	return 1

/obj/spacepod/proc/removePilot()
	if( !pilot || !istype( pilot ))
		return 0

	remove_HUD( pilot )
	pilot.loc = get_turf( src )
	pilot.reset_view( pilot )
	pilot.stop_pulling()
	pilot.forceMove( get_turf( src ))

	pilot = null
	inertia_dir = 0 // engage reverse thruster and power down pod

	return 1

/obj/spacepod/proc/displacePilot( var/mob/user )
	if( !pilot || !istype( pilot ))
		return 0

	var/mob/M = pilot
	removePilot()
	if( addPassenger( M ))
		if( user )
			visible_message( "[user] moves the pilot, [M], into a passenger's seat!" )
	else
		if( user )
			visible_message( "[user] moves the pilot, [M], out of the shuttle!" )

/obj/spacepod/proc/moveToPilot( mob/user as mob )
	if( pilot )
		user << "<span class='warning'>[pilot] is already piloting the shuttle.</span>"
		return 0

	if( !( user in passengers ))
		user << "<span class='notice'>You start climbing into the pilot seat of the [src]...</span>"
		if( !do_after( user, enter_time ))
			user << "<span class='warning'>You decide you don't want to go into the [src] after all.</span>"
			return

		visible_message( "<span class='notice'>[user] climbs into the pilot's helm of \the [src].</span>" )

		addPilot( user )

		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1
	else
		user << "You start moving into the pilot seat..."
		if( !do_after( user, enter_time ))
			user << "<span class='warning'>You decide you don't want to pilot \the [src] after all.</span>"
			return

		occupants_announce( "<span class='notice'>[user] climbs out of their passenger's seat and into the pilot's helm.</span>" )

		removePassenger( user )
		addPilot( user )

		return 1

/obj/spacepod/proc/addPassenger( mob/user as mob )
	if( equipment_system )
		if( equipment_system.seats.len <= passengers.len )
			return 0

	if( !user || !istype( user ))
		return 0

	passengers.Add( user )

	user.loc = src
	user.reset_view(src)
	user.stop_pulling()
	user.forceMove(src)

	return 1

/obj/spacepod/proc/removePassenger( mob/user as mob )
	if( !user && !istype( user ))
		return 0

	if( !( user in passengers ))
		return 0

	passengers.Remove( user )

	user.loc = get_turf( src )
	user.reset_view( user )
	user.stop_pulling()
	user.forceMove( get_turf( src ))

	return 1

/obj/spacepod/proc/moveToPassenger( mob/user as mob )
	if( equipment_system )
		user << "<span class='notice'>You start climbing into a passenger seat...</span>"
		if( do_after( user, enter_time ))
			if( equipment_system.seats.len > passengers.len ) // if theres still seats for them
				if( user == pilot )
					occupants_announce( "<span class='notice'>[user] climbs out of the pilot's seat and into a passenger's seat.</span>" )

					removePilot()
					addPassenger( user )

					return 1
				else
					visible_message("<span class='notice'>[user] climbs into the [src].</span>")

					addPassenger( user )

					playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
					return 1
			else
				user << "<span class='warning'>There are no empty seats!</span>"
		else
			user << "<span class='warning'>You decide you don't want to ride in a passenger seat after all.</span>"

/obj/spacepod/proc/put_in_seat( mob/living/user as mob )
	if( !user || !istype( user ))
		return 0

	if( !user.isAble() ) //are you cuffed, dying, lying, stunned or other
		return 0

	src.add_fingerprint(user)

	for( var/obj/A in user.contents )
		if( istype( A, /obj/item/weapon/disk/nuclear ))
			user << "<span class='warning'>The [A] locks the door as you attempt to get in.</span?"
			return 0

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == user)
			user << "<span class='warning'>You're too busy getting your life sucked out of you.</span>"
			return 0

	if( pilot )
		if( !pilot.isAble() )
			displacePilot( user )
			moveToPilot( user )
			return
	else
		moveToPilot( user )
		return

	if( !( user in passengers ))
		moveToPassenger( user )

	return 0

/obj/spacepod/proc/exit( mob/user as mob )
	if( !user )
		return

	if( istype( src.loc, /obj/effect/traveler ))
		user << pick( "<span class='warning'>Stepping out into the vast emptiness of space isn't a very good idea.</span>",
					  "<span class='warning'>The void does not call to you.</span>",
					  "<span class='warning'>Why would you want to do that?</span>",
					  "<span class='warning'>You reach for the door and pull the handle, but it beeps and locks, stopping you from idiotically floating off into the void.</span>",
					  "<span class='warning'>Space looks perfectly fine from in here.</span>" )
		return

	if( user == pilot )
		removePilot()
	if( user in passengers )
		removePassenger( user )

	playsound( src, 'sound/machines/windowdoor.ogg', 50, 1 )
	user.loc = src.loc

/obj/spacepod/MouseDrop_T(var/atom/movable/W, mob/user as mob)
	if( istype( W, /mob ))
		var/mob/M = W
		if(!isliving(M)) return
		if(M != user)
			if(M.stat != 0)
				visible_message("<span class='warning'>[user.name] starts loading [M.name] into the [src]!</span>")
				sleep(10)
				put_in_seat( M )
			else
				return
		else
			put_in_seat( M, user )

	if( istype( W, /obj ))
		if( equipment_system.cargohold )
			equipment_system.cargohold.put_inside( W, user )

/obj/spacepod/overmapTravel()
	if( !pilot )
		return

	fadeout()

	sleep( 5 )
	if( alert( pilot, "Would you like to traverse across space?",,"Yes", "No" ) == "No" )
		fadein()

		src.dir = turn( src.dir, 180 )
		inertia_dir = src.dir

		relaymove( pilot, src.dir ) // Turn them around and move them away from the sector
		return

	sleep( 5 )

	new /obj/effect/traveler( src )

	fadein()

/datum/global_iterator/pod_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20

	process(var/obj/spacepod/spacepod)
		if(spacepod.cabin_air && spacepod.cabin_air.volume > 0)
			var/delta = spacepod.cabin_air.temperature - T20C
			spacepod.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
		return

/datum/global_iterator/pod_tank_give_air
	delay = 15

	process(var/obj/spacepod/spacepod)
		if(spacepod.internal_tank)
			var/datum/gas_mixture/tank_air = spacepod.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = spacepod.cabin_air

			var/release_pressure = ONE_ATMOSPHERE
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.temperature > 0)
					transfer_moles = pressure_delta*cabin_air.volume/(cabin_air.temperature * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = spacepod.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.volume/(cabin_air.temperature * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						qdel(removed)
		else
			return stop()
		return

/obj/spacepod/proc/canMove()
	if( !pilot )
		return 0

	if( frozen )
		return 0

	if( equipment_system.engine_system )
		var/distance = 1
		if( istype( src.loc, /obj/effect/traveler ))
			distance = 16
		if( !equipment_system.engine_system.cycle( distance ))
			return 0

	else
		pilot << "<span class='warning'>ERROR: No engine detected!</span>"
		return 0

	if( equipment_system.battery )
		if( equipment_system.battery.charge <= 3 )
			pilot << "<span class='warning'>ERROR: The loaded energy cell has too little charge!</span>"
			return 0
	else
		pilot << "<span class='warning'>ERROR: No energy cell detected!</span>"
		return 0

	if( !health  )
		pilot << "<span class='warning'>ERROR: Hull integrity critical, evacuate!</span>"
		return 0

	if( empcounter )
		pilot << "<span class='warning'>ERROR: Massive electromagnetic intereference!</span>"
		return 0

	if( istype( get_turf( src ), /turf/space/bluespace )) // no moving in bluespace
		pilot << "<span class='warning'>ERROR: Spacepod inoperable when traveling through higher dimensions.</span>"
		return 0

	return 1

/obj/spacepod/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	..()

	if(dir == 1 || dir == 4)
		src.loc.Entered(src)

/obj/spacepod/proc/Process_Spacemove(var/check_drift = 0, mob/user)
	var/dense_object = 0
	if(!user)
		for(var/direction in list(NORTH, NORTHEAST, EAST))
			var/turf/cardinal = get_step(src, direction)
			if(istype(cardinal, /turf/space))
				continue
			dense_object++
			break
	if(!dense_object)
		return 0
	inertia_dir = 0
	return 1

/obj/spacepod/relaymove(mob/user, direction)
	if( src.pilot == user )
		if( isobj( src.loc ) || ismob( src.loc ))//Inside an object, tell it we moved
			if( ion_trail.on )
				ion_trail.stop()
			var/atom/O = src.loc
			return O.relaymove( user, direction )
		else
			if( !ion_trail.on )
				ion_trail.start()
			handlerelaymove(user, direction)
	else
		return

/obj/spacepod/proc/handlerelaymove(mob/user, direction)
	var/moveship = 1
	var/obj/item/weapon/cell/battery = equipment_system.battery

	if( !canMove() )
		return 0

	src.dir = direction
	switch(direction)
		if(1)
			if(inertia_dir == 2)
				inertia_dir = 0
				moveship = 0
		if(2)
			if(inertia_dir == 1)
				inertia_dir = 0
				moveship = 0
		if(4)
			if(inertia_dir == 8)
				inertia_dir = 0
				moveship = 0
		if(8)
			if(inertia_dir == 4)
				inertia_dir = 0
				moveship = 0

	if(moveship)
		step(src, direction)
		if(istype(src.loc, /turf/space))
			inertia_dir = direction

	battery.charge = max(0, battery.charge - 3)

/obj/spacepod/proc/add_HUD(var/mob/M)
	if(!M || !(M.hud_used))	return

	M.hud_used.spacepod_hud( src )

/obj/spacepod/proc/remove_HUD(var/mob/M)
	if(!M || !(M.hud_used))	return

	M.hud_used.remove_spacepod_hud()

	M.hud_used.instantiate()
	M.hud_used.hidden_inventory_update()
	M.hud_used.persistant_inventory_update()
	M.update_action_buttons()
	M.regenerate_icons()

/obj/spacepod/proc/update_HUD(var/mob/M)
	if( !M )
		return

	if( !equipment_system.cargohold )
		M.spacepod_cargo.icon_state = ""

	if( !equipment_system.weapon_system )
		M.spacepod_fire.icon_state = ""
		M.spacepod_switch_weapons.icon_state = ""

	if( !has_power() ) // Can't read the instruments without power
		M.spacepod_health.icon_state = "stat_off"
		M.spacepod_fuel.icon_state = "stat_off"
		if( equipment_system.battery )
			M.spacepod_charge.icon_state = "stat_0"
		else
			M.spacepod_charge.icon_state = "stat_off"
		return

	var/obj/item/weapon/cell/battery = equipment_system.battery
	var/charge_percent = battery.charge/battery.maxcharge
	var/charge_icon_level = round( charge_percent*HUD_STATS_STATES )

	M.spacepod_charge.icon_state = "stat_[charge_icon_level]"

	var/health_percent = health/max_health
	var/health_icon_level = round( health_percent*HUD_STATS_STATES )

	M.spacepod_health.icon_state = "stat_[health_icon_level]"

	if( equipment_system.engine_system )
		var/fuel_percent = equipment_system.engine_system.fuel_tank.return_pressure()/equipment_system.engine_system.max_pressure
		var/fuel_icon_level = round( fuel_percent*HUD_STATS_STATES )

		M.spacepod_fuel.icon_state = "stat_[fuel_icon_level]"
	else
		M.spacepod_fuel.icon_state = "stat_off"

/obj/spacepod/proc/has_power()
	if( equipment_system )
		if( equipment_system.battery )
			if( equipment_system.battery.charge > 0 )
				return 1

	return 0

/obj/effect/landmark/spacepod/random
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/spacepod/random/New()
	..()

/obj/spacepod/verb/fly_up()
	if( src.pilot == usr )
		set category = "Spacepod"
		set name = "Fly Upwards"
		set src = usr.loc

		var/turf/ground = get_turf( src )
		if( !istype( ground.loc, /area/space ))
			pilot << "<span class='warning'>\The ceiling is in the way!</span>"
			return

		var/turf/controllerlocation = locate(1, 1, z)
		for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
			if(controller.up)
				var/turf/upwards = locate(src.x, src.y, controller.up_target)

				if( istype( upwards, /turf/space ) || istype( upwards, /turf/simulated/floor/open ))
					src.loc = upwards
					pilot << "You cruise upwards."
				else
					pilot << "<span class='warning'>There is a [upwards] in the way!</span>"
			else
				pilot << "<span class='warning'>There's nothing of interest above you!</span>"
		return

/obj/spacepod/verb/fly_down()
	if( src.pilot == usr )
		set category = "Spacepod"
		set name = "Fly Downwards"
		set src = usr.loc

		var/turf/ground = get_turf( src )
		if( !istype( ground, /turf/space ) && !istype( ground,/turf/simulated/floor/open ))
			pilot << "<span class='warning'>\The [ground] is in the way!</span>"
			return

		var/turf/controllerlocation = locate(1, 1, z)
		for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
			if(controller.down)
				var/turf/below = locate(src.x, src.y, controller.down_target)

				if( !below.density )
					src.loc = below
					pilot << "You cruise downwards."
				else
					pilot << "<span class='warning'>There is a [below] in the way!</span>"
			else
				pilot << "<span class='warning'>There's nothing of interest below you!!</span>"
		return

/obj/spacepod/verb/move_inside()
	set category = "Object"
	set name = "Enter Pod"
	set src in oview(1)

	put_in_seat( usr )

/obj/spacepod/verb/exit_pod()
	set name = "Exit Pod"
	set category = "Spacepod"
	set src = usr.loc

	exit( usr )

/obj/spacepod/proc/toggleDoors( user as mob )
	for(var/obj/machinery/door/poddoor/P in oview(3,src))
		if(istype(P, /obj/machinery/door/poddoor/three_tile_hor) || istype(P, /obj/machinery/door/poddoor/three_tile_ver) || istype(P, /obj/machinery/door/poddoor/four_tile_hor) || istype(P, /obj/machinery/door/poddoor/four_tile_ver))
			if( P.check_access( equipment_system.card ))
				if(P.density)
					P.open()
					return 1
				else
					P.close()
					return 1
			else if( user )
				user << "<span class='warning'>Access denied.</span>"
			return
	if( user )
		user << "<span class='warning'>You are not near any pod doors.</span>"
	return

/obj/spacepod/verb/useDoors()
	if(src.pilot)
		set name = "Toggle Nearby Pod Doors"
		set category = "Spacepod"
		set src = usr.loc

		toggleDoors( usr )

/*
/obj/spacepod/verb/autopilot()
	if( equipment_system.autopilot )
		if( src.pilot == usr )
			set name = "Activate Autopilot"
			set category = "Spacepod"
			set src = usr.loc

			equipment_system.autopilot.prompt()
*/

/obj/spacepod/proc/fireWeapon( user as mob )
	if( !equipment_system )
		return

	if( equipment_system.weapon_system )
		if( user )
			user << "<span class='warning'>ERROR: This pod does not have any active weapon systems.</span>"
		return

	equipment_system.weapon_system.fire_weapons()

/obj/spacepod/verb/useWeapon()
	if( equipment_system.weapon_system )
		if( src.pilot == usr )
			set name = "Fire Pod Weapons"
			set desc = "Fire the weapons."
			set category = "Spacepod"
			set src = usr.loc

			fireWeapon( usr )

obj/spacepod/verb/toggleLights()
	if( src.pilot == usr )
		set name = "Toggle Lights"
		set category = "Spacepod"
		set src = usr.loc

		lightsToggle()

/obj/spacepod/proc/activateWarpBeacon( user as mob )
	for(var/obj/machinery/computer/gate_beacon_console/C in orange(src.loc, 5)) // Finding suitable VR platforms in area
		if(alert(user, "Would you like to interface with: [C]?", "Confirm", "Yes", "No") == "Yes")
			C.gate_prompt( pilot )
			occupants_announce( "<span class='notice'>Activated charging sequence for nearby bluespace beacon.</span>" )

/obj/spacepod/verb/useWarpBeacon()
	if( src.pilot == usr )
		set name = "Use Nearby Warp Beacon"
		set category = "Spacepod"
		set src = usr.loc

		activateWarpBeacon( usr )

/obj/spacepod/verb/dumpCargo()
	if( src.pilot == usr )
		if( equipment_system.cargohold )
			set name = "Dump Cargo"
			set category = "Spacepod"
			set src = usr.loc

			equipment_system.cargohold.dump_prompt( usr )

/obj/spacepod/proc/lightsToggle()
	lights = !lights
	if(lights)
		set_light(light_range + lights_power)
	else
		set_light(light_range - lights_power)
	occupants_announce( "Spacepod lights toggled [lights?"on":"off"]." )
	return

/obj/spacepod/proc/sectorLocate( user as mob )
	usr << "<span class='notice'>Triangulating sector location through bluespace beacons, please standby... (This may take up to 15 seconds)</span>"

	if( !do_after( user, rand( 50, 150 )))
		usr << "<span class='warning'>ERROR: Inaccurate readings, cannot calculate sector. Please stay still next time.</span>"
		return

	var/obj/effect/map/sector = map_sectors["[z]"]
	if( !sector )
		usr << "<span class='warning'>ERROR: Critical error with the bluespace network!</span>"
		return

	usr << "<span class='notice'>You are currently located in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]</span>"

/obj/spacepod/verb/useSectorLocate()
	set category = "Spacepod"
	set name = "Triangulate Sector"
	set src = usr.loc

	sectorLocate( usr )

/obj/spacepod/proc/switchWeapon( user as mob )
	var/list/weapons = list()
	for( var/weapon in equipment_system )
		if( istype( weapon, /obj/item/device/spacepod_equipment/weaponry ))
			weapons.Add( weapon )
	var/selected = equipment_system.weapon_system
	selected = input( user, "Select your preferred weapon system.", "Select Weapon System", selected ) in weapons
	equipment_system.weapon_system = selected

/obj/spacepod/verb/useSwitchWeapon()
	if( src.pilot == usr )
		if( equipment_system.weapon_system )
			set category = "Spacepod"
			set name = "Switch Weapon System"
			set src = usr.loc

			switchWeapon( usr )

/obj/spacepod/complete/New()
	..()

	equipment_system.equip( new /obj/item/weapon/cell/super )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/engine )

/obj/spacepod/command
	name = "\improper command spacepod"
	desc = "A sleek command space pod."
	icon_state = "pod_com"

/obj/spacepod/command/New()
	..()

	equipment_system.equip( new /obj/item/pod_parts/armor/command )

/obj/spacepod/command/complete/New()
	..()

	equipment_system.equip( new /obj/item/weapon/cell/super )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/engine )

/obj/spacepod/security
	name = "\improper security spacepod"
	desc = "An armed security spacepod with reinforced armor plating."
	icon_state = "pod_sec"

/obj/spacepod/security/New()
	..()

	equipment_system.equip( new /obj/item/pod_parts/armor/security )

/obj/spacepod/security/complete/New()
	..()

	equipment_system.equip( new /obj/item/device/spacepod_equipment/engine/einstein/galileo )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/shield )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/weaponry/taser )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/misc/tracker )
	equipment_system.equip( new /obj/item/weapon/cell/super )

	equipment_system.misc_system.enabled = 1
	return

/obj/spacepod/shuttle
	name = "\improper shuttle"
	desc = "A pod refitted as a transport shuttle. Doesn't have any sort of protection at all."
	icon_state = "pod_shuttle"

/obj/spacepod/shuttle/New()
	..()

	equipment_system.equip( new /obj/item/pod_parts/armor/shuttle )

/obj/spacepod/shuttle/complete/New()
	..()

	equipment_system.equip( new /obj/item/device/spacepod_equipment/engine/einstein/fourier )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/misc/tracker )
	equipment_system.equip( new /obj/item/weapon/cell/super )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/seat )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/seat )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/seat )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/seat )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/misc/cargo )

	equipment_system.misc_system.enabled = 1
	return

/obj/spacepod/dev/New()
	..()

	equipment_system.max_size = 1000
	equipment_system.equip( new /obj/item/device/spacepod_equipment/engine/magic )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/weaponry/taser )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/weaponry/burst_taser )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/weaponry/laser )
	equipment_system.equip( new /obj/item/pod_parts/armor/security )
	equipment_system.equip( new /obj/item/weapon/cell/infinite )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/shield )
	equipment_system.equip( new /obj/item/device/spacepod_equipment/misc/tracker )
	equipment_system.misc_system.enabled = 1
	return

#undef DAMAGE
#undef FIRE
