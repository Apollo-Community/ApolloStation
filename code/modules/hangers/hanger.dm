//A hanger representing and keeping track of an area of turfs shuttles can land on.
//Also keeps track if its in space and or occupied.
//The hanger contains a "smart" init_hanger() part that is able to construct
//a hanger from a range of arguments.
//There are 3 types of hangers
//Dimensional beacon based - Just a beacon and given dimensions
//Dimensional area based - No beacon just an area, used to calculate center point.
//None dimensional area/beacon hybrit - An area and a beacon defining the center point. This can house non square ships

//Make a global hanger for blue space travelers (this is hacky)
var/global/datum/hanger/hanger_blue/blue_hanger = new/datum/hanger/hanger_blue()

datum/hanger
	var/beacon_tag
	var/datum/coords/loc
	var/list/hanger_turfs
	var/full = 0
	var/exterior = 1
	var/area/hanger_area
	var/list/hanger_turf_atribs
	var/dimx = 0
	var/dimy = 0
	var/square = 1
	var/list/hanger_area_turfs = list()

//Initializes the hanger.
//This is basically delayed constructor to make the creation of hangers
//More user friendly in the hanger controller. (AKA nobody wants to pass a thousant arguments to have to pass)
datum/hanger/proc/init_hanger()
	//If we have a location beacon get the hanger location
	if(!isnull(beacon_tag))
		var/turf/locObj = locate(beacon_tag)
		if( !locObj )
			return
		loc = new/datum/coords()
		loc.x_pos = locObj.x
		loc.y_pos = locObj.y
		loc.z_pos = locObj.z

	//If we have an hanger area get its turfs we may or may not need this later.
	//Note: the turfs gotten when else is reached will probably never be used but need them for debugging
	if(!isnull(hanger_area) && ( isnull(hanger_area_turfs) || !hanger_area_turfs:len ))
		hanger_area_turfs = get_area_turfs(hanger_area.type)
	else
		hanger_area_turfs = get_turfs_square(loc.x_pos, loc.y_pos, loc.z_pos, dimx, dimy)

	//If no location was assigned but we have hanger area turfs, calculate the aprocimate center of the hanger and take that as location.
	//This is used to make hangers in space easier

	if(isnull(loc) && !isnull(hanger_area_turfs))
		loc = new/datum/coords
		square = 1

		var/datum/dim_min_max/dims = get_dim_and_minmax(hanger_area_turfs)
		dimx = dims.dim_x
		dimy = dims.dim_y
		if(dimx % 2)
			//odd dim x
			dimx += round(1 + dimx)
		if(dimy % 2)
			//odd dim y
			dimy += round(1 + dimy)
		loc.x_pos = dims.min_x + ((1/2)*dimx)
		loc.y_pos = dims.min_y + ((1/2)*dimy)
		loc.z_pos = dims.loc_z

//Can the given shuttle land at this hanger ?
//Give an x and y dimensions of the shuttle
//If the hanger is not square look if the shuttle will fit in the hanger turfs
//This is important for hangers with docking arms
datum/hanger/proc/can_land_at(var/datum/shuttle/s, var/list/shuttle_turfs = null)
	////error("Can_land called by [s.template_path] in [tag]")
	if(full)
		//error("[tag] was full [s.template_path]")
		return 0
	if(square)
		if(s.template_dim[1] > dimx || s.template_dim[2] > dimy)
			//error("[s.template_path] does not fit in [tag]")
			return 0
	else
		if(isnull(s.shuttle_turfs) || isnull(hanger_area_turfs))
			return 0
		else
			shuttle_turfs = shift_turfs(s.current_hanger.loc, loc, s.shuttle_turfs)
			for(var/turf/T in shuttle_turfs)
				if(hanger_area_turfs.Find(T) >= 1)
					return 0
	return 1


//Shuttle indicating its going to land at a hanger
datum/hanger/proc/land_at(var/datum/shuttle/s)
	//The way the very first call is made is messy to say the least. this is because we don't have a
	//Starting coord yet.. maybe calculate one ?
	//error("[s.template_path] is going to land at [tag]")
	if(!exterior)
		//Need to find a way to fix this..
		//if(s.shuttle_ingame)	hanger_turfs = shift_turfs(s.current_hanger.loc ,loc, s.shuttle_turfs)
		//else	hanger_turfs = hanger_area_turfs
		hanger_turfs = hanger_area_turfs
		hanger_turf_atribs = truf_atrib_lister(hanger_turfs)
		//error("[tag] saved [hanger_turfs.len] hanger turfs and [hanger_turf_atribs.len] atribs")

datum/hanger/proc/take_off()
	if(!full)
		return

	if(!exterior)
		truf_atrib_placer(hanger_turf_atribs)

	full = 0

//For when you have a long jump in blue space
datum/hanger/hanger_blue

datum/hanger/hanger_blue/can_land_at(var/datum/shuttle/s = null, var/list/shuttle_turfs = null)
	full = 0
	return 1

datum/hanger/hanger_blue/land_at(var/datum/shuttle/s = null)
	full = 0
	return

datum/hanger/hanger_blue/take_off()
	full = 0
	return