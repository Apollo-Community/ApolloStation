//Zlevel where overmap objects should be
#define OVERMAP_ZLEVEL 1
#define STATION_X 128
#define STATION_Y 128
#define POPULATE_RADIUS 5 // Radius form the station x, y to populate sectors
//How far from the edge of overmap zlevel could randomly placed objects spawn
#define OVERMAP_EDGE 9

// Sector flags
#define SECTOR_KNOWN 1 // Does this sector start out known?
#define SECTOR_STATION 2 // Is this sector part of the station?
#define SECTOR_ALERT 4 // Is this sector affected by alerts such as red alert?
#define SECTOR_LOCAL 8 // Is this sector accessible from the overmap?
#define SECTOR_ADMIN 16 // Is this sector accessible only through admoon intervention?

#define MAX_SECTORS 1 // How many unknown sectors are allowed?

//list used to track which zlevels are being 'moved' by the proc below
var/list/moving_levels = list()
//Proc to 'move' stars in spess
//yes it looks ugly, but it should only fire when state actually change.
//null direction stops movement
proc/toggle_move_stars(zlevel, direction)
	if(!zlevel)
		return

	var/gen_dir = null
	if(direction & (NORTH|SOUTH))
		gen_dir += "ns"
	else if(direction & (EAST|WEST))
		gen_dir += "ew"
	if(!direction)
		gen_dir = null

	if (moving_levels["zlevel"] != gen_dir)
		moving_levels["zlevel"] = gen_dir
		for(var/x = 1 to world.maxx)
			for(var/y = 1 to world.maxy)
				var/turf/space/T = locate(x,y,zlevel)
				if (istype(T))
					if(!gen_dir)
						T.icon_state = "[((T.x + T.y) ^ ~(T.x * T.y) + T.z) % 25]"
					else
						T.icon_state = "speedspace_[gen_dir]_[rand(1,15)]"
						for(var/atom/movable/AM in T)
							if (!AM.anchored)
								AM.throw_at(get_step(T,reverse_direction(direction)), 5, 1)

//===================================================================================
//Hook for building overmap
//===================================================================================
var/global/list/map_sectors = list()

/*
/hook/startup/proc/load_sectors()
	var/map_path = "maps/overmap/random/"
	var/list/maps = flist( map_path )

	for( var/i = 0, i < MAX_SECTORS, i++ )
		var/chosen = pick( maps )

		testing( "Loading [chosen] as a random sector" )
		maploader.load_map( map_path+chosen )
		testing( "Loaded" )
		maps.Remove( chosen )
*/

/hook/startup/proc/build_map()
	if(!config.use_overmap)
		return 1
	//testing("Building overmap...")
	var/obj/effect/mapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		if( data )
			//testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			map_sectors["[level]"] = new data.obj_type(data)

	generate_sectors_paper() // Making the info for our landmarks paper
	return 1