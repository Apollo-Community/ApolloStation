/obj/structure/drum
	name = "metal drum"
	desc = "a large metal drum used for storing liquids."
	icon = 'icons/obj/storage_col.dmi'
	icon_state = "drum"
	density = 1

	var/volume = 2000
	var/datum/chemicals/chemicals
	var/drum_color = "#FF3333" // The base color of the drum
	var/decal = 1 // Whether the drum has a decal.
	var/decal_color = "#333333" // The color of the decal. Only applicable if the drum has a decal.


/obj/structure/drum/New()
	..()
	if(volume)
		desc += "It can hold [volume] units."
	chemicals = new(src, volume)
	update_icon()

/obj/structure/drum/Destroy()
	qdel(chemicals)
	..()

/obj/structure/drum/access_chems()
	return chemicals

/obj/structure/drum/update_icon()
	var/icon/I = new('icons/obj/storage_col.dmi', "drum")
	I.Blend(drum_color, ICON_MULTIPLY)
	if(decal)
		var/icon/stripe = new('icons/obj/storage_col.dmi', "drum_decal_[decal]")
		stripe.Blend(decal_color, ICON_MULTIPLY)
		I.Blend(stripe, ICON_OVERLAY)
	var/icon/lid = new('icons/obj/storage_col.dmi', "drum_top")
	var/icon/high = new('icons/obj/storage_col.dmi', "drum_highlight")
	I.Blend(high, ICON_ADD)
	I.Blend(lid, ICON_OVERLAY)
	icon = I

/obj/structure/drum/proc/fillup(list/chems)
	return