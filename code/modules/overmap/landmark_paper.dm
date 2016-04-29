/obj/item/weapon/paper/sectors
	name = "Notable Landmarks List"

/obj/item/weapon/paper/sectors/New()
	..()

	spawn( 20 )
		info = overmap.sectors_landmarks_info
		update_icon()
