/obj/item/weapon/paint_brush
	desc = "Used for the popular hobby of watching paint dry."
	name = "paint brush"
	icon = 'icons/obj/items.dmi'
	icon_state = "paintbrush"
	force = 3.0
	throwforce = 6.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	attack_verb = list( "whapped", "slapped", "hit", "whacked" )

	var/paint_color = null
	var/list/paint_modes = list( "Base" = "base", "Bottom Stripe" = "stripe0", "Top Stripe" = "stripe1" )
	var/paint_mode = "base" // Different paint modes

	var/volume = 0
	var/max_volume = 5

/obj/item/weapon/paint_brush/New()
	..()

	create_reagents(5)

/obj/item/weapon/paint_brush/attack_self(mob/user as mob)
	var/choice = input( user, "What type do you want to paint?", "Choose a Paint Mode" ) as null|anything in paint_modes

	if( choice )
		paint_mode = paint_modes[choice]

/obj/item/weapon/paint_brush/proc/wash()
	paint_color = null
	volume = 0

	update_icon()

/obj/item/weapon/paint_brush/proc/transferPaint( var/amount, var/color )
	if( !color || color == paint_color )
		return -2
	if( volume == max_volume )
		return -1
	if( amount <=  0 )
		return 0
	if( amount+volume > max_volume )
		amount = max_volume-amount

	volume += amount
	paint_color = color

	update_icon()

	return 1

/turf/simulated/wall/proc/update_paint_icon()
	if( !paint )
		return

	// Making the various images
	var/icon/base = image(icon = paint.icon, icon_state = "[paint.base_icon][smoothwall_connections]")
	base += paint.getColor( "base" )

	var/icon/stripe0 = image(icon = paint.icon, icon_state = "[paint.stripe0_icon][smoothwall_connections]")
	stripe0 += paint.getColor( "stripe0_color" )

	var/icon/stripe1 = image(icon = paint.icon, icon_state = "[paint.stripe1_icon][smoothwall_connections]")
	stripe1 += paint.getColor( "stripe1_color" )

	// Building the composite image
	var/icon/composite = base
	composite.Blend( stripe0 )
	composite.Blend( stripe1 )

	var/image/img = composite
	img.layer = TURF_LAYER+0.1

	// Garbage collecting
	overlays -= paint_overlay
	qdel( paint_overlay )

	// Adding new overlay
	paint_overlay = img
	overlays += paint_overlay

/turf/simulated/wall/proc/paint( var/color, var/mode = "base" )
	if( !color )
		return
	if( !paint )
		return

	paint.paint( color, mode )

	update_paint_icon()

/turf/simulated/wall/proc/unpaint( var/mode = null )
	if( !paint )
		return

	paint.unpaint( mode )

	update_paint_icon()
