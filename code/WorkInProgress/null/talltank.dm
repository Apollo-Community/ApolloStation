/obj/structure/talltank
	name = "storage tank"
	desc = "a large vessel for storing fluids and gasses."
	icon = 'icons/obj/talltank.dmi'
	icon_state = "tank"

	density = 1
	anchored = 1
	dir = SOUTH

	var/volume = 25000
	var/datum/chemicals/chemicals
	var/tank_color = "#FF3333" // The base color of the drum
	var/striped = TRUE // Whether the drum is striped.
	var/stripe_color = "#333333" // The color of the stripe. Only applicable if the drum is striped.

	var/list/conduit_nodes = list("south" = "smallpipe")

/obj/structure/talltank/New()
	..()
	if(volume)
		desc += "It can hold [volume] units."
	chemicals = new(src, volume)
	update_icon()

/obj/structure/talltank/Destroy()
	qdel(chemicals)
	..()

/obj/structure/talltank/access_chems()
	return chemicals

/obj/structure/talltank/update_icon()
	var/icon/I = new('icons/obj/talltank.dmi', "tank", dir)
	var/icon/top = new('icons/obj/talltank.dmi', "tank_top")
	top.Blend(tank_color, ICON_MULTIPLY)
	if(striped)
		var/icon/stripe = new('icons/obj/talltank.dmi', "tank_stripe")
		stripe.Blend(stripe_color, ICON_MULTIPLY)
		top.Blend(stripe, ICON_OVERLAY)
	var/icon/high = new('icons/obj/talltank.dmi', "tank_highlight")
	top.Blend(high, ICON_ADD)
	I.Blend(top, ICON_OVERLAY)
	icon = I

/obj/structure/talltank/proc/fillup(list/chems)
	return

/obj/structure/talltank/proc/update_nodes()
	switch(dir)
		if(SOUTH)
			conduit_nodes = list("south" = "smallpipe")
		if(NORTH)
			conduit_nodes = list("north" = "smallpipe")
		if(EAST)
			conduit_nodes = list("east" = "smallpipe")
		if(WEST)
			conduit_nodes = list("west" = "smallpipe")
	..()