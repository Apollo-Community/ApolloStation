/obj/item/device/sector_locator
	name = "B.I.R.D."
	desc = "The Bluespace Interface Recon Device, or B.I.R.D., is a device commonly used in exploratory missions to determine where the user is."
	icon = 'icons/obj/device.dmi'
	icon_state = "sector_locator"
	item_state = "electronic"
	w_class = 2.0

/obj/item/device/sector_locator/attack_self(mob/living/user as mob)
	calculate_sector()

/obj/item/device/sector_locator/verb/sector_locate()
	set category = "Object"
	set name = "Triangulate Sector"
	set src = usr.loc

	calculate_sector()

/obj/item/device/sector_locator/proc/calculate_sector()
	var/turf/T = get_turf( src )
	T.visible_message("\icon[src] [src] [pick("chirps","chirrups","cheeps")], \"Give me a moment, I'll try to find out where we are. This may take up to 30 seconds!\"")
	var/cur_z = T.z
	spawn( rand( 100, 300 ))
		T = get_turf( src )
		if( cur_z != T.z )
			T.visible_message("\icon[src] [src] [pick("chirps","chirrups","cheeps")], \"I couldn't tell where we are. Don't wander so much next time!\"")
			return

		var/obj/effect/map/sector = map_sectors["[T.z]"]
		if( !sector )

			T.visible_message("\icon[src] [src] [pick("chirps","chirrups","cheeps")], \"I couldn't seem to find any nearby beacons!\"")
			return

		T.visible_message("\icon[src] [src] [pick("chirps","chirrups","cheeps")], \"You are currently located in Sector [SYSTEM_DESIGNATION]-[sector.x]-[sector.y]!\"")
