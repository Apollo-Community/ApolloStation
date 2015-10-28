//Apollo Halloween 2015 stuff

#define MAX_PUMPKINS 6
#define HALLOWEEN_OBJ "/obj/item/weapon/flame/lighter/zippo/pumpkin"

/hook/startup/proc/load_eggs()
	for(var/type in subtypes( /obj/item/weapon/spec_pumpkin ))
		new type(pick(pumpkin_starts))

/obj/item/weapon/spec_pumpkin
	name = "jack-o-lantern"
	icon = 'icons/apollo/halloween.dmi'
	icon_state = ""
	w_class = 2.0
	desc = "A scary jack-o-lantern! Maybe there's something inside..."
	var/mobs_opened = list()

/obj/item/weapon/spec_pumpkin/attack_self(mob/user as mob)
	open( user )

/obj/item/weapon/spec_pumpkin/verb/open(mob/user as mob)
	set name = "Open Jack-O-Lantern"
	set category = "Object"
	set src in oview(1)

	if( locate( user ) in mobs_opened )
		var/difference = MAX_PUMPKINS-user.pumpkins_found
		if( difference ) // If they haven't already found all of them
			user << "You've already found this one, go look for the remaining [difference] jack-o-lanterns!"
		else
			user << "You've already found all of the jack-o-lanterns!"
		return

	mobs_opened += user
	user.pumpkins_found++

	if(( user.pumpkins_found >= MAX_PUMPKINS ))
		if( log_acc_item_to_db( user.ckey, HALLOWEEN_OBJ ))
			user << "Congratulations! You've collected all of the pumpkins! A special halloween item has been added to your account as a reward."
		else
			user << "You've already recieved the item for this holiday event, come back in a few months for the next one!"
			return
	else
		var/difference = MAX_PUMPKINS-user.pumpkins_found
		if( difference ) // If they haven't already found all of them
			user << "Found a pumpkin! Go find the remaining [difference] jack-o-lanterns!"

	respawn( user )

/obj/item/weapon/spec_pumpkin/proc/respawn(mob/user as mob)
	if( user )
		user.drop_item(src)
	loc = pick(pumpkin_starts)

/obj/item/weapon/spec_pumpkin/ex_act()
	respawn()

/obj/item/weapon/spec_pumpkin/jmmj
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "JMMJ"

/obj/item/weapon/spec_pumpkin/kwask
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "Kwask"

/obj/item/weapon/spec_pumpkin/stuicey
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "stuicey"

/obj/item/weapon/spec_pumpkin/dancer
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "dancer"

/obj/item/weapon/spec_pumpkin/king_nexus
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "King_Nexus"

/obj/item/weapon/spec_pumpkin/kodos
	icon = 'icons/apollo/halloween.dmi'
	icon_state = "Kodos"
