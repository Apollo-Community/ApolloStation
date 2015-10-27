//NEVER USE THIS IT SUX	-PETETHEGOAT

var/global/list/cached_icons = list()

/obj/item/weapon/reagent_containers/glass/paint
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"
	matter = list("metal" = 200)
	w_class = 3.0
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10,20,30,50,70)
	volume = 70
	flags = OPENCONTAINER
	var/paint_type = ""

/obj/item/weapon/reagent_containers/glass/paint/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/paint_brush))
		if(reagents.total_volume < 1)
			user << "[src] is out of paint!</span>"
		else
			reagents.trans_to(I, 5)
			user << "<span class='notice'>You wet [I] in [src].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

/obj/item/weapon/reagent_containers/glass/paint/afterattack(turf/simulated/target, mob/user, proximity)
	if(!proximity) return
	if(istype(target) && reagents.total_volume > 5)
		for(var/mob/O in viewers(user))
			O.show_message("\red \The [target] has been splashed with paint by [user]!", 1)
		spawn(5)
			reagents.reaction(target, TOUCH)
			reagents.remove_any(5)
	else
		return ..()

/obj/item/weapon/reagent_containers/glass/paint/New()
	if(paint_type == "remover")
		name = "paint remover bucket"
	else if(paint_type && lentext(paint_type) > 0)
		name = paint_type + " " + name
	..()
	reagents.add_reagent("paint_[paint_type]", volume)

/obj/item/weapon/reagent_containers/glass/paint/on_reagent_change() //Until we have a generic "paint", this will give new colours to all paints in the can
	var/mixedcolor = mix_color_from_reagents(reagents.reagent_list)
	for(var/datum/reagent/paint/P in reagents.reagent_list)
		P.color = mixedcolor


/obj/item/weapon/reagent_containers/glass/paint/red
	icon_state = "paint_red"
	paint_type = "red"

/obj/item/weapon/reagent_containers/glass/paint/green
	icon_state = "paint_green"
	paint_type = "green"

/obj/item/weapon/reagent_containers/glass/paint/blue
	icon_state = "paint_blue"
	paint_type = "blue"

/obj/item/weapon/reagent_containers/glass/paint/yellow
	icon_state = "paint_yellow"
	paint_type = "yellow"

/obj/item/weapon/reagent_containers/glass/paint/orange
	icon_state = "paint_orange"
	paint_type = "orange"

/obj/item/weapon/reagent_containers/glass/paint/purple
	icon_state = "paint_purple"
	paint_type = "purple"

/obj/item/weapon/reagent_containers/glass/paint/black
	icon_state = "paint_black"
	paint_type = "black"

/obj/item/weapon/reagent_containers/glass/paint/white
	icon_state = "paint_white"
	paint_type = "white"

/obj/item/weapon/reagent_containers/glass/paint/phoron
	icon_state = "paint_phoron"
	paint_type = "phoron"

/obj/item/weapon/reagent_containers/glass/paint/remover
	paint_type = "remover"

