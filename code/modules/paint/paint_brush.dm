/obj/item/weapon/paint_brush
	desc = "Used for the popular hobby of watching paint dry."
	name = "paint brush"
	icon = 'icons/obj/items.dmi'
	icon_state = "paintbrush"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	attack_verb = list( "whapped", "slapped", "hit", "whacked" )
	var/list/paint_modes = list( "base", "stripe0", "stripe1" )
	var/paint_mode = "base" // Different paint modes

/obj/item/weapon/paint_brush/New()
	..()

	create_reagents(5)

/obj/item/weapon/paint_brush/attack_self(mob/user as mob)
	var/choice = input(usr, "What type do you want to paint?", "Choose a Paint Mode", "") as null|anything in paint_modes

	if( choice )
		paint_mode = choice

/turf/simulated/wall/proc/update_paint_icon()
	if( !paint )
		return

	// Making the various images
	var/icon/base = image(icon = paint.icon, icon_state = "[paint.base_icon][smoothwall_connections]")
	base += paint.base_color
	base.layer = TURF_LAYER+0.1

	var/icon/stripe0 = image(icon = paint.icon, icon_state = "[paint.stripe0_icon][smoothwall_connections]")
	stripe0 += paint.stripe0_color
	stripe0.layer = TURF_LAYER+0.2

	var/icon/stripe1 = image(icon = paint.icon, icon_state = "[paint.stripe1_icon][smoothwall_connections]")
	stripe1 += paint.stripe1_color
	stripe1.layer = TURF_LAYER+0.3

	// Building the composite image
	var/icon/composite = base
	composite.Blend( stripe0 )
	composite.Blend( stripe1 )

	var/image/img = composite

	// Garbage collecting
	overlays -= paint_overlay
	qdel( paint_overlay )

	// Adding new overlay
	paint_overlay = img
	overlays += paint_overlay

/turf/simulated/wall/proc/paint( var/color, var/mode )
	if( !color )
		return
	if( !mode )
		return
	if( !paint )
		return

	paint.paint( color, mode )

	update_paint_icon()

/turf/simulated/wall/proc/unpaint( var/mode = null )
	if( !paint )
		return

	paint.paint( mode )

	update_paint_icon()
