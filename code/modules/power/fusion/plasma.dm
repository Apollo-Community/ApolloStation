/obj/machinery/power/fusion/plasma
	dir = 0
	icon = 'icons/obj/fusion.dmi'
	icon_state = "plas_cool"
	density = 0
	var/transfering = 0
	var/datum/gas_mixture/air_contents = null
	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/network = null
	ready = 1

//When fusion happens energize the core copied over from rad collectors.
/obj/machinery/power/fusion/plasma/proc/transfer_energy(var/neurons = 0)
	for(var/obj/machinery/power/fusion/core/C in fusion_controller.fusion_components)
		var/distance = get_dist(C, src)
		if(distance && distance <= 10)		//sanity for 1/0
			//stop their being a massive benifit to moving the rad collectors closer
			if(distance < 3)	distance = 2.67			// between 25 - 50k benifit 	(level 1)
			//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
			//The closer the better radiation intensity is inversely to space traveled.
			C.receive_neutrons(neurons/(distance**2))
	return

/obj/machinery/power/fusion/plasma/proc/toggle_heat_transfer()
	//Init part and partner check
	transfering = !transfering
	if (!transfering)
		if(!isnull(partner))
			partner.partner = null
			partner = null
		return

	if(!partner)
		var/partner_connect = turn(dir, 90)

		for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,partner_connect))
			if(target.dir & get_dir(src,target))
				partner = target
				partner.partner = src
				break

		if(isnull(partner))	//No partner was found :(
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
		M.dust()
		return

/obj/machinery/power/fusion/plasma/Bumped(atom/A)
	if(istype(A, /mob/living))
		var/tmp/mob/living/M = A
		M.dust()

/obj/machinery/power/fusion/plasma/update_icon()
	return