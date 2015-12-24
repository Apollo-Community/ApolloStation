//Apollo Christmas 2015 stuff

/hook/startup/proc/load_decorations()
	for(var/type in subtypes( /obj/item/weapon/spec_decoration ))
		var/loc_found = 0
		for( var/i = 0; i < 10; i++ )
			var/turf/T = pick(deoration_starts)
			if( i == 9 || !( locate( /obj/item/weapon/spec_decoration ) in T ))
				loc_found = 1
				new type(pick(T))
			if( loc_found )
				break

/obj/item/weapon/spec_decoration
	name = "Christmas Decoration"
	icon = 'icons/apollo/christmas.dmi'
	icon_state = ""
	w_class = 2.0
	desc = "A jolly merry christmas tree decoration! It'd look great on the tree"

/obj/item/weapon/spec_decoration/proc/respawn(mob/user as mob)
	var/loc_found = 0
	for( var/i = 0; i < 10; i++ )
		var/turf/T = pick(decoration_starts)
		if( i == 9 || !( locate( /obj/item/weapon/spec_decoration ) in T ))
			loc_found = 1
			loc = T
		if( loc_found )
			break

/obj/item/weapon/spec_decoration/ex_act()
	respawn()
