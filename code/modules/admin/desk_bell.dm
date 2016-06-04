/obj/item/desk_bell
	name = "desk bell"
	desc = "Ring this to try and get someone's attention!"

	icon = 'icons/obj/bells.dmi'
	icon_state = "desk_bell"
	throwforce = 1
	w_class = 2.0
	throw_speed = 4
	throw_range = 5

/obj/item/desk_bell/proc/ring()
	playsound( get_turf( src ), 'sound/items/desk_bell.ogg', 80 )
	flick("desk_bell_ring", src)

/obj/item/desk_bell/attack_hand()
	ring()

/obj/item/desk_bell/MouseDrop(var/mob/living/carbon/human/H as mob)
	if( istype( H ))
		H.put_in_hands( src )

	..()

/obj/item/desk_bell/MouseDrop()		//stops people picking it up
	return
