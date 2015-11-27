/obj/effect/decal/chemspill
	name = "chemical spill" // Specific reagents should be able to rename the spill. Such as uranium becoming "radioactive waste", or paint becoming "wet paint"
	desc = "someone should probably clean that up." // Should also be able to be set by reagents.
	icon = 'icons/effects/effects.dmi'
	icon_state = "liqhalf" // There are spill effects for liquids and solids. Prefixed by "liq" and "sol" respectively. "liq half" should be used for 120u or higher. "liq full" for 240u.
	unacidable = 1 // We should really redo acid in general so we don't have to do this all the time.
	var/liquid = 1 // Whether this should use the icon for liquid or solid spills.
	var/processing = 0 // Whether this spill has any chemicals in it that need to process occasionally.
	reagents = new/datum/reagents(240)
	var/statenumber = 1 // A randomized number between 1 and 7 used for the spill icon. Prevents tiny changes to volume from resulting in icon changing.

/obj/effect/decal/chemspill/New()
	..()
	reagents.my_atom = src
	statenumber = rand(1,7)


/obj/effect/decal/chemspill/update_icon()
	if(!reagents.total_volume)
		qdel(src)

	if(liquid != 2) // Set liquid to 2 in order to override normal icon stuff.
		if(reagents.total_volume >= 240)
			icon_state = "[liquid?"liq":"sol"]full"
		else if(reagents.total_volume >= 120)
			icon_state = "[liquid?"liq":"sol"]half"
		else
			icon_state = "[liquid?"liq":"sol"][statenumber]"

		var/image/temp = image('icons/effects/effects.dmi', src, "[icon_state]")
		temp.icon += mix_color_from_reagents(reagents.reagent_list)
		temp.icon *= mix_alpha_from_reagents(reagents.reagent_list)/255
		overlays.Cut()
		overlays += temp

/obj/effect/decal/chemspill/process()
	if(processing)
		var/found = 0
		for (var/datum/reagent/R in reagents.reagent_list)
			if(R.processme)
				R.process()
				found = 1
		if(!found)
			processing = 0 // Avoid processing stuff that doesnt need to be processed anymore.
		else
			update_icon() // Assume that the process affected the chemicals, or the volume.
	if(reagents.total_volume > 240)
		spillover()

/obj/effect/decal/chemspill/proc/spillover() // Placeholder for flooding mechanics.
	return

/obj/effect/decal/chemspill/proc/isSolid()
	for(var/datum/reagent/R in reagents.reagent_list)
		if (R.state == 1)
			return 1
	return 0

/*

TODO:

> Port Blood Over
> Port Tracks Over
> Implement Spillover Proc
> Add Chemical Process Controller

*/