/obj/effect/map
	name = ""
	desc = ""
	icon = 'icons/effects/sectors.dmi'

	var/real_name = ""
	var/real_desc = ""
	var/real_icon_state = "unknown"
	var/map_z = 0
	var/obj/effect/mapinfo/sector/metadata = null

/obj/effect/map/New( var/obj/effect/mapinfo/data, var/turf/T )
	metadata = data

	if( !metadata )
		qdel( src )

	loc = T

	map_z = metadata.zlevel
	real_name = metadata.name
	real_desc = metadata.desc

	update_icon()

	tag = "OVERMAP [real_name]"

/obj/effect/map/update_icon()
	icon_state = real_icon_state

	src.overlays.Cut()

	var/sector_type
	if(( metadata.sector_flags & SECTOR_KNOWN ) && ( metadata.sector_flags & SECTOR_LOCAL ))
		sector_type = "known"
	else if( metadata.sector_flags & SECTOR_LOCAL )
		sector_type = "unknown"
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

	if( icon_state )
		name = real_name

	spawn( 5 )
		if( isKnown() )
			reveal()

/obj/effect/map/sector/CanPass(atom/movable/A)
	return 1

/obj/effect/map/sector/Crossed(atom/movable/A)
	if( !( metadata.sector_flags & SECTOR_LOCAL ))
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
/obj/effect/map/sector/apollo
	real_icon_state = "NOS Apollo"
	real_desc = "The NOS Apollo, the hub of operations in this sector of the Nyx system."

/obj/effect/map/sector/ace
	real_icon_state = "ACE"

/obj/effect/map/sector/engipost
	real_icon_state = "Engi Outpost"

/obj/effect/map/sector/moon
	real_icon_state = "Moon"

/obj/effect/map/sector/slater
	real_icon_state = "NMV Slater"

/obj/effect/map/sector/asteroid/New()
	real_icon_state = "asteroid[rand(0,3)]"
	..()
