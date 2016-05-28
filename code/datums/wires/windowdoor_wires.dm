/datum/wires/windowdoor

	holder_type = /obj/machinery/door/window
	wire_count = 6

	var/const/SHOCK_WIRE = 1
	var/const/POWER_WIRE = 2
	var/const/OPEN_WIRE = 4
	var/const/CLOSE_WIRE = 8

/datum/wires/windowdoor/GetInteractWindow()
	var/obj/machinery/door/window/A = holder
	. += ..()
	. += "<BR>The red light is [A.power ? "off" : "on"]."
	. += "<BR>The warning light is [A.shocked ? "blinking" : "off"]."

/datum/wires/windowdoor/CanUse()
	var/obj/machinery/door/window/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/windowdoor/UpdateCut(index, mended)
	var/obj/machinery/door/window/A = holder
	switch(index)
		if(SHOCK_WIRE)
			A.shocked = !mended
			A.shock(user,50)
		if(POWER_WIRE)
			A.power = !mended
			A.shock(user,50)

/datum/wires/windowdoor/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/door/window/A = holder
	switch(index)
		if(SHOCK_WIRE)
			A.shocked = !A.shocked
			spawn(100) A.shocked = !A.shocked
		if(POWER_WIRE)
			A.power = !A.power
			spawn(100) A.power = !A.power
		if(OPEN_WIRE)
			A.open()
		if(CLOSE_WIRE)
			A.close()