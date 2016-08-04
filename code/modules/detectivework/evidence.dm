//CONTAINS: Evidence bags and fingerprint cards

/obj/item/weapon/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""
	w_class = 2
	var/obj/item/stored_item = null

/obj/item/weapon/evidencebag/afterattack(obj/item/I, mob/user,proximity)
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/weapon/evidencebag/attackby(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return 1

/obj/item/weapon/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored == 1)
		return

	if(istype(I, /obj/item/weapon/evidencebag))
		user << "<span class='notice'>You find putting an evidence bag in another evidence bag to be slightly absurd.</span>"
		return 1 //now this is podracing

	if(I.w_class > 3)
		user << "<span class='notice'>[I] won't fit in [src].</span>"
		return

	if(contents.len)
		user << "<span class='notice'>[src] already has something inside it.</span>"
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(I.loc,/obj/item/weapon/storage))	//in a container.
			var/obj/item/weapon/storage/U = I.loc
			U.remove_from_storage(I, src)
		else if(user.l_hand == I)					//in a hand
			user.drop_l_hand()
		else if(user.r_hand == I)					//in a hand
			user.drop_r_hand()
		else
			return

	user.visible_message("[user] puts [I] into [src].", "<span class='notice'>You put [I] inside [src].</span>",\
	"<span class='italics'>You hear a rustle as someone puts something into a plastic bag.</span>")

	icon_state = "evidence"

	var/xx = I.pixel_x	//save the offset of the item
	var/yy = I.pixel_y
	I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	I.pixel_x = xx		//and then return it
	I.pixel_y = yy
	add_overlay(img)
	add_overlay("evidence")	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.loc = src
	w_class = I.w_class
	return 1


/obj/item/weapon/evidencebag/attack_self(mob/user as mob)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src]", "You take [I] out of [src].",\
		"You hear someone rustle around in a plastic bag, and remove something.")
		overlays.Cut()	//remove the overlays

		user.put_in_hands(I)
		stored_item = null

		w_class = initial(w_class)
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."
	else
		user << "[src] is empty."
		icon_state = "evidenceobj"
	return

/obj/item/weapon/evidencebag/examine(mob/user)
	..(user)
	if (stored_item) user.examinate(stored_item)

/obj/item/weapon/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."
	New()
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		new /obj/item/weapon/evidencebag(src)
		..()
		return

/obj/item/weapon/f_card
	name = "finger print card"
	desc = "Used to take fingerprints."
	icon = 'icons/obj/card.dmi'
	icon_state = "fingerprint0"
	var/amount = 10.0
	item_state = "paper"
	throwforce = 1
	w_class = 1.0
	throw_speed = 3
	throw_range = 5

/obj/item/weapon/f_card/add_fingerprint(mob/living/M as mob, ignoregloves = 0)
	if(..())
		var/mob/living/carbon/human/H = M
		var/full_print = md5(H.dna.uni_identity)
		fingerprints[full_print] = full_print

/obj/item/weapon/f_card/examine(mob/user)
	..()
	if(fingerprints.len)
		user << "<span class='notice'>Fingerprints on this card:</span>"
		for(var/print in fingerprints)
			user << "<span class='notice'>\t[fingerprints[print]]</span>"

/obj/item/weapon/fcardholder
	name = "fingerprint card case"
	desc = "Apply finger print card."
	icon = 'icons/obj/items.dmi'
	icon_state = "fcardholder0"
	item_state = "clipboard"
