//The fusion "core" heating rod
//What gets hit by the beam and heats up the plasma
/obj/machinery/power/fusion/core
	name = "Heat Distrubtion Device"
	desc = "Converts incoming energy into heat and distributes it."
	icon = 'icons/obj/fusion.dmi'
	icon_state = "core_off"
	var/heat = 0
	var/controller
	var/beam_coef = 2
	ready = 1
	var/last_power = 0
	wired = 1
	panel_open = 0

/obj/machinery/power/fusion/core/status()
	return "Buildupheat: [heat] <br> Integrity: [(1000-damage)/10] % <br> Producing [last_power] Kw"

//Temperature and power decay of the core
/obj/machinery/power/fusion/core/proc/decay()
	//Do something with the alloy compo here
	heat = max(0, heat-((0.0005*heat)**2))

//Hitting the core with anything, this includes power and damage calculations from the emitter.
/obj/machinery/power/fusion/core/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam/continuous/emitter))
		var/obj/item/projectile/beam/continuous/emitter/B = Proj
		heat += B.power*beam_coef
	else
		damage += Proj.damage
	return 0

//Override to make sure the icon does not dissapear
/obj/machinery/power/fusion/core/update_icon()
	if(last_power > 1 || heat > 1)
		icon_state = "core_on"
	else
		icon_state = "core_off"
	return

/obj/machinery/power/fusion/core/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		src.tag = input(user,"Input Device tag","Input Tag",null) as text|null
	..()

/obj/machinery/power/fusion/core/process()
	update_icon()
	decay()

/obj/machinery/power/fusion/core/proc/receive_neutrons(var/neutrons)
	var/power = 750*neutrons
	add_avail(power)
	last_power = power
	return