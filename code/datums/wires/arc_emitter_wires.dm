/datum/wires/arc_emitter

	holder_type = /obj/machinery/power/arc_emitter
	wire_count = 3

	var/const/SABOTAGE_WIRE = 1
	var/const/TOGGLE_WIRE = 2

/datum/wires/arc_emitter/GetInteractWindow()
	var/obj/machinery/power/arc_emitter/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/arc_emitter/CanUse()
	var/obj/machinery/power/arc_emitter/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/arc_emitter/UpdateCut(index, mended)
	var/obj/machinery/power/arc_emitter/A = holder
	switch(index)
		if(SABOTAGE_WIRE)
			A.disabled = !mended

/datum/wires/arc_emitter/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/power/arc_emitter/A = holder
	switch(index)
		if(TOGGLE_WIRE)
			A.activate(user)