/turf/space/bluespace
	icon = 'icons/turf/space.dmi'
	icon_state = "bluespace"
	name = "\proper bluespace"

	temperature = 0
	thermal_conductivity = 0
//	heat_capacity = 700000 No.

/turf/space/bluespace/New()
	var/size = rand(1, 3)

	for( var/i = 1; i <= size; i++ )
		var/image/star = image(icon, icon_state=pick( "bstar1", "bstar2" ))
		star.pixel_x = rand( -14, 14 )
		star.pixel_y = rand( -14, 14 )
		i++
		overlays += star

/turf/space/bluespace/Entered(atom/movable/A as mob|obj)
	return