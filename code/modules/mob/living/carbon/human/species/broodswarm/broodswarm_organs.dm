//XENOMORPH ORGANS
/datum/organ/internal/broodswarm
	name = "flesh"
	parent_organ = "groin"
	removed_type = /obj/item/organ/broodswarm

/obj/item/organ/broodswarm
	name = "broodswarm organ"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hive_tumor"
	desc = "A repulsive undulating blob of flesh."

/datum/organ/internal/broodswarm/hive_tumor
	name = "hive tumor"
	parent_organ = "groin"
	removed_type = /obj/item/organ/broodswarm/hive_tumor

/obj/item/organ/broodswarm/hive_tumor
	name = "hive tumor"
	desc = "A grotesque lump of flesh, it undulates rhythemically."

/obj/item/organ/broodswarm/hive_tumor/process()
	if( istype( loc, /turf ))
		grow()

/obj/item/organ/broodswarm/hive_tumor/proc/grow()
	new /obj/structure/broodswam/large/hive_tumor( get_turf( src ))

	src.visible_message("<span class='warning'>The hive tumor embeds itself into the floor, oozing a terrible mess!</span>")

	qdel( src )
