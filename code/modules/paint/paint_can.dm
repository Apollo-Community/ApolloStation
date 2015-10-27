var/global/list/paint_colors = list( "red" = "#992E2E",
									 "orange" = "#CC6A29",
									 "yellow" = "#CCCC3E",
									 "green" = "#2E992E",
									 "blue" = "#2E2E99",
									 "purple" = "#62358D",
									 "brown" = "#62462B",
									 "black" = "#1A1A1A",
									 "white" = "#BABABA",
									 "phoron" = "#603F7F" )

var/global/list/cached_icons = list()

/obj/item/weapon/paint_can
	desc = "It's a paint bucket."
	name = "paint bucket"
	icon = 'icons/obj/items.dmi'
	icon_state = "paint_neutral"
	item_state = "paintcan"

	matter = list("metal" = 200)

	w_class = 3.0

	var/max_volume = 120
	var/volume = 120
	var/transfer_amount = 5
	var/paint_color = "white"

/obj/item/weapon/paint_can/New()
	if( paint_color == "remover")
		name = "paint remover bucket"
	else if( !paint_color )
		volume = 0
	else
		update_icon()

/obj/item/weapon/paint_can/proc/getColor()
	return paint_colors[paint_color]

/obj/item/weapon/paint_can/proc/paint( var/atom/A, var/mob/user )
	if( !volume )
		if( user )
			user << "There's no paint left in \the [src]!"
		return 0

	if( istype( A, /turf/simulated/wall ))
		var/turf/simulated/wall/W = A
		W.paint( paint_color )
		volume = max( 0, volume-5 )
		if( user )
			user << "You splash the wall with [paint_color] paint."

/obj/item/weapon/paint_can/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/paint_brush))
		var/obj/item/weapon/paint_brush/brush = I

		var/amount = brush.transferPaint( transfer_amount, paint_color )

		switch( amount )
			if( -2 )
				user << "The [I] is already covered with a different color. Wash it off first to change it's color!"
			if( -1 )
				user << "The [I] is already covered with enough paint!"
			if( 0 )
				user << "[src] is out of paint!</span>"
			if( 1 )
				user << "<span class='notice'>You wet [I] in [src].</span>"
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

	..()

/obj/item/weapon/paint_can/afterattack(turf/simulated/wall/target, mob/user, proximity)
	if(!proximity) return
	if(istype(target) && reagents.total_volume > 5)
		for(var/mob/O in viewers(user))
			O.show_message("\red \The [target] has been splashed with paint by [user]!", 1)
		spawn(0)
			target.paint( paint_color )
	else
		return ..()

/obj/item/weapon/paint_can/red
	icon_state = "paint_red"
	paint_color = "red"

/obj/item/weapon/paint_can/green
	icon_state = "paint_green"
	paint_color = "green"

/obj/item/weapon/paint_can/blue
	icon_state = "paint_blue"
	paint_color = "blue"

/obj/item/weapon/paint_can/yellow
	icon_state = "paint_yellow"
	paint_color = "yellow"

/obj/item/weapon/paint_can/orange
	icon_state = "paint_orange"
	paint_color = "orange"

/obj/item/weapon/paint_can/purple
	icon_state = "paint_purple"
	paint_color = "purple"

/obj/item/weapon/paint_can/black
	icon_state = "paint_black"
	paint_color = "black"

/obj/item/weapon/paint_can/white
	icon_state = "paint_white"
	paint_color = "white"

/obj/item/weapon/paint_can/phoron
	icon_state = "paint_phoron"
	paint_color = "phoron"

/obj/item/weapon/paint_can/remover
	paint_color = "remover"

