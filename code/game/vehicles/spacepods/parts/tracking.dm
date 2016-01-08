/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper tracking system"
	desc = "A tracking device for spacepods. Used by recall computers to recall the shuttles."
	icon_state = "locator"
	enabled = 1

/obj/item/device/spacepod_equipment/misc/tracker/check()
	return enabled

/obj/item/device/spacepod_equipment/misc/tracker/proc/get_turf()
	var/turf/T = get_turf( src )

	if( istype( T, /turf/space/bluespace ))
		T = null

	return T

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(check())
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		else
			enabled = 1
			user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
			return
	else
		..()
