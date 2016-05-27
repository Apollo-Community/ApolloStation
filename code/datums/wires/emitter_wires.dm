/datum/wires/emitter

	holder_type = /obj/machinery/power/emitter
	wire_count = 3

	var/const/SABOTAGE_WIRE = 1
	var/const/TOGGLE_WIRE = 2

/datum/wires/emitter/GetInteractWindow()
	var/obj/machinery/power/emitter/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/emitter/CanUse()
	var/obj/machinery/power/emitter/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/emitter/UpdateCut(index, mended)
	var/obj/machinery/power/emitter/A = holder
	switch(index)
		if(SABOTAGE_WIRE)
			A.disabled = !mended

/datum/wires/emitter/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/power/emitter/A = holder
	switch(index)
		if(TOGGLE_WIRE)
			A.activate(user)