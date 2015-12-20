/obj/item/broodswarm/placeable
	var/spawn_type // What kind of structure is created when this is placed?
	var/uses = 1
	var/max_uses = 1
	icon = 'icons/obj/broodswarm.dmi'
	icon_state = "hive_tumor"

/obj/item/broodswarm/placeable/New()
	uses = max_uses
	..()

/obj/item/broodswarm/placeable/hive_pit/attack_self(mob/living/user as mob)
	var/turf/T = get_turf( src )
	if( T.containsCell( /atom/movable/cell/blotch ))
		user << "<span class='notice'>You place the [src] on the blotch, causing it to take root.</span>"
		create()
	else
		user << "<span class='warning'>The [src] must be placed on the blotch.</span>"

/obj/item/broodswarm/placeable/proc/create(mob/living/user as mob)
	new spawn_type( get_turf( src ))

	uses--
	if( uses <= 0 )
		qdel( src )

/obj/item/broodswarm/placeable/hive_pit
	name = "Hive pit core"
	desc = "Plant this on the blotch in order to grow a hive pit."
	spawn_type = /obj/machinery/broodswam/large/hive_pit

