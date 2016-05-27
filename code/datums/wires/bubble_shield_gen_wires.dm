/datum/wires/shield_gen

	holder_type = /obj/machinery/shield_gen
	wire_count = 6

	var/const/SABOTAGE_WIRE = 1
	var/const/TOGGLE_WIRE = 2
	var/const/RANGE_UP = 4
	var/const/RANGE_DOWN = 8

/datum/wires/shield_gen/GetInteractWindow()
	var/obj/machinery/shield_gen/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/shield_gen/CanUse()
	var/obj/machinery/shield_gen/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/shield_gen/UpdateCut(index, mended)
	var/obj/machinery/shield_gen/A = holder
	switch(index)
		if(SABOTAGE_WIRE)
			A.disabled = !mended

/datum/wires/shield_gen/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/shield_gen/A = holder
	switch(index)
		if(TOGGLE_WIRE)
			A.toggle()
		if(RANGE_UP)
			A.field_radius += 10
		if(RANGE_DOWN)
			A.field_radius -= 10