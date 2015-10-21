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

	afterattack(turf/simulated/target, mob/user, proximity)
		if(!proximity) return
		if(istype(target) && reagents.total_volume > 5)
			for(var/mob/O in viewers(user))
				O.show_message("\red \The [target] has been splashed with paint by [user]!", 1)
			spawn(5)
				reagents.reaction(target, TOUCH)
				reagents.remove_any(5)
		else
			return ..()

	New()
		if(paint_type == "remover")
			name = "paint remover bucket"
		else if(paint_type && lentext(paint_type) > 0)
			name = paint_type + " " + name
		..()
		reagents.add_reagent("paint_[paint_type]", volume)

	on_reagent_change() //Until we have a generic "paint", this will give new colours to all paints in the can
		var/mixedcolor = mix_color_from_reagents(reagents.reagent_list)
		for(var/datum/reagent/paint/P in reagents.reagent_list)
			P.color = mixedcolor

	red
		icon_state = "paint_red"
		paint_type = "red"

	green
		icon_state = "paint_green"
		paint_type = "green"

	blue
		icon_state = "paint_blue"
		paint_type = "blue"

	yellow
		icon_state = "paint_yellow"
		paint_type = "yellow"

	violet
		icon_state = "paint_violet"
		paint_type = "violet"

	black
		icon_state = "paint_black"
		paint_type = "black"

	white
		icon_state = "paint_white"
		paint_type = "white"

	remover
		paint_type = "remover"

datum/reagent/paint
	name = "Paint"
	id = "paint_"
	reagent_state = 2

	var/paint_type = /datum/paint

	description = "This paint will only adhere to floor tiles."

datum/reagent/paint/reaction_turf(var/turf/simulated/wall/T, var/volume)
	if(!istype(T) || istype(T, /turf/space))
		return
	T.paint( PoolOrNew( paint_type ))

datum/reagent/paint/reaction_obj(var/obj/O, var/volume)
	..()
	if(istype(O,/obj/item/weapon/light))
		var/obj/item/weapon/light/L = O
		L.paint( PoolOrNew( paint_type ))

/datum/reagent/paint/red
	name = "Red Paint"
	id = "paint_red"
	paint_type = /datum/paint/red

/datum/reagent/paint/green
	name = "Green Paint"
	id = "paint_green"
	paint_type = /datum/paint/green

/datum/reagent/paint/blue
	name = "Blue Paint"
	id = "paint_blue"
	paint_type = /datum/paint/blue

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	id = "paint_yellow"
	paint_type = /datum/paint/yellow

/datum/reagent/paint/violet
	name = "Violet Paint"
	id = "paint_violet"
	paint_type = /datum/paint/purple

/datum/reagent/paint/black
	name = "Black Paint"
	id = "paint_black"
	paint_type = /datum/paint/black

/datum/reagent/paint/white
	name = "White Paint"
	id = "paint_white"
	paint_type = /datum/paint

datum/reagent/paint_remover
	name = "Paint Remover"
	id = "paint_remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = 2
	color = "#808080"

	reaction_turf(var/turf/T, var/volume)
		if(istype(T) && T.icon != initial(T.icon))
			T.icon = initial(T.icon)
		return
