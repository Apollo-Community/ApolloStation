/obj/structures/hobo_barrel
	name = "Hobo barrel"
	icon = 'icons/misc/hobo_barrel.dmi'
	icon_state = "off"
	desc = "A cold piece of cilindric metal."
	var/obj/structures/hobo_barrel/lit = 0
	anchored = 1 //About time someone fixed this.
	density = 1
	light_color = FIRE_COLOR
	light_range = 2
	var/max_paper = 10
	var/paper = 0
/obj/structures/hobo_barrel/New()
	..()

/obj/structures/hobo_barrel/attackby(var/obj/item/I,var/mob/user)
	if(istype(I,/obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/C = I
		if(C.lit == 1 && max_paper == paper)
			icon_state = "hobo_barrel"
			user << "You throw the lit [I.name] into the barrel, and the paper inside lights up in flames!"
		else
			user << "You throw the [I.name] into the barrel."
		qdel(C)
	if(istype(I,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = I
		if(paper < max_paper)
			paper = 1
			user << "You throw the [P.name] into the barrel."
			qdel(P)
		else
			user << "The barrel is full."