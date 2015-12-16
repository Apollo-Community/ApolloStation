/obj/structure/broodswam/large
	name = "broodswarm hive structure"
	desc = "A disgusting strcuture of flesh."
	icon = 'icons/obj/broodswarm_hive.dmi'
	pixel_x = -16


/*----------- HIVE TUMOR ------------*/
/obj/structure/broodswam/large/hive_tumor
	name = "hive tumor"
	desc = "A grotesque lump of flesh, it undulates rhythemically."
	icon_state = "hive_tumor"

	breakable = 0

	var/datum/cell_auto_master/blotch/controller

/obj/structure/broodswam/large/hive_tumor/New()
	controller = new( get_turf( src ))

	..()

/obj/structure/broodswam/large/hive_tumor/ex_act()
	return

/obj/structure/broodswam/large/hive_tumor/attack_hand( mob/user )
	user.do_attack_animation( src )
	return

/obj/structure/broodswam/large/hive_tumor/blob_act()
	return

/obj/structure/broodswam/large/hive_tumor/attack_tk()
	return

/obj/structure/broodswam/large/hive_tumor/attack_generic()
	return

/obj/structure/broodswam/large/hive_tumor/attackby()
	return


/*----------- HIVE PIT ------------*/
/obj/structure/broodswam/large/hive_pit
	icon_state = "hive_pit"
	anchored = 1
	density = 1
	opacity = 0

	name = "pit"
	desc = "A dark, ominous pit which appears to be breathing. Whatever it is that lies at the bottom, you hope you never know."


