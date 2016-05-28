/datum/wires/shieldgen

	holder_type = /obj/machinery/shieldgen
	wire_count = 3

	var/const/SABOTAGE_WIRE = 1
	var/const/TOGGLE_WIRE = 2

/datum/wires/shieldgen/GetInteractWindow()
	var/obj/machinery/shield_gen/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/shieldgen/CanUse()
	var/obj/machinery/shieldgen/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/shieldgen/UpdateCut(index, mended)
	var/obj/machinery/shieldgen/A = holder
	switch(index)
		if(SABOTAGE_WIRE)
			A.disabled = !mended

/datum/wires/shieldgen/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/shieldgen/A = holder
	switch(index)
		if(TOGGLE_WIRE)
			if(A.active)
				A.shields_down()
			else
				A.shields_up()