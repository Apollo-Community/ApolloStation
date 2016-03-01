/obj/item/inflatable/spacesuit
	name = "inflatable spacesuit"
	desc = "A single-use spacesuit made for emergencies. The instructions read, \"Put the inflatable pack on your back, and pull the cord to inflate.\""
	icon = 'icons/obj/items.dmi'
	icon_state = "inflatable_space"
	item_state = "inflatable_space"
	w_class = 2.0

	slot_flags = SLOT_BACK

	var/equip_delay = 20
	var/mob/living/carbon/human/wearer // The person currently wearing the rig.
	var/success_chance = 100 // how likely is it that the suit will successfully open?

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

	if( H.head )
		M.visible_message("<span class='alert'>[M] pulls the cord on \the [src], but it fails to deploy and pops!</span>", "<span class='alert'>You pull the inflation cord, but \the [src] fails to deploy as \the [H.head] was in the way!</span>")
		pop( M )
		return
	else if( H.wear_suit )
		M.visible_message("<span class='alert'>[M] pulls the cord on \the [src], but it fails to deploy and pops!</span>", "<span class='alert'>You pull the inflation cord, but \the [src] fails to deploy as \the [H.wear_suit] was in the way!</span>")
		pop( M )
		return
	else if( prob( success_chance ))
		playsound(loc, 'sound/items/zip.ogg', 75, 1)
		M.visible_message("<span class='alert'>[M] pulls the cord on \the [src] and it rapidly expands around their body!!</span>", "<span class='notice'>You pull the inflation cord and \the [src] expands rapidly around your body, forming an airtight seal!</span>" )

		var/obj/item/clothing/head/helmet/space/inflatable/helmet = new( H )
		H.equip_to_slot( helmet, slot_head )
		src.transfer_fingerprints_to( helmet )
		helmet.canremove = 0

		var/obj/item/clothing/suit/space/inflatable/suit = new( H )
		H.equip_to_slot( suit, slot_wear_suit )
		src.transfer_fingerprints_to( suit )
		qdel( src )
	else
		M.visible_message("<span class='alert'>[M] pulls the cord on \the [src], but it fails to deploy and pops!</span>", "<span class='alert'>You pull the inflation cord, but \the [src] fails to deploy and pops!</span>")
		pop( M )

/obj/item/inflatable/spacesuit/proc/pop()
	playsound(loc, 'sound/effects/snap.ogg', 75, 1)
	qdel( src )

/obj/item/inflatable/spacesuit/budget
	name = "budget inflatable spacesuit"
	desc = "A single-use spacesuit made for emergencies. The instructions read, \"Put the inflatable pack on your back, and pull the cord to inflate. Quality not gauranteed.\""
	success_chance = 40 // how likely is it that the suit will successfully open?

/obj/item/clothing/head/helmet/space/inflatable
	name = "inflatable spacesuit helmet"
	icon_state = "inflatable_space"
	item_state = "inflatable_space"
	desc = "An inflatable spacesuit helmet. Its visor appears to be made of plastic wrap."

/obj/item/clothing/suit/var/bouncy = 0

/obj/item/clothing/suit/space/inflatable
	name = "inflatable spacesuit"
	icon_state = "inflatable_space"
	item_state = "inflatable_space"
	desc = "An inflatable spacesuit. It looks rediculous."
	resilience = 5
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
			H.u_equip( I )
			qdel( I )

	spawn(0)
		H.u_equip( src )
		qdel( src )
		H.update_icons()
