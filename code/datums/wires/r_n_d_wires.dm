/datum/wires/r_n_d

	holder_type = /obj/machinery/r_n_d
	wire_count = 6

	var/const/HACK_WIRE = 1
	var/const/SHOCK_WIRE = 2
	var/const/DISABLE_WIRE = 4
	var/const/SABOTAGE_WIRE = 8

/datum/wires/r_n_d/GetInteractWindow()
	var/obj/machinery/r_n_d/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."
	. += "<BR>The green light is [A.shocked ? "off" : "on"]."
	. += "<BR>The blue light is [A.hacked ? "off" : "on"]."
	. += "<BR>The warning light is [A.sabotaged ? "blinking" : "off"]."

/datum/wires/r_n_d/CanUse()
	var/obj/machinery/r_n_d/A = holder
	if(A.panel_open)
		return 1
	return 0

/datum/wires/r_n_d/UpdateCut(index, mended)
	var/obj/machinery/r_n_d/A = holder
	switch(index)
		if(HACK_WIRE)
			A.hacked = !mended
		if(SHOCK_WIRE)
			A.disabled = !mended
			A.shock(user,50)
		if(DISABLE_WIRE)
			A.shocked = !mended
			A.shock(user,50)
		if(SABOTAGE_WIRE)
			A.sabotaged = !mended
			A.shock(user,50)

/datum/wires/r_n_d/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/r_n_d/A = holder
	switch(index)
		if(HACK_WIRE)
			A.hacked = !A.hacked
			spawn(100) A.hacked = !A.hacked
		if(SHOCK_WIRE)
			A.disabled = !A.disabled
			A.shock(user,50)
			spawn(100) A.disabled = !A.disabled
		if(DISABLE_WIRE)
			A.shocked = !A.shocked
			A.shock(user,50)
			spawn(100) A.shocked = !A.shocked