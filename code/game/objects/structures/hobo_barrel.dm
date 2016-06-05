/obj/structure/hobo_barrel
	name = "hobo barrel"
	icon = 'icons/misc/hobo_barrel.dmi'
	icon_state = "off"
	desc = "A cold piece of cylindrical metal."
	var/obj/structure/hobo_barrel/lit = 0
	anchored = 1
	density = 1
	light_color = FIRE_COLOR
	light_range = 0
	var/max_paper = 10
	var/paper = 0

/obj/structure/hobo_barrel/New()
	..()

/obj/structure/hobo_barrel/attackby(var/obj/item/I,var/mob/user)
	if(istype(I,/obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = I
		if(C.lit == 1 && paper == max_paper)
			icon_state = "hobo_barrel"
			user << "You throw the lit [I.name] into the barrel, and the paper inside lights up in flames!"
			desc = "A hot piece of cylindrical metal."

			set_light(4)
		else
			user << "You throw the [I.name] into the barrel."
		qdel(C)
	else if(istype(I,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = I
		if(paper < max_paper)
			paper++
			user << "You throw the [P.name] into the barrel."
			qdel(P)
		else
			user << "The barrel is full."
	else if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/ratrod/raw))
		if(icon_state == "hobo_barrel")
			user << "<span class='notice'>You begin roasting the ratrod over the barrel fire.</span>"
			if(do_after(user, 100))
				user << "<span class='notice'>The rat gets a nice, brown color. You pull the ratrod away from the fire.</span>"
				qdel(I)
				var/obj/item/weapon/reagent_containers/food/snacks/ratrod/ratrod = new()
				ratrod.loc = get_turf(user)
				user.put_in_any_hand_if_possible(ratrod)
		else
			user << "<span class='notice'>You hold the ratrod over the barrel for no apparent reason.</span>"
