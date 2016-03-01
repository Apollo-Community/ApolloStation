// This is an object that's used to convey information about the template
// It'll be deleted directly after it's made

/obj/templateinfo
	name = "template info"
	icon = 'icons/turf/areas.dmi'
	icon_state = "template_info"

	var/area_name = "Template Area" // The area name for the template
	var/requires_power = 1 // Whether or not the template's area requires power
	var/area_environment = 2 // see areas.dm

/obj/templateinfo/New()
	// failsafe
	spawn(100)
		if(src)	qdel(src)
	..()