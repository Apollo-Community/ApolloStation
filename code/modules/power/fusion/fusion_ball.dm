var/global/list/fusion_balls = list()
//Plasma ball singulo kind of all destructive bs kills everyone hahaha (Based upon lord singulo)
//The fusion ball makes use of Rotem12's Lighting for byond (https://github.com/Rotem12/Lightning).
/obj/fusion_ball/
	name = "Fusion Event Ball"
	desc = "An out of controll fusion reaction."
	icon = 'icons/rust.dmi'
	icon_state = "emfield_s1"
	anchored = 1
	density = 0
	layer = 6
	light_range = 7
	unacidable = 1 //Don't comment this out.
	can_fall = 0 // can't fall down z-levels
	var/start_time = 0 //At what time did we start
	var/end_time = 0 //At what time are we going to end
	var/middle_time = 0	//Right in the middle of start and end.
	var/escalate = 0 //Are we at full or half size ?
	var/shock_range = 5 //How far away do we sock people ?
	var/kill_shock_range = 2 //How var away do we fry people ?
	var/move_self = 1 //Do we move on our own?
	var/target = null //Its target. Moves towards the target if it has one.
	var/obj/machinery/power/smes/smes_target = null //The temp target it move to if no beacon is set.
	var/last_failed_movement = 0 //Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing.
	var/chained = 0//Adminbus chain-grab
	var/emp_change = 0
	var/x_offset = 0
	var/y_offset = 0
	var/stage = 1

/obj/fusion_ball/New(loc)
	//CARN: admin-alert for chuckle-fuckery.
	admin_investigate_setup()
	start_time = world.realtime
	end_time = start_time + 300
	middle_time = start_time + 150
	set_light(light_range, 7, COLOR_WHITE)
	..()
	processScheduler.enableProcess("fusion_ball")	//To make sure its not checking for balls when there are non.
	fusion_balls += src
	for(var/obj/machinery/power/singularity_beacon/singubeacon in machines)
		if(singubeacon.active)
			target = singubeacon
			break

/obj/fusion_ball/Destroy()
	explosion(get_turf(src), 4, 5, 6, 6)
	fusion_balls -= src
	..()

//Not a very smart move.
/obj/fusion_ball/attack_hand(mob/user as mob)
	kill_shock(user)
	return 1

/obj/fusion_ball/bullet_act(obj/item/projectile/P)
	return 0 //Will there be an impact? Who knows. Will we see it? No.

/obj/fusion_ball/Bump(atom/A)
	if(istype(A, /turf))
		return
	if(istype(A, /mob/living))
		kill_shock(A)
		return
		qdel(A)

/obj/fusion_ball/Bumped(atom/A)
	if(istype(A, /turf))
		return
	if(istype(A, /mob/living))
		kill_shock(A)
		return
		qdel(A)

/obj/fusion_ball/process()
	check_time()
	move()
	shock()

/obj/fusion_ball/proc/check_time()
	if(world.realtime > end_time)
		Destroy()
	if(world.realtime > middle_time && !escalate)
		escalate()

/obj/fusion_ball/proc/escalate()
	stage = 2
	shock_range = 7
	kill_shock_range = 3
	icon = 'icons/effects/96x96.dmi'
	icon_state = "emfield_s3"
	x_offset = 32
	y_offset = 32

/obj/fusion_ball/attack_ai() //To prevent ais from killing itself be clicking on the ball of plasma (who would klick on a ball of plasma anyway)
	return

/obj/fusion_ball/proc/admin_investigate_setup()
	message_admins("A fusion ball has spawned at: ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>).")
	investigate_log("A fusion ball has spawned at: ([x], [y], [z]), src")

/obj/fusion_ball/proc/shock()
	//Darken turfs under you
	var/list/effected = list()
	effected += get_turf(src)
	var/turf/center = locate(src.x+1, src.y+1)
	effected += center
	effected += orange(2, center)
	for(var/turf/simulated/floor/f in effected)
		f.burn_tile()

	//Shock things.
	spawn()
		for(var/mob/living/M in ohearers(shock_range,src))	//if you are behind glass your are safe.(this returns only mobs !)
			var/dist = get_dist(M, src)
			if(dist > kill_shock_range)
				kill_shock(M)
				continue
			hurt_shock(M)
		var/list/viewers = oview(shock_range,src)
		//Shoot 3 emp bolts at random locations.
		for(var/i = 0, i <= 3, i++)
			var/obj/m = pick(viewers)
			emp(m)
			if(!istype(m, /turf/simulated/floor))
				continue
			var/turf/simulated/floor/f = m
			f.burn_tile()
	return

//Shoot EMP at a turf.
/obj/fusion_ball/proc/emp(obj/m)
	var/datum/effect/effect/system/lightning_bolt/bolt = new()
	bolt.start(src, m, sx_offset = x_offset, sy_offset = y_offset)
	playsound(src.loc, pick( 'sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg'), 100, 1)
	empulse(get_turf(m), 1, 1)

//Hurt (burn) shock target.
/obj/fusion_ball/proc/hurt_shock(var/mob/living/m)
	if(m.status_flags & GODMODE)
		return
	var/datum/effect/effect/system/lightning_bolt/bolt = new()
	bolt.start(src, m, sx_offset = x_offset, sy_offset = y_offset)
	playsound(src.loc, pick( 'sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg'), 100, 1)
	m.apply_damage(rand(10, 20), damagetype = BURN)
	m.apply_effect(rand(2.5, 5), effecttype = STUN)
	new/obj/effect/effect/sparks(get_turf(m))

//Kill (dustify) shock a target.
/obj/fusion_ball/proc/kill_shock(var/mob/living/m)
	if(m.status_flags & GODMODE)
		return
	var/datum/effect/effect/system/lightning_bolt/bolt = new()
	playsound(src.loc, pick( 'sound/effects/electr1.ogg', 'sound/effects/electr2.ogg', 'sound/effects/electr3.ogg'), 100, 1)
	bolt.start(src, m, sx_offset = x_offset, sy_offset = y_offset)
	new/obj/effect/effect/sparks(get_turf(m))
	m.dust()

//Movement handle, move one turf per processes tick.
/obj/fusion_ball/proc/move()
	var/movement_dir = pick(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
	if(isnull(smes_target))
		var/list/targets = list()
		for(var/obj/machinery/power/smes/S in machines)
			if(S.z != src.z)	//Lets not try to go to other z levels and only target smesses with juice in it.
				continue
			targets += S
		smes_target = pick(targets)
	if(smes_target)
		if(prob(70))
			movement_dir = get_dir(src,smes_target)
		if(smes_target.charge < 100)
			smes_target = null
	if(target && prob(60))
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	//Because get_step or step SUCKS.
	switch(movement_dir)
		if(NORTH)
			y += 1
		if(EAST)
			x += 1
		if(SOUTH)
			y -= 1
		if(WEST)
			x -= 1
		if(NORTHEAST)
			x += 1
			y += 1
		if(NORTHWEST)
			x -= 1
			y += 1
		if(SOUTHEAST)
			x += 1
			y -= 1
		if(SOUTHWEST)
			x -= 1
			y -= 1
	return 1