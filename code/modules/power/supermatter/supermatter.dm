/*
	GAS EFFECTS
	PHORON: Heals the supermatter up until level 9
	N2O: Slows down power production
	O2: Acts as a turbocharger, multiplying heat and power production by a certain amount.
		Is required to keep a stable engine after level 5. If an engine is starved of O2, it will start experiencing critical failures.
	CO2: Fire suppressant, but also increases heat output by a small amount if SM level is 3 or above
*/

/obj/machinery/power/supermatter
	name = "supermatter core"
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

	var/smlevel = 1

	var/power = 0
	var/power_percent = 0

	var/damage = 0
	var/damage_max = 1000
	var/damage_archived = 0
	var/emergency_point = 500

	var/safe_alert = ""
	var/safe_warned = 0

	var/emergency_issued = 0
	var/lastwarning = 0
	var/warning_delay = 10 // Once every 10 seconds, announce the status
	var/warning_point = 100

	var/last_crit_check = 0
	var/crit_delay = 60 // One minute between critical failure checks

	var/obj/item/device/radio/radio

	var/grav_pulling = 0
	var/exploded = 0

	var/debug = 0

	var/settings = null

/obj/machinery/power/supermatter/New( loc as turf, var/level = 1 )
	. = ..()

	settings = sm_levels

	if( level > MAX_SUPERMATTER_LEVEL )
		level = MAX_SUPERMATTER_LEVEL
	else if( level < MIN_SUPERMATTER_LEVEL )
		level = MIN_SUPERMATTER_LEVEL

	if( level != MIN_SUPERMATTER_LEVEL )
		smlevel = level

	spawn(0)
		update_icon()

	radio = new (src)

/obj/machinery/power/supermatter/Destroy()
	qdel( radio )
	. = ..()

/obj/machinery/power/supermatter/proc/explode()
	message_admins("Supermatter exploded at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)", "LOG:")
	log_game("Supermatter exploded at ([x],[y],[z])")
	grav_pulling = 1
	exploded = 1

	spawn( getSMVar( smlevel, "pull_time" ) * TICKS_IN_SECOND )
		var/turf/epicenter = get_turf(src)

		explosion(epicenter, \
		          getSMVar( smlevel, "explosion_size" )/3, \
		          getSMVar( smlevel, "explosion_size" )/2, \
		          getSMVar( smlevel, "explosion_size" ), \
		          getSMVar( smlevel, "explosion_size" )*2, 1)

		supermatter_delamination( epicenter, getSMVar( smlevel, "delamination_size" ), smlevel, 1 )
		qdel( src )
		return

//Changes color and light_range of the light to these values if they were not already set
/obj/machinery/power/supermatter/proc/shift_light( var/clr, var/lum = light_range )
	light_color = clr
	light_range = lum

	color = clr

	set_light( light_range, light_power, light_color )

/obj/machinery/power/supermatter/proc/announce_warning()
	var/integrity = calc_integrity()
	var/alert_msg = " Integrity at [integrity]%"

	if(damage > emergency_point)
		alert_msg = SM_EMERGENCY_ALERT + alert_msg
		lastwarning = world.timeofday - warning_delay * 5
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

/obj/machinery/power/supermatter/proc/calc_integrity()
	var/integrity = damage / damage_max
	integrity = round( MAX_SM_INTEGRITY - ( integrity * MAX_SM_INTEGRITY))
	return integrity < 0 ? 0 : integrity

/obj/machinery/power/supermatter/process()
	power_percent = power/getSMVar( smlevel, "base_power" )

	// SUPERMATTER LOCATION CHECK
	if( turfCheck() )
		return

	// SUPERMATTER ALERT CHECK
	alertCheck()

	if(grav_pulling)
		supermatter_pull()

	// SUPERMATTER GAS INTERACTIONS
	hanldeEnvironment()

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
	if(istype( loc, /obj/machinery/phoron_desublimer/resonant_chamber ))
		return 1 // Resonant chambers are similar to bluespace beakers, they halt reactions within them

/obj/machinery/power/supermatter/proc/alertCheck()
	var/turf/L = loc
	if( damage > damage_max )
		if( !exploded )
			if( !istype( L, /turf/space ))
				announce_warning()
			explode()
	else if( damage > warning_point && ( world.timeofday - lastwarning ) >= warning_delay*TICKS_IN_SECOND ) // while the core is still damaged and it's still worth noting its status
		if( !istype( L, /turf/space ))
			announce_warning()

/obj/machinery/power/supermatter/proc/hanldeEnvironment()
	var/turf/L = loc

	var/datum/gas_mixture/removed = null
	var/datum/gas_mixture/env = null

	// Getting the environment gas
	if(!istype(L, /turf/space))
		env = L.return_air()
		removed = env.remove( max( env.total_moles/10, min( smlevel * getSMVar( smlevel, "consumption_rate" ), env.total_moles )))

	// If we're in a vacuum, heat can't escape the core, so we'll get damaged
	if(!env || !removed || !removed.total_moles)
		damage += getSMVar( smlevel, "vacuum_damage" )
		return

	damage_archived = damage

	var/heat = getSMVar( smlevel, "thermal_factor" ) // the amount of heat we release

	// Awan suggested causing the SM to have different reactions to different gasses. So Let's try this.
	// Store these variables for reactions.
	var/oxygen = removed.gas["oxygen"]
	var/phoron = removed.gas["phoron"]
	var/carbon = removed.gas["carbon_dioxide"]
	var/sleepy = removed.gas["sleeping_agent"]

	// N2O handling
	if(sleepy)
		power = max( 0, power-( sleepy*getSMVar( smlevel, "n2o_power_loss" )))
		sleepy = 0

	// Oxygen handling
	if(oxygen)
		power = max( 0, power+( power*( oxygen*getSMVar( smlevel, "o2_turbo_multiplier" ))))
		oxygen = 0
	else
		if( prob( getSMVar( smlevel, "crit_fail_chance" )) && delayPassed( crit_delay, last_crit_check ))
			critFail()
		last_crit_check = world.timeofday
		phoron = max( 0, phoron+getSMVar( smlevel, "suffocation_damage" ))
		damage = max( 0, damage+getSMVar( smlevel, "suffocation_damage" ))

	// CO2 handling
	if(carbon)
		heat = max( 0, heat+( heat*( carbon*getSMVar( smlevel, "co2_heat_multiplier" )))) // Carbon reacts violently with supermatter, creating heat and leaving O2
		oxygen += carbon
		carbon = 0

	// Temperature & phoron handling
	if (removed.temperature < getSMVar( smlevel, "heat_damage_level" ))
		if(phoron)
			damage = max( 0, damage-( phoron*getSMVar( smlevel, "phoron_heal_rate" )))
	else
		var/delta_temp = removed.temperature-getSMVar( smlevel, "heat_damage_level" )
		damage = max( 0, ( delta_temp*getSMVar( smlevel, "damage_per_degree" )))

	if( power_percent > OVERCHARGE_LEVEL ) // If we're more than 120%
		heat = max( 0, heat+( heat*getSMVar( smlevel, "overcharge_heat_multiplier" )))
		if( prob( getSMVar( smlevel, "crit_fail_chance" )))
			spark()

	// Release phoron & oxygen
	var/temp_percent = ( removed.temperature/getSMVar( smlevel, "heat_damage_level" ))
	phoron = max( 0, phoron+temp_percent*getSMVar( smlevel, "phoron_release" ))
	oxygen = max( 0, oxygen+temp_percent*getSMVar( smlevel, "o2_release" ))

	//Release reaction gasses
	removed.gas["phoron"] = phoron
	removed.gas["oxygen"] = oxygen
	removed.gas["sleeping_agent"] = sleepy
	removed.gas["carbon_dioxide"] = carbon

	removed.add_thermal_energy( power*heat*( power_percent**2 ))
	env.merge(removed)

/obj/machinery/power/supermatter/proc/psionicBurst()
	for(var/mob/living/carbon/human/l in oview(src, 7)) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			if(!isnucleation(l))
				l.hallucination = max(0, getSMVar( smlevel, "psionic_power" ) * sqrt(1 / max(1,get_dist(l, src))))
			else // Nucleations get less hallucinatoins
				l.hallucination = max(0, getSMVar( smlevel, "psionic_power" )/5 * sqrt(1 / max(1,get_dist(l, src))))

/obj/machinery/power/supermatter/proc/radiate()
	for(var/mob/living/l in range( get_turf(src), round( sqrt(( power/getSMVar( smlevel, "base_power" ))*7 )/5 )))
		var/rads = ((power/getSMVar( smlevel, "base_power" ))*getSMVar( smlevel, "radiation_power" )) * sqrt( 1 / get_dist(l, get_turf(src)) )
		l.apply_effect(rads, IRRADIATE)

	transfer_energy()

/obj/machinery/power/supermatter/proc/decay()
	var/decay = max( getSMVar( smlevel, "minimum_decay" ), (power-getSMVar( smlevel, "base_power" ))*getSMVar( smlevel, "decay" ))
	power = max(0, power-decay)

/obj/machinery/power/supermatter/proc/critFail()
	var/crit_damage = rand( 0, getSMVar( smlevel, "crit_fail_damage" ))

	damage += crit_damage

	// A wave burst during a critical failure
	supermatter_delamination( get_turf( src ), smlevel*3, smlevel, 0, 0 )

	var/integrity = calc_integrity()
	radio.autosay("CRITICAL STRUCTURE FAILURE: [MAX_SM_INTEGRITY-integrity]% Integrity Lost!", "Supermatter Monitor")
	announce_warning()

/obj/machinery/power/supermatter/proc/spark()
	// Light up some sparks
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up( 3, 1, src )
	s.start()

/obj/machinery/power/supermatter/proc/smLevelChange( var/level_increase = 1 )
	smlevel += level_increase

	update_icon()

/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.

	if(istype(Proj, /obj/item/projectile/beam))
		power += getSMVar( smlevel, "emitter_power" )
		damage += getSMVar( smlevel, "emitter_damage" )
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
		if(distance <= getSMVar( smlevel, "collector_range" ))
			//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
			R.receive_pulse(power*(distance/getSMVar( smlevel, "collector_range" )))
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/shard/supermatter))
		src.damage += W.force
		user.visible_message("<span class=\"warning\">\The [user] slashes at \the [src] with a [W] with a horrendous clash!</span>",\
		"<span class=\"danger\">You slash at \the [src] with \the [src] with a horrendous clash!\"</span>",\
		"<span class=\"warning\">A horrendous clash fills your ears.</span>")
		return

	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_effect((power/getSMVar( smlevel, "base_power" ))*getSMVar( smlevel, "radiation_power" ), IRRADIATE)

/obj/machinery/power/supermatter/ex_act()
	return

/obj/machinery/power/supermatter/Bumped( atom/AM as mob|obj )
	if(istype(AM, /mob/living))
		var/mob/living/M = AM
		if( !M.smVaporize()) // Nucleation's biology doesn't react to this
			return
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
	else if(!grav_pulling) //To prevent spam, detonating supermatter does not indicate non-mobs being destroyed
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	Consume(AM)

/obj/machinery/power/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user))
		if( user.smVaporize() )
			power += getSMVar( smlevel, "base_power" )/8
	else
		qdel( user )
		return

	update_icon()

	power += getSMVar( smlevel, "base_power" )/8

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/l in range(src, round(sqrt(((power/getSMVar( smlevel, "base_power" ))*7) / 5))))
		if(l in view())
			l.show_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class=\"warning\">The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			l.show_message("<span class=\"warning\">You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)
		var/rads = ((power/getSMVar( smlevel, "base_power" ))*getSMVar( smlevel, "radiation_power" )) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)

/obj/machinery/power/supermatter/update_icon()
	color = getSMVar( smlevel, "color" )
	name = getSMVar( smlevel, "color_name" ) + " " + initial(name)

	shift_light( color )

/obj/machinery/power/supermatter/proc/supermatter_pull()
	//following is adapted from singulo code
	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1
	// Let's just make this one loop.
	for(var/atom/X in orange( getSMVar( smlevel, "pull_radius" ), src ))
		X.singularity_pull(src, STAGE_FIVE)

	if(defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0
	return

/obj/machinery/power/supermatter/GotoAirflowDest(n) //Supermatter not pushed around by airflow
	return

/obj/machinery/power/supermatter/RepelAirflowDest(n)
	return

/obj/machinery/power/supermatter/MouseDrop(atom/over)
	if(!usr || !over) return
	if(!Adjacent(usr) || !over.Adjacent(usr)) return // should stop you from dragging through windows

	spawn(0)
		over.MouseDrop_T(src,usr)
	return