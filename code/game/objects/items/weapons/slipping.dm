/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeelgreen
	name = "green banana peel"
	desc = "A peel from a gooey, green banana. Looks disgusting."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel-green"
	item_state = "banana_peel-green"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living))
		var/mob/living/M = AM
		M.slip("the [src.name]",4)
/*
 * Soap
 */
/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/Crossed(AM as mob|obj) //EXACTLY the same as bananapeel for now, so it makes sense to put it in the same dm -- Urist
	if (istype(AM, /mob/living))
		var/mob/living/M =	AM
		M.slip("the [src.name]",3)

/obj/item/weapon/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		user << "<span class='notice'>You need to take that [target.name] off before cleaning it.</span>"
	else if(istype(target,/obj/effect/decal/cleanable))
		user << "<span class='notice'>You scrub \the [target.name] out.</span>"
		qdel(target)
	else
		user << "<span class='notice'>You clean \the [target.name].</span>"
		target.clean_blood()
	return

/obj/item/weapon/soap/attack(mob/target as mob, mob/user as mob)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_sel &&user.zone_sel.selecting == "mouth" )
		user.visible_message("<span class='alert'>\the [user] washes \the [target]'s mouth out with soap!</span>")
		return
	..()

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/deluxe/New()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"