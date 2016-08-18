/obj/machinery/power/fusion/plasma
	dir = 0
	icon = 'icons/obj/fusion.dmi'
	icon_state = "plas_cool"
	density = 0
	var/transfering = 0
	var/datum/gas_mixture/air_contents = null
	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/network = null

//When a fusion event happens neurons are generated that can be collected by radiation collectos.
/obj/machinery/power/fusion/plasma/proc/transfer_energy(var/neurons = 0)
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		var/distance = get_dist(R, src)
		if(distance && distance <= 10)		//sanity for 1/0
			//stop their being a massive benifit to moving the rad collectors closer
			if(distance < 3)	distance = 2.67			// between 25 - 50k benifit 	(level 1)
			//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
			//The closer the better radiation intensity is inversely to space traveled.
			R.receive_pulse(neurons/(distance**2))
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