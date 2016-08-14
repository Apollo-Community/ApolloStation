//The fusion Tokamak <by rjtwins>
//SPARKS YESH
/obj/machinery/power/fusion/proc/spark()
	// Light up some sparks
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up( 3, 1, src )
	s.start()

/obj/machinery/power/fusion/attackby()

//What gets hit by the beam and heats up the plasma
//More like a heat rod then a core :P
/obj/machinery/power/fusion/core
	var/power = 0
	var/heat = 0
	var/health = 1000

//Temperature and power decay of the core
/obj/machinery/power/fusion/core/proc/decay()
	//Do something with the alloy compo here
	var/decay =
	power = max(0, power-decay)

//Hitting the core with anything, this includes power and damage calculations from the emitter.
/obj/machinery/power/fusion/core/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam/continuous/emitter))
		var/obj/item/projectile/beam/continuous/emitter/B = Proj
		//Needs math !
		power += B.power
	else
		damage += Proj.damage
	return 0

/obj/machinery/power/fusion/core/proc/power2heat()
	//This needs math and tweaking !
	var/heatdif = men(power * 0.15, 25)
	heat += heatdif
	power -= 2*heatdif

//Four core corners (magnatic rings)
/obj/machinery/power/fusion/ring
	var/battery = 0
	var/mode = 0
	var/nLevel = 0
	var/max_nLevel = 1000

//Transfer energy in direct neutron mode
/obj/machinery/power/fusion/ring/proc/transfer_energy()
	if(mode)

		for(var/obj/machinery/power/rad_collector/R in rad_collectors)
			var/distance = get_dist(R, src)
			if(distance && distance <= 10)		//sanity for 1/0
				//stop their being a massive benifit to moving the rad collectors closer
				if(distance < 3)	distance = 2.67			// between 25 - 50k benifit 	(level 1)
				//for collectors using standard phoron tanks at 1013 kPa, the actual power generated will be this power*0.3*20*29 = power*174
				R.receive_pulse(nLevel*(0.7/distance)/4)
	return

//Return a string with data from the ring obj
/obj/machinery/power/fusion/ring/proc/status()
	return "Capacitor Reserve: [power] <br> Mode: [src.mode=1 ? "Direct" : "Indirect"] <br> Neutron Level: [nLevel]"

/obj/machinery/power/fusion/ring/nw

/obj/machinery/power/fusion/ring/se

/obj/machinery/power/fusion/ring/sw

/obj/machinery/power/fusion/ring/nw

/obj/machinery/power/fusion/plasma
	dir = 0
	icon = 'icons/effects/beam.dmi'
	icon_state = "plas_stream"