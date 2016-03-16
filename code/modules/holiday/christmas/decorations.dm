//Apollo Christmas 2015 stuff
/hook/startup/proc/load_decorations()
	for(var/type in subtypes( /obj/item/weapon/spec_decoration ))
		var/loc_found = 0
		for( var/i = 0; i < 10; i++ )
			var/list/starts = list()
			starts += blobstart
			starts += xeno_spawn
			var/turf/T = pick( starts )
			if( i == 9 || !( locate( /obj/item/weapon/spec_decoration ) in T ))
				loc_found = 1
				new type(pick(T))
			if( loc_found )
				break

/obj/item/weapon/spec_decoration
	name = "bauble"
	icon = 'icons/obj/christmas.dmi'
	icon_state = ""
	w_class = 1.0
	desc = "A jolly christmas tree decoration! It'd look great on a pine tree!"

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

/obj/item/weapon/spec_decoration/red
	name = "red bauble"
	icon_state = "bauble_red"

/obj/item/weapon/spec_decoration/orange
	name = "orange bauble"
	icon_state = "bauble_orange"

/obj/item/weapon/spec_decoration/yellow
	name = "yellow bauble"
	icon_state = "bauble_yellow"

/obj/item/weapon/spec_decoration/green
	name = "green bauble"
	icon_state = "bauble_green"

/obj/item/weapon/spec_decoration/blue
	name = "blue bauble"
	icon_state = "bauble_blue"

/obj/item/weapon/spec_decoration/purple
	name = "purple bauble"
	icon_state = "bauble_purple"
