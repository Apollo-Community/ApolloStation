/datum/wires/breakerbox

	holder_type = /obj/machinery/power/breakerbox
	wire_count = 3

var/const/BREAKER_DISABLE_WIRE = 2

/datum/wires/breakerbox/GetInteractWindow()
	var/obj/machinery/power/breakerbox/A = holder
	. += ..()
	. += "<BR>The red light is [A.disabled ? "off" : "on"]."

/datum/wires/breakerbox/CanUse()
	var/obj/machinery/power/breakerbox/A = holder
	if(A.panel_open)
		return 1
	return 0


/datum/wires/breakerbox/UpdateCut(index, mended)
	var/obj/machinery/power/breakerbox/A = holder
	switch(index)
		if(BREAKER_DISABLE_WIRE)
			A.disabled = !mended

/datum/wires/breakerbox/UpdatePulsed(index)
	if(IsIndexCut(index))
		return
	var/obj/machinery/power/breakerbox/A = holder
	switch(index)
		if(BREAKER_DISABLE_WIRE)
			A.auto_toggle()