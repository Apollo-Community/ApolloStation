// Seeing as none of these will change throughout a round, and we had a fuckton of defines anyways, I made them into defines. For the blood god.
#define SM_SAFE_ALERT "Crystaline hyperstructure returning to safe operating levels."
#define SM_WARNING_ALERT "Danger! Crystal hyperstructure instability!"
#define SM_EMERGENCY_ALERT "CRYSTAL DELAMINATION IMMINENT."

#define TRANSFORM_DISTANCE_MOD 2 // Size/this is maximum distance from SM during burst for transformation to Nucleation

/obj/machinery/power/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal. \red You get headaches just from looking at it."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "supermatter"
	var/base_icon = "base"

	density = 1
	anchored = 0

	light_range = 3
	light_color = SM_DEFAULT_COLOR
	light_power = 3

	color = SM_DEFAULT_COLOR

	var/bare = 0

	var/smlevel = 1

	var/power = 0
	var/power_percent = 0
	var/power_archived = 0

	var/damage = 0
	var/damage_archived = 0

	var/safe_alert = ""
	var/safe_warned = 0

	var/emergency_issued = 0
	var/lastwarning = 0
	var/warning_point = 100

	var/emergency_point = 500
	var/explosion_point = 1000

	var/obj/item/device/radio/radio

	var/grav_pulling = 0
	var/exploded = 0

	var/debug = 0

/obj/machinery/power/supermatter/New()
	. = ..()

	update_icon()

	radio = new (src)


/obj/machinery/power/supermatter/Destroy()
	del radio
	. = ..()

/obj/machinery/power/supermatter/proc/explode()
	message_admins("Supermatter exploded at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)", "LOG:")
	log_game("Supermatter exploded at ([x],[y],[z])")
	grav_pulling = 1
	exploded = 1

	spawn(smvsc.detonate_delay * 10)
		var/turf/epicenter = get_turf(src)

		explosion(epicenter, \
		          min(1 * (smvsc.explosion_size + (power_percent * smlevel)), (smvsc.explosion_size) * 3), \
		          min(2 * (smvsc.explosion_size + (power_percent * smlevel)), (smvsc.explosion_size) * 4), \
		          min(3 * (smvsc.explosion_size + (power_percent * smlevel)), (smvsc.explosion_size) * 5), \
		          min(4 * (smvsc.explosion_size + (power_percent * smlevel)), (smvsc.explosion_size) * 6), 1)

		sleep(1) // just need to catch our breath

		supermatter_delamination(epicenter, \
		          min(4 * (smvsc.explosion_size + (power_percent * smlevel)), (smvsc.explosion_size) * 6), 1, smlevel)
		del src
		return

//Changes color and light_range of the light to these values if they were not already set
/obj/machinery/power/supermatter/proc/shift_light( var/clr, var/lum = light_range )
	light_color = clr
	light_range = lum

	color = clr

	set_light( light_range, light_power, light_color )

/obj/machinery/power/supermatter/proc/announce_warning()
	var/integrity = damage / (explosion_point + (( smvsc.fusion_stability / explosion_point ) * smlevel ))
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	var/alert_msg = " Integrity at [integrity]%"

	if(damage > emergency_point)
		alert_msg = SM_EMERGENCY_ALERT + alert_msg
		lastwarning = world.timeofday - smvsc.warning_delay * 5
	else if(damage >= damage_archived) // The damage is still going up
		safe_warned = 0
		alert_msg = SM_WARNING_ALERT + alert_msg
		lastwarning = world.timeofday
	else if(!safe_warned)
		safe_warned = 1 // We are safe, warn only once
		alert_msg = SM_SAFE_ALERT
		lastwarning = world.timeofday
	else
		alert_msg = null
	if(alert_msg)
		radio.autosay(alert_msg, "Supermatter Monitor")

/obj/machinery/power/supermatter/process()
	power_percent = ( power/( smvsc.base_power*( smlevel ** smvsc.fusion_power ))) // This was a fucking pain to use over and over again.

	// SUPERMATTER LOCATION CHECK
	if( turfCheck() )
		return

	// SUPERMATTER ALERT CHECK
	alertCheck()

	if(grav_pulling)
		supermatter_pull()

	// SUPERMATTER GAS INTERACTIONS
	hanldeEnvironment()

	// SUPERMATTER CRITICAL FAILURE
	if( prob( smlevel/smvsc.crit_stability ))
		critFail()

	// SUPERMATTER PSIONIC SHIT
	psionicBurst()

	// SUPERMATTER RADIATION
	radiate()

	// SUPERMATTER DECAY
	decay()

	return 1

/obj/machinery/power/supermatter/proc/turfCheck()
	var/turf/L = loc
	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL
	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return 1 //Yeah just stop.

/obj/machinery/power/supermatter/proc/alertCheck()
	var/turf/L = loc
	if(damage > (explosion_point + ( (smvsc.fusion_stability / explosion_point) * smlevel) ))
		if(!exploded)
			if(!istype(L, /turf/space))
				announce_warning()
			explode()
	else if(damage > warning_point && (world.timeofday - lastwarning) >= smvsc.warning_delay * 10) // while the core is still damaged and it's still worth noting its status
		if(!istype(L, /turf/space))
			announce_warning()

/obj/machinery/power/supermatter/proc/hanldeEnvironment()
	var/damage_inc_limit = ( power_percent * smvsc.damage_factor * 100)
	var/turf/L = loc

	var/datum/gas_mixture/removed = null
	var/datum/gas_mixture/env = null

	// Getting the environment gas
	if(!istype(L, /turf/space))
		env = L.return_air()
		removed = env.remove( max( env.total_moles/10, min( smlevel * smvsc.consumption_rate, env.total_moles )))

	if(!env || !removed || !removed.total_moles)
		damage += (10 * smlevel * smvsc.damage_factor)

	else
		damage_archived = damage

		// Awan suggested causing the SM to have different reactions to different gasses. So Let's try this.

		// Store these variables for reactions.
		var/oxygen = removed.gas["oxygen"]
		var/phoron = removed.gas["phoron"]
		var/carbon = removed.gas["carbon_dioxide"]
		var/sleepy = removed.gas["sleeping_agent"]

		if(sleepy)
			power = max(0, power-sleepy)

		if(oxygen)
			power += oxygen*max(0.01, (1-power_percent))*(smvsc.gas_rate/10)*(smlevel**smvsc.fusion_power)
			if (prob(oxygen/(10*smvsc.crit_stability)))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(oxygen/smvsc.crit_stability, 1, src)
				s.start()

		if(carbon)
			power += carbon*max(0.01, (1-power_percent))*smvsc.gas_rate*(smlevel**smvsc.fusion_power)
			carbon = 0

		if(phoron)
			if (removed.temperature < smvsc.crit_temp)
				var/heal_amt = max(0, (smvsc.crit_temp-removed.temperature)/smvsc.crit_temp)*(phoron*smvsc.crystal_rate)
				damage = max(0, damage - heal_amt)
				phoron = 0
			else
				power += phoron*max(0.01, (1-power_percent))*(smvsc.gas_rate/5)
				phoron = 0

		phoron += (damage/(explosion_point + ( (smvsc.fusion_stability / explosion_point) * smlevel) ))*(smlevel**smvsc.fusion_power)
		phoron += oxygen/20
		oxygen -= oxygen/10

		var/need_oxy = ((smvsc.suffocation_moles/10) * (smlevel**smvsc.fusion_power))-(smvsc.safe_level*(oxygen+(smvsc.suffocation_moles/10)))

		if (need_oxy>0)
			phoron+=need_oxy
			power-=need_oxy
			damage+=need_oxy

		if(removed.temperature >= smvsc.crit_temp)
			damage += min(damage_inc_limit, (removed.temperature-smvsc.crit_temp)*(smvsc.heat_damage/1000))

		transfer_energy()

		//Release reaction gasses
		removed.gas["phoron"] = phoron
		removed.gas["oxygen"] = oxygen
		removed.gas["sleeping_agent"] = sleepy
		removed.gas["carbon_dioxide"] = carbon

		removed.add_thermal_energy(power*smvsc.thermal_factor*(power_percent**2))
		env.merge(removed)

/obj/machinery/power/supermatter/proc/psionicBurst()
	for(var/mob/living/carbon/human/l in oview(src, 7)) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			if(!isnucleation(l))
				l.hallucination = max(0, min(smlevel*smvsc.psionic_power, l.hallucination + ((power/smvsc.base_power)*smvsc.psionic_power) * sqrt(1 / max(1,get_dist(l, src)))))
			else
				l.hallucination = max(0, min(smlevel*(smvsc.psionic_power/5), l.hallucination + ((power/smvsc.base_power)*(smvsc.psionic_power/5)) * sqrt(1 / max(1,get_dist(l, src)))))

/obj/machinery/power/supermatter/proc/radiate()
	for(var/mob/living/l in range(src, round(sqrt(((power/smvsc.base_power)*7) / 5))))
		var/rads = ((power/smvsc.base_power)*smvsc.radiation_power) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)

/obj/machinery/power/supermatter/proc/decay()
	var/decay = min(0.01, (power_percent**5)) * smvsc.decay_rate
	power = max(0, power-decay)

/obj/machinery/power/supermatter/proc/critFail()
	var/crit_damage = rand(0, (smvsc.crit_danger * (smlevel ** smvsc.fusion_power) ) )	// Take a bunch of damage. 5 = 500, 10 = 2000, 15 = 4500, 20 = 8000

	damage += crit_damage

	var/integrity = crit_damage / (explosion_point + ( (smvsc.fusion_stability / explosion_point) * smlevel) )
	integrity = round(100 - integrity * 100)
	integrity = integrity < 0 ? 0 : integrity
	radio.autosay("CRITICAL FAILURE! [integrity]% Integrity Lost!", "Supermatter Monitor")
	announce_warning()

/obj/machinery/power/supermatter/proc/smLevelChange( var/level_increase = 1 )
	smlevel += level_increase

	power_archived = power_percent
	update_icon()

/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(istype(Proj, /obj/item/projectile/beam))
		power += Proj.damage
	else
		damage += Proj.damage
	return 0

/obj/machinery/power/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"
	return

/obj/machinery/power/supermatter/attack_ai(mob/user as mob)
	user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"

/obj/machinery/power/supermatter/attack_hand(mob/user as mob)
	if( isnucleation( user )) // Nucleation's can touch it to heal!
		var/mob/living/L = user
		user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow before they calmly pull away from it.</span>",\
		"\blue You reach out and touch \the [src]. Everything seems to go quiet and slow down as you feel your crystal structures mending.\"</span>", \
		"<span class=\"danger\">Everything suddenly goes silent.\"</span>")
		L.rejuvenate()
		L.sleeping = max(L.sleeping+2, 10)
		return

	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		var/distance = get_dist(R, src)
		if(distance <= 15)
			//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
			R.receive_pulse(power * 0.3 * (min(3/distance, 1))**2)
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/tongs))
		var/obj/item/weapon/tongs/T = W
		if (T.held)
			Consume(T.held)
			T.held = null
			T.update_icon()
			return

	if(istype(W, /obj/item/weapon/shard/supermatter))
		var/obj/item/weapon/shard/supermatter/S = W
		Consume(S)
		return

	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_effect((power/smvsc.base_power)*smvsc.radiation_power, IRRADIATE)

/obj/machinery/power/supermatter/ex_act()
	return

/obj/machinery/power/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		if( isnucleation( AM )) // Nucleation's biology doesn't react to this
			return
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
	else if(istype(AM, /obj/machinery/power/supermatter))
		AM.visible_message("<span class=\"warning\">\The [AM] fuses with \the [src].</span>",\
		"<span class=\"warning\">You hear a loud shriek as you are washed with a wave of heat.</span>")
	else if( istype(AM, /obj/item/weapon/shard/supermatter))
		AM.visible_message("<span class=\"warning\">\The [AM] fuses with \the [src].</span>",\
		"<span class=\"warning\">You hear a loud shriek as you are washed with a wave of heat.</span>")
	else if(!grav_pulling) //To prevent spam, detonating supermatter does not indicate non-mobs being destroyed
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	Consume(AM)


/obj/machinery/power/supermatter/proc/Consume(var/mob/living/user)
	if( isnucleation( user )) // Nucleation's biology doesn't react to this
		return

	if(istype(user))
		user.dust()
		power += smvsc.base_power/8
	else
		if (istype(user, /obj/machinery/power/supermatter))
			var/obj/machinery/power/supermatter/S = user
			var/newsm = S.smlevel + smlevel
			var/newdm = ((S.smlevel/newsm)*S.damage)+((smlevel/newsm)*damage)
			var/newpw = ((S.smlevel/newsm)*S.power)+((smlevel/newsm)*power)
			smlevel = newsm
			damage = newdm
			power = newpw
			power += (smvsc.base_power/2 * (S.smlevel**smvsc.fusion_power))  // Get a ton of power from the fusion.
			for(var/mob/living/l in range(src, round(sqrt(((power/smvsc.base_power)*7) / 5))))
				var/rads = ((power/smvsc.base_power)*smvsc.radiation_power) * sqrt( 1 / get_dist(l, src) )
				l.apply_effect(rads, IRRADIATE)
		if (istype(user, /obj/item/weapon/shard/supermatter))
			var/obj/item/weapon/shard/supermatter/S = user
			smlevel += ((S.size)/100)
			for(var/mob/living/l in range(src, round(sqrt(((power/smvsc.base_power)*7) / 5))))
				var/rads = ((power/smvsc.base_power)*smvsc.radiation_power) * sqrt( 1 / get_dist(l, src) ) // Increased range for radiation. Eventually you'll be radiating the entire station.
				l.apply_effect(rads, IRRADIATE)
		update_icon()
		qdel( user )
		return

	power += smvsc.base_power/8

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/l in range(src, round(sqrt(((power/smvsc.base_power)*7) / 5))))
		if(l in view())
			l.show_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class=\"warning\">The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			l.show_message("<span class=\"warning\">You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)
		var/rads = ((power/smvsc.base_power)*smvsc.radiation_power) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)



/obj/machinery/power/supermatter/update_icon()
	color = getSMColor( smlevel )

	shift_light( color )

/obj/machinery/power/supermatter/proc/supermatter_pull()
	//following is adapted from singulo code
	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1
	// Let's just make this one loop.
	for(var/atom/X in orange(10,src))
		// Movable atoms only
		if(istype(X, /atom/movable))
			if(is_type_in_list(X, uneatable))	continue
			if(!grav_pulling)	return
			if(((X) && (!istype(X,/mob/living/carbon/human))))
				spawn( 0 )
					step_towards(X,src)
				if(istype(X, /obj)) //unanchored objects pulled twice as fast
					var/obj/O = X
					if(!O.anchored)
						spawn( 0 )
							step_towards(X,src)
				else
					spawn( 0 )
						step_towards(X,src)
				if(istype(X, /obj/structure/window)) //shatter windows
					var/obj/structure/window/W = X
					W.ex_act(2.0)
			else if(istype(X,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						spawn( 0 )
							step_towards(H,src) //step just once with magboots
						continue
				spawn( 0 )
					step_towards(H,src) //step twice
					step_towards(H,src)

	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0
	return

/obj/machinery/power/supermatter/GotoAirflowDest(n) //Supermatter not pushed around by airflow
	return

/obj/machinery/power/supermatter/RepelAirflowDest(n)
	return

/obj/machinery/power/supermatter/bare
	icon_state = "supermatter_bare"
	bare = 1
