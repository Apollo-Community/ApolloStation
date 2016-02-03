/obj/item/inflatable/spacesuit
	name = "inflatable spacesuit"
	desc = "A single-use spacesuit made for emergencies. The instructions read, \"Put the inflatable pack on your back, and pull the cord to inflate. Quality not guaranteed.\""
	icon = 'icons/obj/items.dmi'
	icon_state = "inflate_space_init"
	w_class = 2.0

	slot_flags = SLOT_BACK

	var/equip_delay = 20
	var/mob/living/carbon/human/wearer // The person currently wearing the rig.

/obj/item/inflatable/spacesuit/attack_self(mob/user)
	return

/obj/item/inflatable/spacesuit/equipped(mob/living/carbon/human/M)
	..()

	if(istype(M) && M.back == src)
		M.visible_message("<span class='notice'>[M] starts putting on \the [src]...</span>", "<span class='notice'>You start putting on \the [src]...</span>")

		if(!do_after(M, equip_delay))
			if(M && M.back == src)
				M.back = null
				M.drop_from_inventory(src)
			src.loc = get_turf(src)
			return

	if(istype(M) && M.back == src)
		M.visible_message("<span class='notice'><b>[M] struggles into \the [src].</b></span>", "<span class='notice'>You struggle into \the [src]. Make sure to remove any headgear and suits before deploying.</span>")
		wearer = M
		update_icon()

/obj/item/inflatable/spacesuit/verb/inflate()
	set name = "Inflate"
	set category = "Object"
	set src in usr

	var/mob/M = usr

	if( !M )
		return

	if( wearer != M )
		M << "<span class='notice'>You need to put this on your back first!</span>"
		return

	if( !istype( M, /mob/living/carbon/human ))
		M << "<span class='notice'>Your species cannot use this!</span>"
		return

	var/mob/living/carbon/human/H = M
	src.add_fingerprint( M )
	playsound(loc, 'sound/items/zip.ogg', 75, 1)

	if( H.head )
		M << "<span class='alert'>You pull the inflation cord, but the suit failed to deploy as \the [H.head] was in the way!</span>"
		pop(M)
		return
	else if( H.wear_suit )
		M << "<span class='alert'>You pull the inflation cord, but the suit failed to deploy as \the [H.wear_suit] was in the way!</span>"
		pop(M)
		return
	else
		M << "<span class='notice'>You pull the inflation cord and the inflatable suit expands rapidly around your body, forming an airtight seal!</span>"
		//TODO: Species check, skull damage for forcing an unfitting helmet on?

		var/obj/item/clothing/head/helmet/space/inflatable/helmet = new( H )
		H.equip_to_slot( helmet, slot_head )
		src.transfer_fingerprints_to( helmet )

		var/obj/item/clothing/suit/space/inflatable/suit = new( H )
		H.equip_to_slot( suit, slot_wear_suit )
		src.transfer_fingerprints_to( suit )

	qdel( src )

/obj/item/inflatable/spacesuit/proc/pop( mob/M )
	M.visible_message("<span class='alert'>[M] pulls the cord on \the [src], but it fails to deploy and pops!</span>", "<span class='alert'>Your inflatable suit pops!</span>")
	playsound(loc, 'sound/effects/snap.ogg', 75, 1)
	qdel( src )

/obj/item/clothing/head/helmet/space/inflatable
	name = "inflatable spacesuit helmet"
	icon_state = "inflatable_space"
	item_state = "inflatable_space"
	desc = "An inflatable spacesuit helmet. Its visor appears to be made of plastic wrap."
	var/removed = 0

/obj/item/clothing/head/helmet/space/inflatable/dropped(mob/M as mob)
	if( !removed )
		playsound(loc, 'sound/effects/snap.ogg', 75, 1)
		M << "<span class='alert'>You pop your inflatable suit!</span>"
		removed = 1

	var/mob/living/carbon/human/H = M

	if( !istype( H ))
		return

	if( H.wear_suit )
		if( istype( H.wear_suit, /obj/item/clothing/suit/space/inflatable ))
			var/obj/item/clothing/suit/space/inflatable/I = H.head
			I.removed = 1
			qdel( H.wear_suit )

	spawn(0)
		H.u_equip( src )
		qdel( src )
		H.update_icons()

/obj/item/clothing/suit/var/bouncy = 0

/obj/item/clothing/suit/space/inflatable
	name = "inflatable spacesuit"
	icon_state = "inflatable_space"
	item_state = "inflatable_space"
	desc = "An inflatable spacesuit. It looks rediculous."
	resilience = 2
	breach_threshold = 1
	bouncy = 1
	var/removed = 0

/obj/item/clothing/suit/space/inflatable/dropped(mob/M as mob)
	if( !removed )
		playsound(loc, 'sound/effects/snap.ogg', 75, 1)
		M << "<span class='alert'>You pop your inflatable suit!</span>"
		removed = 1

	var/mob/living/carbon/human/H = M

	if( !istype( H ))
		return

	if( H.head )
		if( istype( H.head, /obj/item/clothing/head/helmet/space/inflatable ))
			var/obj/item/clothing/head/helmet/space/inflatable/I = H.head
			I.removed = 1
			H.u_equip( I )
			qdel( I )

	spawn(0)
		H.u_equip( src )
		qdel( src )
		H.update_icons()
