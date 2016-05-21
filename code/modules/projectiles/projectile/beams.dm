var/list/beam_master = list()
//Use: Caches beam state images and holds turfs that had these images overlaid.
//Structure:
//beam_master
//    icon_states/dirs of beams
//        image for that beam
//    references for fired beams
//        icon_states/dirs for each placed beam image
//            turfs that have that icon_state/dir

/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40
	damage_type = BURN
	flag = "laser"
	eyeblur = 4
	var/frequency = 1

/*
/obj/item/projectile/beam/process()
	var/reference = "\ref[src]" //So we do not have to recalculate it a ton
	var/first = 1 //So we don't make the overlay in the same tile as the firer
	spawn while(src) //Move until we hit something
		var/turf/T = get_turf( src )
		if( !istype( T ))
			qdel( src )
			break

		if((!( current ) || loc == current)) //If we pass our target
			current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)

		if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
			qdel(src) //Delete if it passes the world edge
			return

		step_towards(src, current) //Move~

		if(kill_count < 1)
			qdel(src)
		kill_count--

		if(!bumped && !isturf(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original)

		if(!first) //Add the overlay as we pass over tiles
			var/target_dir = get_dir(src, current) //So we don't call this too much

			//If the icon has not been added yet
			if( !("[icon_state][target_dir]" in beam_master) )
				var/image/I = image(icon,icon_state,10,target_dir) //Generate it.
				beam_master["[icon_state][target_dir]"] = I //And cache it!

			//Finally add the overlay
			T.loc.overlays += beam_master["[icon_state][target_dir]"]

			//Add the turf to a list in the beam master so they can be cleaned up easily.
			if(reference in beam_master)
				var/list/turf_master = beam_master[reference]
				if("[icon_state][target_dir]" in turf_master)
					var/list/turfs = turf_master["[icon_state][target_dir]"]
					turfs += loc
				else
					turf_master["[icon_state][target_dir]"] = list(loc)
			else
				var/list/turfs = list()
				turfs["[icon_state][target_dir]"] = list(loc)
				beam_master[reference] = turfs
		else
			first = 0

	cleanup(reference)
	return
*/

/obj/item/projectile/beam/Destroy()
	cleanup("\ref[src]")
	..()

/obj/item/projectile/beam/proc/cleanup(reference) //Waits .3 seconds then removes the overlay.
	src = null //we're getting deleted! this will keep the code running
	spawn(3)
		var/list/turf_master = beam_master[reference]
		for(var/laser_state in turf_master)
			var/list/turfs = turf_master[laser_state]
			for(var/turf/T in turfs)
				T.overlays -= beam_master[laser_state]
	return

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"
	eyeblur = 2


/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 30

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50


/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30


/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	flag = "laser"

	on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
				M.Weaken(5)
		return 1

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	damage = 60
	stun = 5
	weaken = 5
	stutter = 5

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	nodamage = 1
	agony = 40
	damage_type = HALLOSS

// emitter beam
// this was implemented kinda clunkily, so it doesn't work well as a base. keep its usage to emitter beams for now
/obj/item/projectile/beam/continuous
	name = "laser beam"
	icon = 'icons/obj/projectiles_continuous.dmi'
	icon_state = "emitter_end"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 4
	damage_type = BURN
	flag = "laser"
	eyeblur = 1

	var/power = 40
	var/process_delay = 2
	var/obj/item/projectile/beam/continuous/node1
	var/obj/item/projectile/beam/continuous/node2

/obj/item/projectile/beam/continuous/New(var/loc, var/parent)
	node1 = parent

	var/parent_power = 0
	if(istype(node1))
		parent_power = node1.power
	else if(istype(parent, /obj/machinery/power/emitter))
		var/obj/machinery/power/emitter/E = parent
		parent_power = E.active_power_usage / 1000

	update_power(parent_power)

	dir = node1.dir
	step(src, dir)

	process()

/obj/item/projectile/beam/continuous/Destroy()
	if(node1 && istype(node1))
		node1.node2 = null
	if(node2)
		qdel(node2)

	node1 = null
	node2 = null

	..()

/obj/item/projectile/beam/continuous/Bump(var/atom/movable/A)
	if(istype(A, /mob/living))
		var/mob/living/M = A
		M.bullet_act(src, "chest")

	if(istype(A, /turf))
		for(var/obj/O in A)
			O.bullet_act(src)
		A.bullet_act(src)

	if(istype(A, /obj))
		var/obj/O = A
		O.bullet_act(src)

	qdel(src)

/obj/item/projectile/beam/continuous/Crossed(var/atom/movable/A)
	// bit of dupe code, but it's so that your chatbox isn't spammed with the message
	if(istype(A, /mob/living))
		var/mob/living/M = A
		M << "<span class='warning'>You feel a concentrated, burning pain on your skin!</span>"
	Bump(A)
	return ..(A)

/obj/item/projectile/beam/continuous/process()
	if(!loc || loc.density || !node1)
		Bump(loc)
		return
	if(node2 && node2.loc) // don't try to propagate if there's a beam segment ahead
		spawn(process_delay)
			process()
		return
 
 	icon_state = "emitter_end"
	var/obj/item/projectile/beam/continuous/B = new(src.loc, src)
	node2 = B
	spawn(0)
		if(B.loc)
			if(B.z != z) // pls no travel through zs
				qdel(B)
				return
			B.process()
			if(B)	icon_state = "emitter"

	spawn(process_delay)
		process()

/obj/item/projectile/beam/continuous/proc/update_power(var/new_power)
	if(new_power)
		power = new_power

	alpha = min(255, 255 * (power / EMITTER_POWER_MAX))
	damage = power / 10

	if(node2)
		node2.update_power(power)