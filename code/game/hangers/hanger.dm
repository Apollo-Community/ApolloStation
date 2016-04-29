//A hanger representing and keeping track of an area of turfs shuttles can land on.
//Also keeps track if its in space and or occupied.

obj/hanger
	var/htag
	var/full = 0
	var/exterior = 1
	var/dimx = 0
	var/dimy = 0
	var/square = 0
	var/area/hanger_area
	var/hanger_area_tag
	var/list/hanger_turf_atribs
	var/list/hanger_area_turfs
	var/list/hanger_turfs
	name = "Shuttle Jump Beacon"
	desc = "Small machine which acts as a lock on point for shuttles"
	anchored = 1
	density = 0
	layer = 2.46 // Above cables, but should be below floors.
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon" // If anyone wants to make better sprite, feel free to do so without asking me.

//Initializes the hanger.
//This is basically delayed constructor to make the creation of hangers
//More user friendly in the hanger controller. (AKA nobody wants to pass a thousant arguments to have to pass)
obj/hanger/New()
	//If we have an hanger area get its turfs we may or may not need this later.
	//Note: the turfs gotten when else is reached will probably never be used but need them for debugging
	hanger_area = locate(text2path(hanger_area_tag))
	if(!isnull(hanger_area) && isnull(hanger_area_turfs))
		hanger_area_turfs = get_area_turfs(hanger_area.type)
	else
		hanger_area_turfs = get_turfs_square(x, y, z, dimx, dimy)

	//If no location was assigned but we have hanger area turfs, calculate the aprocimate center of the hanger and take that as location.
	//This is used to make hangers in space easier

	if(!isnull(hanger_area_turfs) && dimx == 0 && dimy == 0)
		var/datum/dim_min_max/dims = get_dim_and_minmax(hanger_area_turfs)
		dimx = dims.dim_x
		dimy = dims.dim_y
		if(dimx % 2)
			//odd dim x
			dimx += round(1 + dimx)
		if(dimy % 2)
			//odd dim y
			dimy += round(1 + dimy)
	error("hanger [htag] created with [hanger_area_turfs.len] turfs and is square [square]")
	add_to_controller()

//Can the given shuttle land at this hanger ?
//Give an x and y dimensions of the shuttle
//If the hanger is not square look if the shuttle will fit in the hanger turfs
//This is important for hangers with docking arms
obj/hanger/proc/can_land_at(var/datum/shuttle/s)
	error("can_land_at called by [s.template_path]")
	var/list/shuttle_turfs
	if(full)
		return 0
	error("Passed full test [s.template_path]")
	if(square == 1)
		error("Square testing")
		if(s.template_dim[1] > dimx || s.template_dim[2] > dimy)
			error("square test failed")
			return 0
		error("Passed square test")
	else
		error("null testing")
		if(isnull(s.shuttle_turfs) || isnull(hanger_area_turfs))
			error("null test failed")
			return 0
		else
			var/datum/coords/current_loc = new /datum/coords
			current_loc.x_pos = s.current_hanger.x
			current_loc.y_pos = s.current_hanger.y
			current_loc.z_pos = s.current_hanger.z
			var/datum/coords/hloc = new /datum/coords
			hloc.x_pos = x
			hloc.y_pos = y
			hloc.z_pos = z

			shuttle_turfs = shift_turfs(current_loc, hloc, s.shuttle_turfs)
			for(var/turf/T in shuttle_turfs)
				if(hanger_area_turfs.Find(T) >= 1)
					error("turfs check test failed")
					return 0
	error("returning with 1")
	return 1



//Shuttle indicating its going to land at a hanger
obj/hanger/proc/land_at(var/datum/shuttle/s)
	if(!exterior)
		hanger_turfs = hanger_area_turfs
		hanger_turf_atribs = truf_atrib_lister(hanger_turfs)

obj/hanger/proc/take_off()
	error("take_off called")
	if(!exterior)
		truf_atrib_placer(hanger_turf_atribs)
	full = 0
	error("returning with [full]")

obj/hanger/proc/add_to_controller()
	hangers += src
	hangers_as[htag] = src
	//error("[htag] created at [x], [y], [z]")

obj/hanger/square/interior/New()
	..()
	land_at(null)

obj/hanger/oddshaped/interior/New()
	..()
	land_at(null)