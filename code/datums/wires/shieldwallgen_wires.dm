/datum/wires/shieldwallgen

	holder_type = /obj/machinery/shieldwallgen
	wire_count = 3

	var/const/SABOTAGE_WIRE = 1
	var/const/TOGGLE_WIRE = 2

/datum/wires/shieldwallgen/GetInteractWindow()
	var/obj/machinery/shieldwallgen/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/shieldwallgen/CanUse()
	var/obj/machinery/shieldwallgen/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/shieldwallgen/UpdateCut(index, mended)
	var/obj/machinery/shieldwallgen/A = holder
	switch(index)
		if(SABOTAGE_WIRE)
			A.disabled = !mended

/datum/wires/shieldwallgen/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/shieldwallgen/A = holder
	switch(index)
		if(TOGGLE_WIRE)
			A.switch_state()