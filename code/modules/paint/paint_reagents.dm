datum/reagent/paint
	name = "Paint"
	id = "paint_"
	reagent_state = 2

	var/paint_type = /datum/paint

	description = "This paint will only adhere to walls."

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
	color = "#FE191A"

/datum/reagent/paint/green
	name = "Green Paint"
	id = "paint_green"
	paint_type = /datum/paint/green
	color = "#18A31A"

/datum/reagent/paint/blue
	name = "Blue Paint"
	id = "paint_blue"
	paint_type = /datum/paint/blue
	color = "#247CFF"

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	id = "paint_yellow"
	paint_type = /datum/paint/yellow
	color = "#FDFE7D"

/datum/reagent/paint/orange
	name = "Orange Paint"
	id = "paint_orange"
	paint_type = /datum/paint/orange
	color = "#FF8533"

/datum/reagent/paint/purple
	name = "Purple Paint"
	id = "paint_purple"
	paint_type = /datum/paint/purple
	color = "#CC0099"

/datum/reagent/paint/black
	name = "Black Paint"
	id = "paint_black"
	paint_type = /datum/paint/black
	color = "#333333"

/datum/reagent/paint/white
	name = "White Paint"
	id = "paint_white"
	paint_type = /datum/paint
	color = "#F0F8FF"

/datum/reagent/paint/phoron
	name = "Phoron Paint"
	id = "paint_phoron"
	paint_type = /datum/paint/phoron
	color = "#782296"

datum/reagent/paint_remover
	name = "Paint Remover"
	id = "paint_remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = 2
	color = "#808080"

datum/reagent/paint_remover/reaction_turf(var/turf/simulated/wall/T, var/volume)
	if(istype(T))
		T.unpaint()
	return
