/obj/effect/map
	name = ""
	desc = ""
	icon = 'icons/effects/sectors.dmi'

	var/real_name = ""
	var/real_desc = ""
	var/real_icon_state = "unknown"
	var/map_z = 0
	var/obj/effect/mapinfo/sector/metadata = null

/obj/effect/map/New(var/obj/effect/mapinfo/data)
	metadata = data

	if( !metadata )
		qdel( src )

	map_z = metadata.zlevel
	real_name = metadata.name
	real_desc = metadata.desc

	var/turf/T = null
	for( var/i = 0; i < 50; i++ )
		var/new_x = metadata.mapx ? metadata.mapx : rand(STATION_X-POPULATE_RADIUS, STATION_X+POPULATE_RADIUS)
		var/new_y = metadata.mapy ? metadata.mapx : rand(STATION_Y-POPULATE_RADIUS, STATION_Y+POPULATE_RADIUS)
		T = locate(new_x, new_y, OVERMAP_ZLEVEL)

		if( !sector_exists( T ) || ( metadata.mapx && metadata.mapy ))
			break
		else
			T = null

	if( !T )
		qdel( src )

	loc = T

	update_icon()

/obj/effect/map/update_icon()
	src.overlays.Cut()

	var/sector_type
	if(( metadata.sector_flags & SECTOR_KNOWN ) && ( metadata.sector_flags & SECTOR_LOCAL ))
		sector_type = "known"
/*	else if( SECTOR_LOCAL )
		sector_type = "unknown"*/
	else
		return

	var/image/designation = image('icons/effects/sectors.dmi', sector_type)
	src.overlays += designation


/obj/effect/map/sector
	real_name = "generic sector"
	real_desc = "Sector with some stuff in it."
	anchored = 1

/obj/effect/map/sector/New()
	..()

	spawn( 5 )
		if( isKnown() )
			reveal()

/obj/effect/map/sector/CanPass(atom/movable/A)
	return 1

/obj/effect/map/sector/Crossed(atom/movable/A)
	if( !isKnown() )
		return

	if( istype( A,/obj/effect/traveler ))
		var/obj/effect/traveler/T = A
		T.enterLocal()

/obj/effect/map/sector/proc/isKnown()
	if(( map_z in overmap.known_levels ) && ( map_z in overmap.local_levels ) && !( map_z in overmap.admin_levels ))
		return 1
	else
		return 0

/obj/effect/map/sector/proc/canRandomTeleport()
	if( isKnown() && ( map_z in overmap.can_random_teleport_levels ))
		return 1
	else
		return 0

/obj/effect/map/sector/proc/reveal()
	icon_state = real_icon_state
	name = real_name
	desc = real_desc

	var/obj/effect/mapinfo/sector/data = metadata

	if( !data )
		return

	if( !( data.sector_flags & SECTOR_KNOWN ))
		data.sector_flags |= SECTOR_KNOWN

	overmap.reportLevels( metadata )

//Space stragglers go here

/obj/effect/map/sector/nssapollo
	real_icon_state = "NSS Apollo"
	real_desc = "The NSS Apollo, state-of-the-art phoron research station."

/obj/effect/map/sector/ace
	real_icon_state = "ACE"

/obj/effect/map/sector/engipost
	real_icon_state = "Engi Outpost"

/obj/effect/map/sector/moon
	real_icon_state = "Moon"
