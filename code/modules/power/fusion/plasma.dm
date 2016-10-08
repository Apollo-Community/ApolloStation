/obj/machinery/power/fusion/plasma
	dir = 0
	icon = 'icons/obj/fusion.dmi'
	icon_state = "plas_cool"
	density = 1
	var/transfering = 0
	var/datum/gas_mixture/air_contents = null
	var/list/partners = list()
	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/network = null
	ready = 1
	anchored = 1

//When fusion happens energize the core copied over from rad collectors.
/obj/machinery/power/fusion/plasma/proc/transfer_energy(var/neurons = 0)
	for(var/obj/machinery/power/fusion/core/C in fusion_controller.fusion_components)
		var/distance = get_dist(C, src)
		if(distance && distance <= 15)		//sanity for 1/0
			//stop their being a massive benifit to moving the rad collectors closer
			if(distance < 3)	distance = 2.67			// between 25 - 50k benifit 	(level 1)
			//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
			//The closer the better radiation intensity is inversely to space traveled.
			C.receive_neutrons(neurons/(distance*0.3))
	return

/obj/machinery/power/fusion/plasma/proc/toggle_heat_transfer()
	//Init part and partner check
	transfering = !transfering
	if (!transfering)
		if(partners.len != 0)
			partners.Cut()
		return

	if(partners.len < 2)
		//Get partners -90 deg from you
		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,turn(src.dir, 90)))
			if(target.dir == get_dir(target, src))	//Is if facing you our way ?
				partner = target
				partner.partner = src
				break

		//Get partner 90 deg from you
		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src, turn(src.dir, -90)))
			if(target.dir == get_dir(target, src))
				partner = target
				partner.partner = src
				break

		if(partners.len == 0)	//No partner was found :(
			return 0
		air_contents = fusion_controller.gas_contents

/obj/machinery/power/fusion/plasma/attack_hand(mob/user as mob)
	var/tmp/mob/living/M = user
	M.dust()

/obj/machinery/power/fusion/plasma/bullet_act(obj/item/projectile/P)
	return 0 //Will there be an impact? Who knows. Will we see it? No.

/obj/machinery/power/fusion/plasma/Bump(atom/A)
	if(istype(A, /mob/living))
		var/tmp/mob/living/M = A
		if(fusion_controller.gas_contents.temperature < 100000)
			M.dust()
			return
		else if(fusion_controller.gas_contents.temperature < 1000)
			M.apply_damage(rand(50, 100), damagetype = BURN)

/obj/machinery/power/fusion/plasma/update_icon()
	return