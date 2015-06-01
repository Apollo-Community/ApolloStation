/proc/size_percent( var/size = 0, var/max_size = 0 )
	if( !size )	return
	if( !max_size )	return

	return round( 100*( size/max_size ))

/obj/item/weapon/shard/supermatter
	name = "supermatter shard"
	desc = "A shard of supermatter. Incredibly dangerous, though not large enough to go critical."
	force = 10.0
	throwforce = 20.0
	icon_state = "supermattersmall"
	sharp = 1
	edge = 1
	w_class = 2
	flags = CONDUCT
	l_color = "#8A8A00"
	luminosity = 2
	var/size = 1
	var/max_size = 100

/obj/item/weapon/shard/supermatter/New()
	..()

	size += rand(0, 10)

	update_icon()

/obj/item/weapon/shard/supermatter/update_icon()
	if( src.size <= 34 )
		icon_state = "supermattersmall"
		src.pixel_x = rand(-12, 12)
		src.pixel_y = rand(-12, 12)
	else if( src.size <= 67 )
		icon_state = "supermattermedium"
		src.pixel_x = rand(-8, 8)
		src.pixel_y = rand(-8, 8)
	else
		icon_state = "supermatterlarge"
		src.pixel_x = rand(-5, 5)
		src.pixel_y = rand(-5, 5)

/obj/item/weapon/shard/supermatter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype( W, /obj/item/weapon/tongs ))
		var/obj/item/weapon/tongs/T = W
		T.pick_up( src )
		T.update_icon()
		return
	else if( istype( W, /obj/item/weapon ))
		if( W.force >= 5 )
			src.shatter()
	..()

/obj/item/weapon/shard/supermatter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/shard/supermatter/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		M << "\red <B>You step on \the [src]!</B>"
		playsound(src.loc, 'sound/effects/glass_step_sm.ogg', 70, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.flags & IS_SYNTHETIC || (H.species.siemens_coefficient<0.5)) //Thick skin.
				return

			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting.status & ORGAN_ROBOT)
					return
				if(affecting.take_damage(5, 20))
					H.UpdateDamageIcon()
				H.updatehealth()
				if(!(H.species && (H.species.flags & NO_PAIN)))
					H.Weaken(3)
	..()


/obj/item/weapon/shard/supermatter/attack_hand(var/mob/user)
	if( !isnucleation( user ))
		user << pick( "\red You think twice before touching that without protection.",
					  "\red You don't want to touch that without some protection.",
					  "\red You probably should get something else to pick that up.",
					  "\red You aren't sure that's a good idea.",
					  "\red You aren't in the mood to get vaporized today.",
					  "\red You really don't feel like frying your hand off.",
					  "\red You assume that's a bad idea." )
		return

	..()

/obj/item/weapon/shard/supermatter/proc/feed( var/datum/gas_mixture/gas )
	size += gas.gas["phoron"]

	if( size > max_size )
		size = max_size

	del( gas )

	update_icon()

/obj/item/weapon/shard/supermatter/proc/shatter()
	if( size >= 10 )
		src.visible_message( "The supermatter shard shatters into smaller fragments!" )
		for( size, size >= 10, size -= 10 )
			new /obj/item/weapon/shard/supermatter( get_turf( src ))
	else
		src.visible_message( "The supermatter shard shatters into dust!" )

	playsound(loc, 'sound/effects/Glassbr2.ogg', 100, 1)
	del( src )

/obj/item/weapon/tongs
	name = "tongs"
	desc = "Tungsten-alloy tongs used for handling dangerous materials."
	force = 7.0
	throwforce = 12.0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "tongs"
	edge = 1
	w_class = 2
	flags = CONDUCT
	var/obj/item/held = null // The item currently being held

/obj/item/weapon/tongs/proc/pick_up( var/obj/item/I )
	held = I
	I.loc = src
	playsound(loc, 'sound/effects/tong_pickup.ogg', 50, 1, -1)

/obj/item/weapon/tongs/attack_self(var/mob/user as mob)
	if( held )
		var/turf/T = get_turf(user.loc)
		held.loc = T
		held = null
		icon_state = initial(icon_state)
	..()

/obj/item/weapon/tongs/update_icon()
	if( !held )
		icon_state = initial( icon_state )
	else if( istype( held, /obj/item/weapon/shard/supermatter ))
		icon_state = "tongs_supermatter"
