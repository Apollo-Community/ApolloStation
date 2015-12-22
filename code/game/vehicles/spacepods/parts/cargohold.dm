
/obj/item/device/spacepod_equipment/misc/cargo
	name = "cargohold"
	icon_state = "cargohold"
	desc = "Used to securely store crates and other such items inside of a spacepod."
	var/max_size = 5

/obj/item/device/spacepod_equipment/misc/cargo/proc/put_inside(var/obj/O, var/mob/user = usr)
	if( !O ) return 0
	if( src.contents.len >= max_size )
		user << "\red The [my_atom]\'s cargohold is full!"
		return 0
	if( O.anchored && !istype( O, /obj/mecha ))
		user << "\red You can't move that!"
		return 0
	if ( istype( O, /obj/item/weapon/grab ))
		return 0

	user.drop_item()
	if( O.loc != src )
		if( istype( O, /obj/mecha ))
			var/obj/mecha/M = O
			M.go_out()
		O.loc = src
		my_atom.visible_message( "[user] loads the [O] into [my_atom]\'s cargohold." )

	return 1

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_prompt( var/mob/user = usr )
	if( !src.contents.len )
		user << "\red There's nothing to dump!"
		return 0

	var/list/answers = list( "All" )
	for( var/obj/O in src )
		answers.Add( O )

	var/response = input( user, "What cargo do you want to dump?", "Dump Cargo", null ) in answers

	if( response == "All" )
		dump_all()
	else
		if( istype( response, /obj ))
			dump_item( response )
		else
			user << "\red Not a valid object for dumping!"
			return 0

	return 1

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_all()
	for( var/obj/O in src )
		dump_item( O )

/obj/item/device/spacepod_equipment/misc/cargo/proc/dump_item( var/obj/O )
	O.loc = get_step( my_atom.loc, turn( my_atom.dir, 180 )) // putting the items behind the spacepod

/obj/item/device/spacepod_equipment/misc/cargo/deassign()
	..()

	dump_all()